`ifndef SPI_SEQUENCE_SV
`define SPI_SEQUENCE_SV

`timescale 1ns / 1ps
`include "uvm_macros.svh"
import uvm_pkg::*;
`include "SPI_seq_item.sv"

// 1. 공통 Base Sequence
class spi_base_seq extends uvm_sequence #(SPI_seq_item);
    `uvm_object_utils(spi_base_seq)

    int num_loop = 10;

    function new(string name = "spi_base_seq");
        super.new(name);
    endfunction  //new()

    virtual task body();
    endtask
endclass  // spi_base_seq

class spi_rand_seq extends spi_base_seq;
    `uvm_object_utils(spi_rand_seq)

    function new(string name = "spi_rand_seq");
        super.new(name);
    endfunction  //new()

    virtual task body();
        `uvm_info(get_type_name(), "SPI Random Sequence Start", UVM_LOW)

        repeat (num_loop) begin
            SPI_seq_item item = SPI_seq_item::type_id::create("item");

            start_item(item);
            if (!item.randomize()) begin
                `uvm_fatal(get_type_name(), "Randomize() Fail!!!!!")
            end
            finish_item(item);
        end

        `uvm_info(get_type_name(), "SPI Random Sequence End", UVM_LOW)
    endtask  //body
endclass  // spi_rand_seq

class spi_directed_seq extends spi_base_seq;
    `uvm_object_utils(spi_directed_seq)

    rand
    logic [15:0]
    target_sw_val; // 시퀀스를 호출할 때 외부에서 값을 줄 수 있음

    function new(string name = "spi_directed_seq");
        super.new(name);
    endfunction  //new()

    virtual task body();
        SPI_seq_item item = SPI_seq_item::type_id::create("item");

        start_item(item);
        if (!item.randomize() with {
                sw == target_sw_val;
                btn_start == 1'b1;  // 버튼 클릭 상태 강제
            }) begin
            `uvm_fatal(get_type_name(), "Directed Randomize() Fail!!!!!")
        end
        finish_item(item);
    endtask  //body
endclass  // spi_directed_seq

`endif
