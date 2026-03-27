`timescale 1ns / 10ps

module top;
    
    wire clk;
    wire rstn;

    
    wire       valid;
    wire       ready;
    wire [7:0] cmd_data;
    wire [7:0] read_data;

    
    top_tb top_tb_inst(
        .clk       (clk),
        .rstn      (rstn),
        .valid     (valid),
        .ready     (ready),
        .cmd_data  (cmd_data),
        .read_data (read_data)
    );

    
    dut dut_inst (
        .clk       (clk),
        .rstn      (rstn),
        .valid     (valid),
        .ready     (ready),
        .data_in   (cmd_data),
        .data_out  (read_data)
    );
endmodule