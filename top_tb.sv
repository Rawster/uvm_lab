`timescale 1ns / 10ps

module top_tb (
    output bit        clk,
    output bit        rstn,
    output bit        valid,
    input  bit        ready,       
    output bit [7:0]  cmd_data,
    output bit [23:0] address_data,
    output bit [7:0]  write_data,
    input  bit [7:0]  read_data    
);
    


    // Zegar
    always #20 clk = ~clk; 
    initial begin

        rstn = 1; 
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
            $display("TEST 1: READ MANUFACTURER CODE");
            $display("SUCCESS: Received ID 62h (SANYO)!");
            $display("---------------------------------------");
        end else begin
            $error("ERROR: Expected 62h, received %h", read_data);
        end
      //TEST 2 READ MEMORY

        wait(ready == 1);

        @(posedge clk);
        cmd_data     = 8'h03;        
        address_data = 24'h000000;
        valid    = 1;

        @(posedge clk);
        valid    = 0;

   
        wait(ready == 1);
        #10;

        if (read_data == 8'h01) begin
            $display("---------------------------------------");
            $display("TEST 2: READ FROM MEMORY");
            $display("SUCCESS: Received 0x01!");
            $display("---------------------------------------");
        end else begin
            $error("ERROR: Expected 0x01, received %h", read_data);
        end


        //TEST 3 READ STATUS register

        wait(ready == 1);

        @(posedge clk);
        cmd_data     = 8'h05;        
        valid    = 1;

        @(posedge clk);
        valid    = 0;

   
        wait(ready == 1);
        #10;

        if (read_data == 8'h80) begin
            $display("---------------------------------------");
            $display("TEST 3: SETUP REGISTER");
            $display("SUCCESS: Received b'10000000!");
            $display("---------------------------------------");
        end else begin
            $error("ERROR: Expectedb'10000000, received %b", read_data);
        end

        //TEST 4 PURGE AND WRITE 1 BYTE

        //send write enable
        wait(ready == 1);

        @(posedge clk);
        
        cmd_data     = 8'h06;        
        valid    = 1;

        @(posedge clk);
        valid    = 0;

   
        wait(ready == 1);
        @(posedge clk);
        //send purge
        wait(ready == 1);

        @(posedge clk);
        
        cmd_data     = 8'h20;
        address_data = 8'h01;        
        valid    = 1;

        @(posedge clk);
        valid    = 0;

        
        wait(ready == 1);
        @(posedge clk);

        //wait for purge to be done
        do begin
            @(posedge clk);
            cmd_data = 8'h05; valid = 1; // Read Status
            @(posedge clk);
            valid = 0;
            wait(ready == 1);
            #10000;
            if (read_data[0] == 1) 
                $display("[%0t] Flash is still BUSY...", $time);
        end while (read_data[0] == 1); 
        @(posedge clk);
        //send write enable
        wait(ready == 1);

        @(posedge clk);
        
        cmd_data     = 8'h06;        
        valid    = 1;

        @(posedge clk);
        valid    = 0;
        $display("[%0t] write enable sent", $time);
        @(posedge clk);
        //write data
        wait(ready == 1);

       
        
        cmd_data     = 8'h02;
        address_data = 8'h01; 
        write_data = 8'h55;  
         @(posedge clk);      
        valid    = 1;

        @(posedge clk);
        valid    = 0;

        wait(ready == 1);

        do begin
            @(posedge clk);
            cmd_data = 8'h05; valid = 1; // Read Status
            @(posedge clk);
            valid = 0;
            wait(ready == 1);
            #10;
            if (read_data[0] == 1) 
                $display("[%0t] Flash is still PROGRAMMING...", $time);
        end while (read_data[0] == 1);

   
        valid = 0;          // 1. Wyłączasz valid
        wait(ready == 1);   // 2. Czekasz aż sterownik będzie gotowy
        @(posedge clk);     // 3. WYMUSZASZ JEDEN TAKT PRZERWY (Tutaj CEB pójdzie na 1)
        
        // --- TERAZ DOPIERO ODCZYT PAMIĘCI ---
        cmd_data     = 8'h03;        
        address_data = 24'h000001; 
        valid        = 1;   // Teraz dajesz valid na nową komendę

        @(posedge clk);
        valid    = 0;
        // ---------------------------------

        wait(ready == 1);
        #10; // Czas na ustabilizowanie read_data


        if (read_data == 8'h55) begin
            $display("---------------------------------------");
            $display("TEST 4: WRITE");
            $display("SUCCESS: Received same as Written 0x55");
            $display("---------------------------------------");
        end else begin
            $error("ERROR: Expected 0x55 received %h", read_data);
        end


        


        $display("[%0t] Simulation finished", $time);
        $finish;
    end


endmodule