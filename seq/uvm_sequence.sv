class base_sequence extends uvm_sequence#(mem_seq_item);
    `uvm_object_utils(base_sequence)

    
    bit [7:0] shadow_mem [bit [23:0]];
    
    
    bit [23:0] known_addrs[$];

    
    rand int num_of_transactions;

    constraint c_num_trans {
        num_of_transactions inside {[2:10]}; 
    }

    function new(string name = "base_sequence"); 
        super.new(name); 
    endfunction

   
    function bit [7:0] get_expected_data(bit [23:0] addr);
        if (shadow_mem.exists(addr)) begin
            return shadow_mem[addr];
        end else begin
            return 8'hFF; 
        end
    endfunction

    task body();
        `uvm_info("SEQ", $sformatf("Rozpoczynam sekwencję po czyszczeniu pamięci. Ilość transakcji: %0d", num_of_transactions), UVM_LOW)

        #100;

        for (int i = 0; i < num_of_transactions; i++) begin
            bit is_write;
            
            req = mem_seq_item::type_id::create("req");
            is_write = $urandom_range(0, 1); 

            start_item(req);

                if (is_write) begin
                // --- SEKWENCJA WRITE ---
                if (!req.randomize() with { 
                    command == 8'h02; 
                    address <= 24'h03FFFF; 
                    
                    // --- ZABEZPIECZENIE PRZED POWTÓRKAMI ---
                    !(address inside {known_addrs}); 
                    
                }) begin
                    `uvm_error("SEQ", "Błąd randomizacji dla komendy WRITE")
                end
                
                shadow_mem[req.address] = req.data;
                
                
                if (!(req.address inside {known_addrs})) begin
                    known_addrs.push_back(req.address);
                end
                
                `uvm_info("SEQ", $sformatf("[%0d] Wysłano WRITE -> ADDR: %0h, DATA: %0h", 
                                           i, req.address, req.data), UVM_MEDIUM)
            end else begin
                
                bit [23:0] target_addr;

                if (known_addrs.size() > 0 && $urandom_range(0, 1) == 1) begin
                    target_addr = known_addrs[$urandom_range(0, known_addrs.size() - 1)];
                end else begin
                    
                    target_addr = $urandom_range(0, 24'h03FFFF); 
                end

                if (!req.randomize() with { 
                    command == 8'h03; 
                    address == target_addr; 
                }) begin
                    `uvm_error("SEQ", "Błąd randomizacji dla komendy READ")
                end
                
                `uvm_info("SEQ", $sformatf("[%0d] Wysłano READ  -> ADDR: %0h (Spodziewane DATA: %0h)", 
                                           i, req.address, get_expected_data(req.address)), UVM_MEDIUM)
            end

            finish_item(req); 
        end

        `uvm_info("SEQ", "Zakończono nadawanie sekwencji.", UVM_LOW)
    endtask
endclass