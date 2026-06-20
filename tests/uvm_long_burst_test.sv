class long_burst_test extends base_test;
    `uvm_component_utils(long_burst_test) 

    function new(string name = "long_burst_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        long_burst_seq direct_seq;

        phase.raise_objection(this);

        
        direct_seq = long_burst_seq::type_id::create("direct_seq");
        direct_seq.start(m_env.m_agent.m_sequencer);

        phase.drop_objection(this);
    endtask
endclass