class busy_check_test extends base_test;
    `uvm_component_utils(busy_check_test) 

    function new(string name = "busy_check_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        busy_check_seq check_seq;

        phase.raise_objection(this);
        
        check_seq = busy_check_seq::type_id::create("check_seq");
        check_seq.start(m_env.m_agent.m_sequencer);
        
        phase.drop_objection(this);
    endtask
endclass