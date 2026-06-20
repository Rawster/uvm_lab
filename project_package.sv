

package project_package;

import uvm_pkg::*;
`include "uvm_macros.svh"

`include "env_config.sv"
`include "uvm_sequence_item.sv"
`include "seq/uvm_sequence.sv"
`include "uvm_long_burst_seq.sv"
`include "uvm_sequencer.sv"
`include "uvm_scoreboard.sv"
`include "uvm_driver.sv"
`include "uvm_monitor.sv"

`include "uvm_agent.sv"
`include "uvm_env.sv"
`include "tests/base_test.sv"
`include "uvm_long_burst_test.sv"

localparam WRITE_COMMAND = 8'h02;
localparam READ_COMMAND = 8'h03;
localparam READ_REGISTER_COMMAND = 8'h05;
localparam PURGE_COMMAND = 8'h20;
localparam READ_MANUFACTURER_COMMAND = 8'h9F;
localparam ENABLE_WRITE_COMMAND = 8'h06;

endpackage





