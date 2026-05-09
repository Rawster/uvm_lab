class mem_seq_item extends uvm_sequence_item;

rand bit [7:0]  command;
rand bit [23:0] address;
rand bit [7:0]  data;
     bit [7:0]  read_data;

`uvm_object_utils_begin(mem_seq_item)
    `uvm_field_int(address,UVM_ALL_ON)
    `uvm_field_int(command,UVM_ALL_ON)
    `uvm_field_int(data,UVM_ALL_ON)
    `uvm_field_int(read_data,UVM_ALL_ON)
`uvm_object_utils_end

function new(string name = "mem_seq_item");
    super.new(name);
    
endfunction

endclass

