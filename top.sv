`timescale 1ns / 10ps

module top;
    
    wire clk;
    wire rstn;

    
    wire       valid;
    wire       ready;
    wire [7:0] cmd_data;
    wire [7:0] read_data;
    wire [7:0] write_data;
    wire [23:0] address_data;

    
    top_tb top_tb_inst(
        .clk       (clk),
        .rstn      (rstn),
        .valid     (valid),
        .ready     (ready),
        .cmd_data  (cmd_data),
        .read_data (read_data),
        .address_data (address_data),
        .write_data (write_data)
    );

    
    dut dut_inst (
        .clk       (clk),
        .rstn      (rstn),
        .valid     (valid),
        .ready     (ready),
        .data_in   (cmd_data),
        .data_out  (read_data),
        .data_in_address (address_data),
        .data_in_data (write_data)
    );
endmodule