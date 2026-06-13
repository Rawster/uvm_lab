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
        
        // Złapanie początku transakcji
        if (vif.valid === 1'b1) begin
            item = mem_seq_item::type_id::create("item");
            item.command = vif.cmd_data;
            item.address = vif.address_data;
            item.data    = vif.write_data;

            
            while (vif.ready === 1'b1) @(posedge vif.clk);
            
            
            while (vif.ready === 1'b0) @(posedge vif.clk);

            
            item.read_data = vif.read_data;

            if (item.command != 8'h05) begin
                `uvm_info("MONITOR", $sformatf("Zlapano: CMD=%0h, READ=%0h", item.command, item.read_data), UVM_LOW)
            end

            
            item_collected_port.write(item);
        end
    end
endtask
endclass