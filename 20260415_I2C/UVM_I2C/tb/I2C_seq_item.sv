`ifndef I2C_SEQ_ITEM_SV
`define I2C_SEQ_ITEM_SV

`timescale 1ns / 1ps
`include "uvm_macros.svh"
import uvm_pkg::*;

class I2C_seq_item extends uvm_sequence_item;

    rand logic [7:0] sw;
    rand logic       btn_start;
    logic      [7:0] fnd_data;
    logic      [3:0] fnd_digit;

logic [ 7:0] actual_data;
    `uvm_object_utils_begin(I2C_seq_item)
        `uvm_field_int(sw, UVM_ALL_ON)
        `uvm_field_int(btn_start, UVM_ALL_ON)
        `uvm_field_int(fnd_data, UVM_ALL_ON)
        `uvm_field_int(fnd_digit, UVM_ALL_ON)
        `uvm_field_int(actual_data, UVM_ALL_ON)
    `uvm_object_utils_end
    //factory 

    function new(string name = "I2C_seq_item");
        super.new(name);
    endfunction  //new()

    virtual function string convert2string();
        return $sformatf(
            "TX: sw = 8'h%02x, btn_start = %b | RX_FND: digit = 4'b%04b, data = 8'h%02x",
            sw,
            btn_start,
            fnd_digit,
            fnd_data
        );
    endfunction


endclass  //component 



`endif




