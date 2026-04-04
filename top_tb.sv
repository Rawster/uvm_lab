`timescale 1ns / 10ps

module top_tb (
    output bit       clk,
    output bit       rstn,
    output bit       valid,
    input  bit       ready,       
    output bit [7:0] cmd_data,
    input  bit [7:0] read_data    
);
    


    // Zegar
    always #20 clk = ~clk; 

    initial begin
        $display("[%0t] Simulation started", $time);
        
        
        rstn = 0; 
        valid = 0;
        cmd_data = 8'h00;
        $display("[%0t] Reset asserted", $time);
        
        #20;      
        
        rstn = 1; 
        $display("[%0t] Reset deasserted", $time);
        
        #100;
        wait(ready == 1);

        //TEST 1 READ Manufacturer code
        $display("[%0t] READ COMMAND", $time);
        @(posedge clk);
        cmd_data = 8'h9F;
        valid    = 1;

        @(posedge clk);
        valid    = 0;

        wait(ready == 1);
        $display("[%0t] Controler response", $time);
        #10;

        if (read_data == 8'h62) begin
            $display("---------------------------------------");
            $display("SUCCESS: Odebrano ID 62h (SANYO)!");
            $display("---------------------------------------");
        end else begin
            $display("ERROR: Oczekiwano 62h, otrzymano %h", read_data);
        end



        $display("[%0t] Simulation finished", $time);
        $finish;
    end


endmodule