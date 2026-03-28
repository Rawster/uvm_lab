SIM = top
WAVE = 0

all: simulate

simulate: comp_rtl comp_tb elab run

comp_rtl:
	xvlog -sv -f rtl.f > compile_rtl.log 2>&1

comp_tb:
	xvlog -sv -f verif.f > compile_tb.log 2>&1

elab:
	xelab -debug typical $(SIM) > elab.log 2>&1

run:
ifeq ($(WAVE), 1)
	xsim $(SIM) -tclbatch run.tcl 2>&1 | tee run.log
	xsim work.$(SIM).wdb -gui -view wave_conf.wcfg
else
	xsim $(SIM) -tclbatch run.tcl -R 2>&1 | tee run.log
endif

clean:
	rm -rf xsim.dir logs *.pb *.jou *.wdb *.log