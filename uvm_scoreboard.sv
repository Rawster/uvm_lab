class scoreboard extends uvm_scoreboard;
    `uvm_component_utils(scoreboard)

    uvm_analysis_imp #(mem_seq_item, scoreboard) item_collected_export;

    // Model pamięci Scoreboarda
    bit [7:0] shadow_mem [bit [23:0]];

    function new(string name = "scoreboard", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        item_collected_export = new("item_collected_export", this);
    endfunction

    virtual function void write(mem_seq_item item);
        
        // 1. Sprawdzanie ID producenta
        if (item.command == 8'h9F) begin
            if (item.read_data == 8'h62) begin
                `uvm_info("SCOREBOARD", "SUKCES! Odczytano poprawne ID producenta (62h)!", UVM_NONE)
            end else begin
                `uvm_error("SCOREBOARD", $sformatf("BLAD! CMD: 9Fh. Oczekiwano 62h, otrzymano %0h", item.read_data))
            end
        end
        
        // 2. Operacja ZAPISU - aktualizacja modelu 
        else if (item.command == 8'h02) begin
            shadow_mem[item.address] = item.data; 
            // UVM_LOW, abyś widział dokładnie ten sam zapis w konsoli
            `uvm_info("SCOREBOARD", $sformatf("Zaktualizowano model: ADDR=%0h, zapamiętano DATA=%0h", item.address, item.data), UVM_LOW)
        end
        
        // 3. Operacja ODCZYTU - weryfikacja z modelem
        else if (item.command == 8'h03) begin
            bit [7:0] expected_data;
            
            if (shadow_mem.exists(item.address)) begin
                expected_data = shadow_mem[item.address];
            end else begin
                expected_data = 8'hFF; 
            end

            if (item.read_data == expected_data) begin
                `uvm_info("SCOREBOARD", $sformatf("SUKCES! Adres: %0h, Odczytano poprawne DATA: %0h", item.address, item.read_data), UVM_NONE)
            end else begin
                `uvm_error("SCOREBOARD", $sformatf("BLAD! Adres: %0h. Oczekiwano %0h, otrzymano %0h", item.address, expected_data, item.read_data))
            end
        end

    endfunction
endclass