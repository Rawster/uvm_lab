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

        // Inicjalizacja sygnałów wejściowych
        vif.valid        = 0;
        vif.cmd_data     = 0;
        vif.address_data = 0;
        vif.burst_len    = 0;
        for (int i = 0; i < 256; i++) vif.write_data_arr[i] = 0;

        vif.rstn = 1;
        @(posedge vif.clk);

        // --- 1. CZYSZCZENIE CAŁEJ PAMIĘCI ---
        `uvm_info("DRIVER", "Rozpoczynam formatowanie calej pamieci (64 sektory po 4KB)...", UVM_LOW)
        
        for (int i = 0; i < 64; i++) begin
            bit [23:0] sector_addr = i * 24'h001000;

            // WREN (0x06) - 1 bajt (burst_len = 0)
            wait(vif.ready == 1);
            @(posedge vif.clk);
            vif.cmd_data     = ENABLE_WRITE_COMMAND ;        
            vif.burst_len    = 0; 
            vif.valid        = 1;
            @(posedge vif.clk); @(posedge vif.clk);
            vif.valid        = 0;
            @(posedge vif.clk); @(posedge vif.clk);
            wait(vif.ready === 1'b1);

            // PURGE (0x20) 
            @(posedge vif.clk);
            vif.cmd_data     = PURGE_COMMAND;        
            vif.address_data = sector_addr; 
            vif.burst_len    = 0;
            vif.valid        = 1;
            @(posedge vif.clk); @(posedge vif.clk);
            vif.valid        = 0;
            @(posedge vif.clk); @(posedge vif.clk);
            wait(vif.ready === 1'b1);

            // Polling (0x05) - czytamy 1 bajt statusu
            do begin
                wait(vif.ready == 1);
                @(posedge vif.clk);
                vif.cmd_data     = READ_REGISTER_COMMAND;
                vif.burst_len    = 0;
                vif.valid        = 1;
                @(posedge vif.clk); @(posedge vif.clk);
                vif.valid        = 0;
                @(posedge vif.clk); @(posedge vif.clk);
                wait(vif.ready == 1);
            end while (vif.read_data_arr[0][0] != 0); 

            if (i % 16 == 0 || i == 63) begin
                `uvm_info("DRIVER", $sformatf("Wyczyszczono sektor %0d/64 (Adres: %0h)", i+1, sector_addr), UVM_LOW)
            end
        end

        `uvm_info("DRIVER", "Cala pamiec wyczyszczona. Start pobierania transakcji w trybie BURST.", UVM_LOW)

        // --- 2. GŁÓWNA PĘTLA OBSŁUGI TRANSAKCJI ---
        forever begin
            seq_item_port.get_next_item(req);

            `uvm_info("DRIVER", $sformatf("Odebrano transakcje BURST -> CMD: %0h, ADDR: %0h, ILOSC BAJTOW: %0d", 
                                           req.command, req.address, req.burst_len), UVM_LOW)

            // Ponowne sprawdzenie zajętości pamięci (BUSY)
            do begin
                wait(vif.ready == 1);
                @(posedge vif.clk);
                vif.cmd_data     = READ_REGISTER_COMMAND;
                vif.burst_len    = 0;
                vif.valid        = 1;
                @(posedge vif.clk); @(posedge vif.clk);
                vif.valid        = 0;
                @(posedge vif.clk); @(posedge vif.clk);
                wait(vif.ready == 1);
            end while (vif.read_data_arr[0][0] != 0);

            // Transakcja ODCZYTU (0x03)
            if (req.command == READ_COMMAND) begin
                wait(vif.ready == 1);
                @(posedge vif.clk);
                vif.cmd_data     = req.command;        
                vif.address_data = req.address;
                vif.burst_len    = req.burst_len - 1; 
                vif.valid        = 1;

                @(posedge vif.clk); @(posedge vif.clk);
                vif.valid        = 0;
                @(posedge vif.clk); @(posedge vif.clk);
                wait(vif.ready === 1'b1);
            end

            // Transakcja ZAPISU (0x02)
            if (req.command == WRITE_COMMAND) begin
                // Najpierw Write Enable (0x06)
                wait(vif.ready == 1);
                @(posedge vif.clk);
                vif.cmd_data     = ENABLE_WRITE_COMMAND;
                vif.burst_len    = 0;        
                vif.valid        = 1;
                @(posedge vif.clk); @(posedge vif.clk);
                vif.valid        = 0;
                @(posedge vif.clk); @(posedge vif.clk);
                wait(vif.ready === 1'b1);

                
                @(posedge vif.clk);
                vif.cmd_data     = req.command;        
                vif.address_data = req.address;
                vif.burst_len    = req.burst_len - 1;
                
                


                foreach (req.data[i]) begin
                    vif.write_data_arr[i] = req.data[i];
                end
                
                vif.valid = 1; 

                @(posedge vif.clk); 

                
                if (req.error_inject) begin
                    `uvm_warning("DRIVER", "INJEKCJA BLEDU ukryta przed Monitorem! Fizyczny sprzęt dostanie zepsute dane.")
                    vif.write_data_arr[0] = ~vif.write_data_arr[0]; 
                end

                @(posedge vif.clk); 
                vif.valid = 0;
                @(posedge vif.clk); @(posedge vif.clk);
                wait(vif.ready === 1'b1);
            end

            #2000;
            seq_item_port.item_done();
        end
    endtask
endclass