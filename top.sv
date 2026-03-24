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
        .data_to   (cmd_data),
        .data_from (read_data)
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