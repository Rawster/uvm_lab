class driver extends uvm_driver #(mem_seq_item);
    `uvm_component_utils(driver)
    
    virtual controller_if vif;

    function new (string name = "driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual controller_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal(get_type_name(), "Didn't get handle to virtual interface vif")
        end
    endfunction

    virtual task run_phase(uvm_phase phase);
        mem_seq_item req;

        // Inicjalizacja sygnałów wejściowych do kontrolera
        vif.valid        = 0;
        vif.cmd_data     = 0;
        vif.address_data = 0;
        vif.write_data   = 0;

        vif.rstn = 1;
        @(posedge vif.clk);

       
        
        `uvm_info("DRIVER", "Rozpoczynam formatowanie całej pamięci (64 sektory po 4KB)...", UVM_LOW)
        
        for (int i = 0; i < 64; i++) begin
            
            bit [23:0] sector_addr = i * 24'h001000;

            
            wait(vif.ready == 1);
            @(posedge vif.clk);
            vif.cmd_data     = 8'h06;        
            vif.valid        = 1;
            @(posedge vif.clk); @(posedge vif.clk);
            vif.valid        = 0;
            @(posedge vif.clk); @(posedge vif.clk);
            wait(vif.ready === 1'b1);

            
            @(posedge vif.clk);
            vif.cmd_data     = 8'h20;        
            vif.address_data = sector_addr; 
            vif.valid        = 1;
            @(posedge vif.clk); @(posedge vif.clk);
            vif.valid        = 0;
            @(posedge vif.clk); @(posedge vif.clk);
            wait(vif.ready === 1'b1);

            
            do begin
                wait(vif.ready == 1);
                @(posedge vif.clk);
                vif.cmd_data     = 8'h05; 
                vif.valid        = 1;
                @(posedge vif.clk); @(posedge vif.clk);
                vif.valid        = 0;
                @(posedge vif.clk); @(posedge vif.clk);
                wait(vif.ready == 1);
            end while (vif.read_data[0] != 0);


        end

        `uvm_info("DRIVER", "Cała pamięć wyczyszczona. Start pobierania transakcji z sekwencera.", UVM_LOW)

        
        forever begin
            seq_item_port.get_next_item(req);
            `uvm_info("DRIVER", $sformatf("Odebrano sekwencję -> CMD: %0h, ADDR: %0h, DATA: %0h", 
                                           req.command, req.address, req.data), UVM_LOW)

            // (BUSY)
            do begin
                wait(vif.ready == 1);
                @(posedge vif.clk);
                vif.cmd_data     = 8'h05;
                vif.valid        = 1;
                @(posedge vif.clk); @(posedge vif.clk);
                vif.valid        = 0;
                @(posedge vif.clk); @(posedge vif.clk);
                wait(vif.ready == 1);
            end while (vif.read_data[0] != 0);

            // Transakcja ODCZYTU (0x03)
            if (req.command == 8'h03) begin
                wait(vif.ready == 1);
                @(posedge vif.clk);
                vif.cmd_data     = req.command;        
                vif.address_data = req.address;
                vif.valid        = 1;

                @(posedge vif.clk); @(posedge vif.clk);
                vif.valid        = 0;
                @(posedge vif.clk); @(posedge vif.clk);
                wait(vif.ready === 1'b1);
            end

            // Transakcja ZAPISU (0x02)
            if (req.command == 8'h02) begin
                
                wait(vif.ready == 1);
                @(posedge vif.clk);
                vif.cmd_data     = 8'h06;        
                vif.valid        = 1;
                @(posedge vif.clk); @(posedge vif.clk);
                vif.valid        = 0;
                @(posedge vif.clk); @(posedge vif.clk);
                wait(vif.ready === 1'b1);

                // Właściwy zapis
                @(posedge vif.clk);
                vif.cmd_data     = req.command;        
                vif.address_data = req.address;
                vif.write_data   = req.data;
                vif.valid        = 1;

                @(posedge vif.clk); @(posedge vif.clk);
                vif.valid        = 0;
                @(posedge vif.clk); @(posedge vif.clk);
                wait(vif.ready === 1'b1);
            end

            #2000;
            seq_item_port.item_done();
        end
    endtask
endclass