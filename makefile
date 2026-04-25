SIM = top
WAVE = 0
COV = 0
DEFINES = -d datain -d statusin -d shortsim
TEST = default

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
	xsim $(SIM) -testplusarg UVM_TESTNAME=$(TEST) -tclbatch run.tcl 2>&1 | tee run.log
	xsim work.$(SIM).wdb -gui -view wave_conf.wcfg
else
	xsim $(SIM) -testplusarg UVM_TESTNAME=$(TEST) -tclbatch run.tcl -R 2>&1 | tee run.log
endif

ifeq ($(COV), 1)
	xcrg -cov_db_dir cov_dir -cov_db_name CC_DB1 -report_dir report
endif




clean:
	rm -rf xsim.dir logs *.pb *.jou *.wdb *.log *.str cov_dir report