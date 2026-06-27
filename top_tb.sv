`timescale 1ns / 10ps
`include "uvm_macros.svh"
import uvm_pkg::*;
import project_package::*; 

interface controller_if(input bit clk);
    logic rstn;
    logic valid;
    logic ready;
    logic [7:0] cmd_data;
    logic [23:0] address_data;
    
    
    logic [7:0] burst_len;             
    logic [7:0] write_data_arr [0:255]; 
    logic [7:0] read_data_arr [0:255];  
endinterface

module top_tb;
    bit clk;
    always #20 clk = ~clk; 

    controller_if vif(clk);

    // 1. Definiujemy "fizyczne ścieżki" na naszej wirtualnej płytce PCB
    wire spi_sck;
    wire spi_si;  // MOSI
    wire spi_so;  // MISO
    wire spi_ceb; // Chip Select
    wire spi_wpb; // Write Protect
    wire spi_holdb; // Hold

    // 2. Instancjacja Twojego kontrolera - podłączamy sygnały SPI!
    controller dut (
        .clk(vif.clk),
        .rstn(vif.rstn),
        .valid(vif.valid),
        .ready(vif.ready),
        .d_in(vif.cmd_data),
        .d_in_address(vif.address_data),
        
        
        .burst_len(vif.burst_len),           
        .d_in_data_arr(vif.write_data_arr),  
        .d_out_arr(vif.read_data_arr),       
        
        .si(spi_si),
        .so(spi_so),
        .sck(spi_sck),
        .ceb(spi_ceb),
        .wpb(spi_wpb),
        .holdb(spi_holdb)
    );

    // 3. Instancjacja Modelu Pamięci Flash od Microchip
    SST25WF020A flash_memory (
        .SCK(spi_sck),
        .SI(spi_si),
        .SO(spi_so),
        .CEB(spi_ceb),
        .WPB(spi_wpb),
        .HOLDB(spi_holdb)
    );

    initial begin
        vif.rstn = 0;
        #50 vif.rstn = 1;
    end

    initial begin
        uvm_config_db#(virtual controller_if)::set(null, "*", "vif", vif);
        run_test("my_base_test");
    end
    
endmodule