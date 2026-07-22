`ifndef I2C_TEST_SV
`define I2C_TEST_SV

`timescale 1ns / 1ps
`include "uvm_macros.svh"
import uvm_pkg::*;

`include "I2C_env.sv"

class I2C_base_test extends uvm_test;
    `uvm_component_utils(I2C_base_test)

    I2C_env env;  // APB 대신 I2C Environment 인스턴스화

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction  //new()

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = I2C_env::type_id::create("env", this);
    endfunction

    virtual function void end_of_elaboration_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "===== I2C UVM 계층 구조 =====",
                  UVM_NONE)
        uvm_top.print_topology();
    endfunction

    virtual task run_phase(uvm_phase phase);
    endtask
endclass  // I2C_base_test


class I2C_directed_test extends I2C_base_test;
    `uvm_component_utils(I2C_directed_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction  //new()

    virtual task run_phase(uvm_phase phase);
        I2C_directed_seq seq;

        phase.raise_objection(this);

        seq = I2C_directed_seq::type_id::create("seq");
        seq.start(env.agt.sqr);  // Agent 내부의 Sequencer에 연결

        #100us;

        phase.drop_objection(this);
    endtask
endclass  // I2C_directed_test


class I2C_rand_test extends I2C_base_test;
    `uvm_component_utils(I2C_rand_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction  //new()

    virtual task run_phase(uvm_phase phase);
        I2C_rand_seq seq;

        phase.raise_objection(this);

        seq = I2C_rand_seq::type_id::create("seq");
        seq.num_loop = 1000;
        seq.start(env.agt.sqr);

        #100us;

        phase.drop_objection(this);
    endtask
endclass  // I2C_rand_test

`endif
