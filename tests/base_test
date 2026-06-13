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

        // Podniesienie sprzeciwu (objection), aby symulacja się nie zakończyła
        phase.raise_objection(this);

        // Utworzenie sekwencji
        seq = base_sequence::type_id::create("seq");

        // --- TO JEST BRAKUJĄCY KROK ---
        // Losowanie parametrów sekwencji (w tym num_of_transactions)
        if (!seq.randomize()) begin
            `uvm_fatal("TEST", "Błąd randomizacji sekwencji bazowej!")
        end
        // ------------------------------

        // Uruchomienie sekwencji na sequencerze
        seq.start(m_env.m_agent.m_sequencer);

        // Opuszczenie sprzeciwu po zakończeniu sekwencji
        phase.drop_objection(this);
    endtask
endclass