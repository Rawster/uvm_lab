SIM = top
WAVE = 0
COV = 0
DEFINES = -d datain -d statusin -d shortsim

all: simulate

simulate: comp_rtl comp_tb elab run

comp_rtl:
	xvlog -sv $(DEFINES) -f rtl.f > compile_rtl.log 2>&1

comp_tb:
	xvlog -sv $(DEFINES) -f verif.f > compile_tb.log 2>&1

elab:
ifeq ($(COV), 1)
	xelab -cc_type sbct -cc_dir ./cov_dir -cov_db_name CC_DB1 -debug typical $(SIM) > elab.log 2>&1
else
	xelab -debug typical $(SIM) > elab.log 2>&1
endif


run:
ifeq ($(WAVE), 1)
	xsim $(SIM) -tclbatch run.tcl 2>&1 | tee run.log
	xsim work.$(SIM).wdb -gui -view wave_conf.wcfg
else
	xsim $(SIM) -tclbatch run.tcl -R 2>&1 | tee run.log
endif

ifeq ($(COV), 1)
	xcrg -cov_db_dir cov_dir -cov_db_name CC_DB1 -report_dir report
endif


clean:
	rm -rf xsim.dir logs *.pb *.jou *.wdb *.log *.str cov_dir report