SIM = top_tb
WAVE = 0
COV = 0
DEFINES = -d datain -d statusin -d shortsim
TEST = base_test
VERBOSITY = UVM_LOW

# Lista testów do pełnej regresji
TESTS_LIST = base_test long_burst_test busy_check_test err_inject_test

all: simulate

simulate: comp_rtl comp_tb elab run

comp_rtl:
	xvlog -L uvm -sv $(DEFINES) -f rtl.f > compile_rtl.log 2>&1

comp_tb:
	xvlog -L uvm -sv $(DEFINES) -f verif.f > compile_tb.log 2>&1

elab:
ifeq ($(COV), 1)
	xelab -timescale 1ns/10ps -L uvm -cc_type sbct -cc_dir ./cov_dir -cov_db_name CC_DB1 -debug typical $(SIM) > elab.log 2>&1
else
	xelab -timescale 1ns/10ps  -L uvm -debug typical $(SIM) > elab.log 2>&1
endif

run:
ifeq ($(WAVE), 1)
	xsim $(SIM) -testplusarg UVM_TESTNAME=$(TEST) -testplusarg UVM_VERBOSITY=$(VERBOSITY) -tclbatch run.tcl 2>&1 | tee run.log
	xsim work.$(SIM).wdb -gui -view wave_conf.wcfg
else
	xsim $(SIM) -testplusarg UVM_TESTNAME=$(TEST) -testplusarg UVM_VERBOSITY=$(VERBOSITY) -tclbatch run.tcl 2>&1 | tee run.log
endif

ifeq ($(COV), 1)
	xcrg -cov_db_dir cov_dir -cov_db_name CC_DB1 -report_dir report
endif

# --- DODANE: SANITY CHECK ---
sanity: comp_rtl comp_tb elab
	@echo "================================================="
	@echo "             SANITY CHECK UVM                    "
	@echo "================================================="
	xsim $(SIM) -testplusarg UVM_TESTNAME=base_test -testplusarg UVM_VERBOSITY=UVM_LOW -tclbatch run.tcl 2>&1 | tee sanity.log
	@if grep -q -E "UVM_FATAL :[[:space:]]*[1-9]|UVM_ERROR :[[:space:]]*[1-9]" sanity.log; then \
		echo "-> FAIL: Sanity Check failed, check sanity.log"; \
		exit 1; \
	else \
		echo "-> PASS: Sanity Check passed"; \
	fi

# --- DODANE: REGRESJA ---
regression: comp_rtl comp_tb elab
	@echo "================================================="
	@echo "             REGRESJA UVM                        "
	@echo "================================================="
	@mkdir -p regression_logs
	@fail_cnt=0; \
	for test in $(TESTS_LIST); do \
		echo -n "Running test: $$test ... "; \
		xsim $(SIM) -testplusarg UVM_TESTNAME=$$test -testplusarg UVM_VERBOSITY=UVM_LOW -tclbatch run.tcl > regression_logs/$$test.log 2>&1; \
		\
		ERR_CNT=$$(grep -E "UVM_FATAL :[[:space:]]*[1-9]|UVM_ERROR :[[:space:]]*[1-9]" regression_logs/$$test.log | wc -l); \
		\
		if [ "$$test" = "err_inject_test" ]; then \
			if [ "$$ERR_CNT" -gt 0 ]; then \
				echo "PASS (Expected Error Found)"; \
			else \
				echo "FAIL (Expected Error Not Found)"; \
				fail_cnt=$$((fail_cnt + 1)); \
			fi; \
		else \
			if [ "$$ERR_CNT" -eq 0 ]; then \
				echo "PASS"; \
			else \
				echo "FAIL (Unexpected errors found!)"; \
				fail_cnt=$$((fail_cnt + 1)); \
			fi; \
		fi; \
	done; \
	echo "================================================="; \
	if [ $$fail_cnt -eq 0 ]; then \
		echo "SUCCESS. All tests passed."; \
	else \
		echo "FAILURE. Failed tests: $$fail_cnt."; \
		exit 1; \
	fi

clean:
	rm -rf xsim.dir logs *.pb *.jou *.wdb *.log *.str cov_dir report regression_logs sanity.log