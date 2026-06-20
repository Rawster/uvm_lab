class scoreboard extends uvm_scoreboard;
    `uvm_component_utils(scoreboard)

    uvm_analysis_imp #(mem_seq_item, scoreboard) item_collected_export;

    
    bit [7:0] shadow_mem [bit [23:0]];

    function new(string name = "scoreboard", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        item_collected_export = new("item_collected_export", this);
    endfunction

    virtual function void write(mem_seq_item item);
        
        
        if (item.command == READ_MANUFACTURER_COMMAND) begin
            
            if (item.read_data.size() > 0 && item.read_data[0] == 8'h62) begin
                `uvm_info("SCOREBOARD", "SUKCES! Odczytano poprawne ID producenta (62h)!", UVM_NONE)
            end else begin
                bit [7:0] actual_val = (item.read_data.size() > 0) ? item.read_data[0] : 8'h00;
                `uvm_error("SCOREBOARD", $sformatf("BLAD! CMD: 9Fh. Oczekiwano 62h, otrzymano %0h", actual_val))
            end
        end
        
         
        else if (item.command == WRITE_COMMAND) begin
            
            foreach (item.data[i]) begin
                bit [23:0] current_addr = item.address + i;
                shadow_mem[current_addr] = item.data[i]; 
            end
            
            `uvm_info("SCOREBOARD", $sformatf("Zaktualizowano model: ADDR BAZOWY=%0h, zapiętano %0d bajtów.", item.address, item.data.size()), UVM_LOW)
        end
        
        
        else if (item.command == READ_COMMAND) begin
            bit error_found = 0;
            
            
            foreach (item.read_data[i]) begin
                bit [7:0] expected_data;
                bit [23:0] current_addr = item.address + i;
                
                
                if (shadow_mem.exists(current_addr)) begin
                    expected_data = shadow_mem[current_addr];
                end else begin
                    expected_data = 8'hFF; 
                end

                
                if (item.read_data[i] !== expected_data) begin
                    `uvm_error("SCOREBOARD", $sformatf("BLAD! Adres: %0h. Oczekiwano %0h, otrzymano %0h", current_addr, expected_data, item.read_data[i]))
                    error_found = 1;
                end
            end
            
            
            if (!error_found) begin
                `uvm_info("SCOREBOARD", $sformatf("SUKCES! Przeczytano poprawnie paczke %0d bajtów od adresu bazowego: %0h", item.read_data.size(), item.address), UVM_NONE)
            end
        end

    endfunction
endclass