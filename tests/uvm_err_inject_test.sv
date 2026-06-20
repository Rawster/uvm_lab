class err_inject_test extends base_test;
    `uvm_component_utils(err_inject_test) 

    function new(string name = "err_inject_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        err_inject_seq err_seq;

        phase.raise_objection(this);
        err_seq = err_inject_seq::type_id::create("err_seq");
        err_seq.start(m_env.m_agent.m_sequencer);
        phase.drop_objection(this);
    endtask
endclass