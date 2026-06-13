class base_env extends uvm_env;
  `uvm_component_utils(base_env)

  agent m_agent; 
  scoreboard m_scoreboard;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    m_agent = agent::type_id::create("m_agent", this);
    m_scoreboard = scoreboard::type_id::create("m_scoreboard", this);
  endfunction


  virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        
        
        m_agent.m_monitor.item_collected_port.connect(m_scoreboard.item_collected_export);
    endfunction

endclass