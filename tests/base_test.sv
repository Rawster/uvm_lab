class base_test extends uvm_test;
  `uvm_component_utils(base_test) 

  base_env m_env;
  env_config cfg;

  function new(string name = "base_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    cfg = env_config::type_id::create("cfg");
    m_env = base_env::type_id::create("m_env", this);
  endfunction


  virtual function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);
        
        
        uvm_top.print_topology();
        
        `uvm_info("TEST_CFG", "Wypisywanie ustawien konfiguracji:", UVM_NONE)
        cfg.print();
    endfunction

virtual task run_phase(uvm_phase phase);
        base_sequence seq;

        phase.raise_objection(this);

        seq = base_sequence::type_id::create("seq");

        if (!seq.randomize()) begin
            `uvm_fatal("TEST", "Błąd randomizacji sekwencji bazowej!")
        end
        
        seq.start(m_env.m_agent.m_sequencer);

        phase.drop_objection(this);
    endtask
endclass