class base_sequence extends uvm_sequence#(mem_seq_item);
    `uvm_object_utils(base_sequence)

    bit [7:0] shadow_mem [bit [23:0]];
    bit [23:0] known_addrs[$];

    // Enum długości sekwencji
    typedef enum {SINGLE, SHORT, MEDIUM, LONG, MAX} seq_len_e;
    rand seq_len_e seq_length;
    
    rand int num_of_transactions;

    constraint c_seq_len_dist {
        seq_length dist {
            SHORT  := 40,
            MEDIUM := 30,
            LONG   := 20,
            SINGLE := 5,
            MAX    := 5
        };
    }

    constraint c_num_trans {
        (seq_length == SINGLE) -> num_of_transactions == 2; 
        (seq_length == SHORT)  -> num_of_transactions inside {[3:10]};
        (seq_length == MEDIUM) -> num_of_transactions inside {[11:30]};
        (seq_length == LONG)   -> num_of_transactions inside {[31:80]};
        (seq_length == MAX)    -> num_of_transactions inside {[81:150]};
    }

    function new(string name = "base_sequence"); 
        super.new(name); 
    endfunction

    task body();
        int write_cnt = 0;
        int read_cnt = 0;

        `uvm_info("SEQ", $sformatf("Rozpoczynam sekwencje typu: %0s. Ilość transakcji: %0d", seq_length.name(), num_of_transactions), UVM_LOW)

        #100;

        for (int i = 0; i < num_of_transactions; i++) begin
            bit is_write;
            bit [23:0] current_addr; 
            
            req = mem_seq_item::type_id::create("req");
            
            if (known_addrs.size() == 0) begin
                is_write = 1; 
            end else if (i == num_of_transactions - 1 && read_cnt == 0) begin
                is_write = 0; 
            end else begin
                is_write = $urandom_range(0, 1); 
            end

            if (is_write) write_cnt++;
            else read_cnt++;

            start_item(req);

                if (is_write) begin
                
                if (!req.randomize() with { 
                    command == 8'h02; 
                    
                    
                    address <= (32'h040000 - burst_len);
                    
                    
                    burst_len <= (256 - address[7:0]);
                    
                    !(address inside {known_addrs}); 
                }) begin
                    `uvm_error("SEQ", "Błąd randomizacji dla komendy WRITE")
                end
                
                
                foreach (req.data[idx]) begin
                    current_addr = req.address + idx;
                    shadow_mem[current_addr] = req.data[idx];
                    
                    if (!(current_addr inside {known_addrs})) begin
                        known_addrs.push_back(current_addr);
                    end
                end
                
                `uvm_info("SEQ", $sformatf("[%0d] Wysłano WRITE BURST -> ADDR: %0h, ILOSC BAJTOW: %0d", i, req.address, req.data.size()), UVM_HIGH)
            end else begin
                // --- SEKWENCJA READ (BURST) ---
                bit [23:0] target_addr;

                if (known_addrs.size() > 0 && $urandom_range(0, 1) == 1) begin
                    target_addr = known_addrs[$urandom_range(0, known_addrs.size() - 1)];
                end else begin
                    target_addr = $urandom_range(0, 24'h03FFFF); 
                end

                if (!req.randomize() with { 
                    command == 8'h03; 
                    address == target_addr; 
                    
                    
                    address <= (32'h040000 - burst_len);
                }) begin
                    `uvm_error("SEQ", "Błąd randomizacji dla komendy READ")
                end
                
                `uvm_info("SEQ", $sformatf("[%0d] Wysłano READ BURST  -> ADDR: %0h, ILOSC BAJTOW: %0d", i, req.address, req.burst_len), UVM_HIGH)
            end

            finish_item(req); 
        end

        `uvm_info("SEQ", $sformatf("Zakończono nadawanie! Wykonano: WRITE = %0d, READ = %0d.", write_cnt, read_cnt), UVM_LOW)
    endtask
endclass