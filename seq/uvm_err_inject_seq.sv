class err_inject_seq extends base_sequence;
    `uvm_object_utils(err_inject_seq)

    function new(string name = "err_inject_seq"); 
        super.new(name); 
    endfunction

    task body();
        bit [23:0] target_addr = 24'h025000; 

        `uvm_info("SEQ", "Rozpoczynam DIRECT TEST: Error Injection", UVM_LOW)
        #100;

        
        req = mem_seq_item::type_id::create("req");
        start_item(req);

        if (!req.randomize() with { 
            command == WRITE_COMMAND; 
            address == target_addr; 
            burst_len == 4; 
        }) begin
            `uvm_error("SEQ", "Blad randomizacji dla WRITE")
        end
        
        req.error_inject = 1; 
        
        
        foreach (req.data[idx]) begin
            shadow_mem[req.address + idx] = req.data[idx];
            known_addrs.push_back(req.address + idx);
        end
        finish_item(req); 

        
        req = mem_seq_item::type_id::create("req");
        start_item(req);

        if (!req.randomize() with { 
            command == READ_COMMAND; 
            address == target_addr; 
            burst_len == 4;
        }) begin
            `uvm_error("SEQ", "Blad randomizacji dla READ")
        end
        
        req.error_inject = 0; 
        finish_item(req); 

        `uvm_info("SEQ", "Zakonczono Direct Test.", UVM_LOW)
    endtask
endclass