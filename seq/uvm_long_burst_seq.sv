class long_burst_seq extends base_sequence;
    `uvm_object_utils(long_burst_seq)

    function new(string name = "long_burst_seq"); 
        super.new(name); 
    endfunction

    task body();
        bit [23:0] target_addr = 24'h010000; 
        int max_page_size = 256;             

        `uvm_info("SEQ", "Rozpoczynam DIRECT TEST: Long Write & Read (256 bajtów)", UVM_LOW)

        #100;

        
        req = mem_seq_item::type_id::create("req");
        start_item(req);

        
        if (!req.randomize() with { 
            command == 8'h02; 
            address == target_addr; 
            burst_len == max_page_size;
        }) begin
            `uvm_error("SEQ", "Błąd randomizacji dla DIRECT WRITE")
        end
        
        
        foreach (req.data[idx]) begin
            bit [23:0] current_addr = req.address + idx;
            shadow_mem[current_addr] = req.data[idx];
            known_addrs.push_back(current_addr);
        end
        
        `uvm_info("SEQ", $sformatf("DIRECT WRITE: Wysyłanie paczki %0d bajtów pod adres %0h", req.data.size(), req.address), UVM_NONE)
        finish_item(req); 

        
        req = mem_seq_item::type_id::create("req");
        start_item(req);

        if (!req.randomize() with { 
            command == 8'h03; 
            address == target_addr; 
            burst_len == max_page_size;
        }) begin
            `uvm_error("SEQ", "Błąd randomizacji dla DIRECT READ")
        end
        
        `uvm_info("SEQ", $sformatf("DIRECT READ: Żądanie odczytu %0d bajtów z adresu %0h", req.burst_len, req.address), UVM_NONE)
        finish_item(req); 

        `uvm_info("SEQ", "Zakończono Direct Test!", UVM_LOW)
    endtask
endclass