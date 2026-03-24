module top_tb;
    
    bit clk;
    bit rstn;

    bit       valid;
    wire      ready;      
    bit [7:0] cmd_data;
    wire [7:0] read_data; 

    // Zegar
    always #5 clk = ~clk; 

    initial begin
        $display("[%0t] Simulation started", $time);
        
        
        rstn = 0; 
        valid = 0;
        cmd_data = 8'h00;
        $display("[%0t] Reset asserted", $time);
        
        #20;      
        
        rstn = 1; 
        $display("[%0t] Reset deasserted", $time);


        //#1000; 

        $display("[%0t] Simulation finished", $time);
        $finish;
    end


endmodule