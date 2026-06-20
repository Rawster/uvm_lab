class busy_polling_seq extends base_sequence;
    `uvm_object_utils(busy_polling_seq)

    function new(string name = "busy_polling_seq"); 
        super.new(name); 
    endfunction

    task body();
        bit [23:0] target_addr = 24'h031234; 
        int test_burst_len = 16;             

        `uvm_info("SEQ", "Rozpoczynam DIRECT TEST: Write & Readback with BUSY Polling", UVM_LOW)
        #100;

        
        req = mem_seq_item::type_id::create("req");
        start_item(req);

        if (!req.randomize() with { 
            command == 8'h02; 
            address == target_addr; 
            burst_len == test_burst_len;
        }) begin
            `uvm_error("SEQ", "Blad randomizacji dla DIRECT WRITE")
        end
        
        
        foreach (req.data[idx]) begin
            shadow_mem[req.address + idx] = req.data[idx];
            known_addrs.push_back(req.address + idx);
        end
        
        `uvm_info("SEQ", "Wysylanie danych do zapisu. Driver rozpocznie Polling...", UVM_NONE)
        finish_item(req); 
        

        
        req = mem_seq_item::type_id::create("req");
        start_item(req);

        if (!req.randomize() with { 
            command == 8'h03; 
            address == target_addr; 
            burst_len == test_burst_len;
        }) begin
            `uvm_error("SEQ", "Blad randomizacji dla DIRECT READ")
        end
        
        `uvm_info("SEQ", "Wysylanie zadania odczytu weryfikującego (Readback)...", UVM_NONE)
        finish_item(req); 

        `uvm_info("SEQ", "Zakonczono Direct Test - Polling zadzialal poprawnie!", UVM_LOW)
    endtask
endclass