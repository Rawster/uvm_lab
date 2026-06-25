`timescale 1ns / 10ps

module dut (
    input  bit       clk,
    input  bit       rstn,
    input  bit       valid,
    output bit       ready,
    input  bit [7:0] data_in,
    input  bit [23:0] data_in_address,
    input  bit [7:0] data_in_data,
    output bit [7:0] data_out
);
    
    wire sck, si, so, ceb, wpb, holdb;

    
    SST25WF020A flash_inst (
        .SCK   (sck),   
        .SI    (si),    
        .SO    (so),    
        .CEB   (ceb),   
        .WPB   (wpb),   
        .HOLDB (holdb)  
    );

    
    controller controller_inst (
        .clk    (clk),
        .rstn   (rstn),
        
        .valid  (valid),
        .ready  (ready),
        .d_in   (data_in),
        .d_out  (data_out),
        
        .sck    (sck),
        .si     (si),
        .so     (so),
        .ceb    (ceb),
        .wpb    (wpb),
        .holdb  (holdb),
        .d_in_address (data_in_address),
        .d_in_data(data_in_data)
    );
endmodule