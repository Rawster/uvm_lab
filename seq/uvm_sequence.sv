class base_sequence extends uvm_sequence#(mem_seq_item);
    `uvm_object_utils(base_sequence)

    localparam int PAGE_SIZE = 256;
    
    localparam int TX_MIN    = 2;
    localparam int TX_SHORT  = 10;
    localparam int TX_MEDIUM = 30;
    localparam int TX_LONG   = 80;
    localparam int TX_MAX    = PAGE_SIZE;

    bit [7:0] shadow_mem [bit [23:0]];
    bit [23:0] known_addrs[$];

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
        (seq_length == SINGLE) -> num_of_transactions == TX_MIN; 
        (seq_length == SHORT)  -> num_of_transactions inside {[3 : TX_SHORT]};
        (seq_length == MEDIUM) -> num_of_transactions inside {[(TX_SHORT+1) : TX_MEDIUM]};
        (seq_length == LONG)   -> num_of_transactions inside {[(TX_MEDIUM+1) : TX_LONG]};
        (seq_length == MAX)    -> num_of_transactions inside {[(TX_LONG+1) : TX_MAX]};
    }

    function new(string name = "base_sequence"); 
        super.new(name); 
    endfunction

    task body();
        int write_cnt = 0;
        int read_cnt = 0;

        `uvm_info("SEQ", $sformatf("Rozpoczynam sekwencje typu: %0s. Ilosc transakcji: %0d", seq_length.name(), num_of_transactions), UVM_LOW)
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
                bit addr_ok;
                bit [23:0] temp_addr;
                int temp_burst;
                
                do begin
                    addr_ok = 1;
                    temp_addr = $urandom_range(0, 24'h03FFFF);
                    temp_burst = $urandom_range(1, 256 - (temp_addr & 24'h0000FF));

                    for (int k = 0; k < temp_burst; k++) begin
                        if ((temp_addr + k) inside {known_addrs}) begin
                            addr_ok = 0;
                            break; 
                        end
                    end
                end while (!addr_ok);
                
                if (!req.randomize() with { 
                    command == WRITE_COMMAND; 
                    address == temp_addr; 
                    burst_len == temp_burst;
                }) begin
                    `uvm_fatal("SEQ", "Krytyczny blad randomizacji dla WRITE!") 
                end
                
                foreach (req.data[idx]) begin
                    current_addr = req.address + idx;
                    shadow_mem[current_addr] = req.data[idx];
                    
                    if (!(current_addr inside {known_addrs})) begin
                        known_addrs.push_back(current_addr);
                    end
                end
                
                `uvm_info("SEQ", $sformatf("[%0d] Wyslano WRITE BURST -> ADDR: %0h, ILOSC BAJTOW: %0d", i, req.address, req.data.size()), UVM_HIGH)
            end else begin
                bit [23:0] target_addr;
                int target_burst;

                if (known_addrs.size() > 0 && $urandom_range(0, 1) == 1) begin
                    target_addr = known_addrs[$urandom_range(0, known_addrs.size() - 1)];
                end else begin
                    target_addr = $urandom_range(0, 24'h03FFFF); 
                end
                
                target_burst = $urandom_range(1, 256 - (target_addr & 24'h0000FF));

                if (!req.randomize() with { 
                    command == READ_COMMAND; 
                    address == target_addr; 
                    burst_len == target_burst;
                }) begin
                    `uvm_fatal("SEQ", "Krytyczny blad randomizacji dla READ")
                end
                
                `uvm_info("SEQ", $sformatf("[%0d] Wyslano READ BURST  -> ADDR: %0h, ILOSC BAJTOW: %0d", i, req.address, req.burst_len), UVM_HIGH)
            end

            finish_item(req); 
        end

        `uvm_info("SEQ", $sformatf("Zakonczono nadawanie! Wykonano: WRITE = %0d, READ = %0d.", write_cnt, read_cnt), UVM_LOW)
    endtask
endclass