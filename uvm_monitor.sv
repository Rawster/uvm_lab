class monitor extends uvm_monitor;
  `uvm_component_utils(monitor)

  virtual controller_if vif;
  
  uvm_analysis_port #(mem_seq_item) item_collected_port;

  function new(string name = "monitor", uvm_component parent = null);
    super.new(name, parent);
    item_collected_port = new("item_collected_port", this);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual controller_if)::get(this, "", "vif", vif)) begin
      `uvm_fatal("MON", "Nie udalo sie pobrac interfejsu vif!")
    end
  endfunction

  virtual task run_phase(uvm_phase phase);
    mem_seq_item item;

    forever begin
        @(posedge vif.clk);
        
        
        if (vif.valid === 1'b1) begin
            item = mem_seq_item::type_id::create("item");
            item.command   = vif.cmd_data;
            item.address   = vif.address_data;
            item.burst_len = vif.burst_len + 1; 

            
            if (item.command == WRITE_COMMAND) begin
                item.data = new[item.burst_len];
                foreach (item.data[i]) begin
                    item.data[i] = vif.write_data_arr[i];
                end
            end

            
            while (vif.ready === 1'b1) @(posedge vif.clk);
            while (vif.ready === 1'b0) @(posedge vif.clk);

            
            if (item.command == READ_COMMAND) begin
                item.read_data = new[item.burst_len]; 
                foreach(item.read_data[i]) begin
                    item.read_data[i] = vif.read_data_arr[i]; 
                end
            end else begin
               
                item.read_data = new[1];
                item.read_data[0] = vif.read_data_arr[0];
            end

            
            if (item.command != READ_REGISTER_COMMAND) begin
                `uvm_info("MONITOR", $sformatf("Zlapano transakcje: CMD=%0h, ADDR=%0h, BURST=%0d", item.command, item.address, item.burst_len), UVM_LOW)
            end

            item_collected_port.write(item);
        end
    end
  endtask
endclass