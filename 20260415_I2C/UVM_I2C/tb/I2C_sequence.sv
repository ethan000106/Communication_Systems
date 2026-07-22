`ifndef I2C_SEQUENCE_SV
`define I2C_SEQUENCE_SV

`timescale 1ns / 1ps
`include "uvm_macros.svh"
import uvm_pkg::*;
`include "I2C_seq_item.sv"


class I2C_base_seq extends uvm_sequence #(I2C_seq_item);
    `uvm_object_utils(I2C_base_seq)
    int num_loop = 0;

    function new(string name = "I2C_base_seq");
        super.new(name);
    endfunction
    
    task trigger_sw(bit [7:0] sw_val);
        I2C_seq_item item = I2C_seq_item::type_id::create("item");
        start_item(item);

        if (!item.randomize() with {
                sw == sw_val;
                btn_start == 1'b1; 
            })
            `uvm_fatal(get_type_name(), "trigger_sw() Randomize() fail!!!")

        `uvm_info(get_type_name(),
                  $sformatf("스위치 데이터 전송: sw = 8'h%02x", sw_val),
                  UVM_MEDIUM)

        finish_item(item);
    endtask



    virtual task body();

    endtask  //body




endclass  //component 


class I2C_directed_seq extends I2C_base_seq;
    `uvm_object_utils(I2C_directed_seq)

    function new(string name = "I2C_directed_seq");
        super.new(name);
    endfunction

    virtual task body();
        `uvm_info(get_type_name(), "Directed Sequence 시작...", UVM_LOW)

        trigger_sw(8'h00);  // 1. 모든 스위치 Off
        trigger_sw(8'hFF);  // 2. 모든 스위치 On
        trigger_sw(8'h55);  // 3. 0101 패턴
        trigger_sw(8'hAA);  // 4. 1010 패턴

        `uvm_info(get_type_name(), "Directed Sequence 종료", UVM_LOW)
    endtask
endclass



class I2C_rand_seq extends I2C_base_seq;
    `uvm_object_utils(I2C_rand_seq)

    function new(string name = "I2C_rand_seq");
        super.new(name);
    endfunction

    virtual task body();
        `uvm_info(get_type_name(), "Random Sequence 시작...", UVM_LOW)

        for (int i = 0; i < num_loop; i++) begin
            I2C_seq_item item = I2C_seq_item::type_id::create("item");
            start_item(item);

            if (!item.randomize() with {
                    btn_start dist {
                        1'b1 := 80,
                        1'b0 := 20
                    };
                })
                `uvm_fatal(get_type_name(), "Randomize() Fail!!!!!")

            `uvm_info(get_type_name(), $sformatf(
                      "[%0d/%0d] Random Item 전송: sw=16'h%04x, btn=%b",
                      i + 1,
                      num_loop,
                      item.sw,
                      item.btn_start
                      ), UVM_HIGH)

            finish_item(item);
        end

        `uvm_info(get_type_name(), "Random Sequence 종료", UVM_LOW)
    endtask
endclass


`endif




