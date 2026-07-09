#Makefile instruction

##Quick Start
To check if enviroment is working correctly run **make sanity**
To launch full regresion run **make regression**
All test should pass.

To run selected test, run **make all TEST="name_of_the_test"

All rtl sources are listed in rtl.f (make comp_rtl to compile)
All verif sources are listed in verif.f (make comp_tb to compile)

##Variables
SIM - top module (type file name)
WAVE - records signals waves and turn on Vivado GUI (value 0 or 1)
COV - turn on collecting coverage (value 0 or 1)
DEFINES - arguments for Vivado compilation (string)
TEST - name of test to run 
VERBOSITY - uvm verbosity level


To run only elaboration type **make elab**
To run only simulation type **make run**


