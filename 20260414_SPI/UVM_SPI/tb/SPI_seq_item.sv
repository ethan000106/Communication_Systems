`ifndef SPI_SEQ_ITEM_SV
`define SPI_SEQ_ITEM_SV

`timescale 1ns / 1ps
`include "uvm_macros.svh"
import uvm_pkg::*;

class SPI_seq_item extends uvm_sequence_item;

    rand logic [15:0] sw;
    rand logic        btn_start;
    logic      [ 3:0] fnd_digit;
    logic      [ 7:0] fnd_data;


    constraint c_sw_data {sw[7:0] inside {[8'h00 : 8'h40]};}

    `uvm_object_utils_begin(SPI_seq_item)
        `uvm_field_int(sw, UVM_ALL_ON)
        `uvm_field_int(btn_start, UVM_ALL_ON)
        `uvm_field_int(fnd_digit, UVM_ALL_ON)
        `uvm_field_int(fnd_data, UVM_ALL_ON)
    `uvm_object_utils_end

    //factory 

    function new(string name = "SPI_seq_item");
        super.new(name);
    endfunction  //new()

    function string convert2string();
        return $sformatf(
            "SPI_TOP_TX: sw = 16'h%04h, btn_start = %b | RX_FND: digit = 4'b%04b, data = 8'h%02h",
            sw,
            btn_start,
            fnd_digit,
            fnd_data
        );

    endfunction


endclass  // spi_seq_item



`endif




