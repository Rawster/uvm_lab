SIM = top_tb

all: simulate

simulate: comp_rtl comp_tb elab run

comp_rtl:
	xvlog -sv -f rtl.f > compile_rtl.log 2>&1

comp_tb:
	xvlog -sv -f verif.f > compile_tb.log 2>&1

elab:
	xelab $(SIM) > elab.log 2>&1

run:
	xsim $(SIM) 2>&1 | tee run.log

clean:
	rm -rf xsim.dir logs *.pb *.jou *.wdb *.log 
