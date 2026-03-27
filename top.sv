module top (
    input bit clk,   
    input bit rstn
);

    
    dut u_dut (
        .clk  (clk), 
        .rstn (rstn)
    );

endmodule