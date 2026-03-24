module controller (
    input  bit clk, rstn,
    input  bit valid,
    output bit ready,
    input  bit [7:0] d_in,
    output bit [7:0] d_out,
    output bit sck, si, ceb, wpb, holdb,
    input  bit so
);
    assign wpb   = 1'b1; 
    assign holdb = 1'b1; 
    assign ceb   = 1'b1; 
    assign ready = 1'b1;
    
    
endmodule