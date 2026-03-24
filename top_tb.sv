module top_tb;
    
    bit clk;
    bit rstn;

    
    always #5 clk = ~clk; 

    initial begin
        
        $display("[%0t] Simulation started", $time);
        
        rstn = 0; 
        $display("[%0t] Reset asserted", $time);
        
        #20;      
        
        rstn = 1; 
        $display("[%0t] Reset deasserted", $time);

        $finish;
    end

    
    top u_top (
        .clk  (clk),
        .rstn (rstn)
    );

endmodule