class env_config extends uvm_object;

    // a. Add fields scoreboard_enable and coverage_enable, default them to 0
    bit scoreboard_enable = 0;
    bit coverage_enable   = 0;

    // b. Add abovementioned fields as uvm_fields using uvm_object_utils macros
    `uvm_object_utils_begin(env_config)
        `uvm_field_int(scoreboard_enable, UVM_DEFAULT)
        `uvm_field_int(coverage_enable,   UVM_DEFAULT)
    `uvm_object_utils_end

    // Konstruktor
    function new(string name = "env_config");
        super.new(name);
    endfunction

endclass