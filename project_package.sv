package project_package;

import uvm_pkg::*;
`include "uvm_macros.svh"



parameter bit [7:0] WRITE_COMMAND = 8'h02;
parameter bit [7:0] READ_COMMAND = 8'h03;
parameter bit [7:0] READ_REGISTER_COMMAND = 8'h05;
parameter bit [7:0] PURGE_COMMAND = 8'h20;
parameter bit [7:0] READ_MANUFACTURER_COMMAND = 8'h9F;
parameter bit [7:0] ENABLE_WRITE_COMMAND = 8'h06;


`include "env_config.sv"
`include "uvm_sequence_item.sv"
`include "seq/uvm_sequence.sv"
`include "seq/uvm_long_burst_seq.sv"
`include "seq/uvm_busy_polling_seq.sv"
`include "seq/uvm_err_inject_seq.sv"

`include "uvm_sequencer.sv"
`include "uvm_scoreboard.sv"
`include "uvm_driver.sv"
`include "uvm_monitor.sv"

`include "uvm_agent.sv"
`include "uvm_env.sv"
`include "tests/base_test.sv"
`include "tests/uvm_long_burst_test.sv"
`include "tests/uvm_busy_polling_test.sv"
`include "tests/uvm_err_inject_test.sv"

endpackage