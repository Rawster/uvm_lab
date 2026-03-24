module top_tb();

logic CLK;
logic RST;

	top top_module(
	.CLK(CLK),
	.RST(RST)
	);	

initial begin
        CLK = 0;
        forever #5 CLK = ~CLK;
end


	
endmodule
