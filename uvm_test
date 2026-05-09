class base_test extends uvm_test;
  `uvm_component_utils(base_test)

  base_env m_env;

  function new(string name = "base_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    m_env = base_env::type_id::create("m_env", this);
  endfunction

  virtual task run_phase(uvm_phase phase);
    
    base_sequence seq;
    seq = base_sequence::type_id::create("seq");

    phase.raise_objection(this); 
    
   
    seq.start(m_env.m_agent.m_sequencer);
    
    phase.drop_objection(this); 
  endtask
endclass