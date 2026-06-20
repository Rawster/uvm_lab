class busy_polling_test extends base_test;
    `uvm_component_utils(busy_polling_test) 

    function new(string name = "busy_polling_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        busy_polling_seq polling_seq;

        phase.raise_objection(this);
        
        polling_seq = busy_polling_seq::type_id::create("polling_seq");
        polling_seq.start(m_env.m_agent.m_sequencer);
        
        phase.drop_objection(this);
    endtask
endclass