`ifndef SPI_TEST_SV
`define SPI_TEST_SV

`timescale 1ns / 1ps
`include "uvm_macros.svh"
import uvm_pkg::*;

class spi_base_test extends uvm_test;
    `uvm_component_utils(spi_base_test)

    SPI_env env;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction  //new()

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = SPI_env::type_id::create("env", this);
    endfunction

    virtual function void end_of_elaboration_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "===== UVM 계층 구조 (Topology) =====",
                  UVM_MEDIUM)
        uvm_top.print_topology();
    endfunction

    virtual task run_phase(uvm_phase phase);
    endtask
endclass  // spi_base_test 

class spi_rand_test extends spi_base_test;
    `uvm_component_utils(spi_rand_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction  //new()

    virtual task run_phase(uvm_phase phase);
        spi_rand_seq seq;

        phase.raise_objection(this);

        seq = spi_rand_seq::type_id::create("seq");
        seq.num_loop = 1024;  // 테스트 반복 

        seq.start(env.agt.sqr);

        #100ns;

        phase.drop_objection(this);
    endtask
endclass  // spi_rand_test

class spi_directed_test extends spi_base_test;
    `uvm_component_utils(spi_directed_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction  //new()

    virtual task run_phase(uvm_phase phase);
        spi_directed_seq seq;

        phase.raise_objection(this);

        seq = spi_directed_seq::type_id::create("seq");

        if (!seq.randomize() with {target_sw_val == 8'h16;}) begin
            `uvm_error(get_type_name(),
                       "Test에서 시퀀스 변수 할당 실패!")
        end

        seq.start(env.agt.sqr);

        #100ns;
        phase.drop_objection(this);
    endtask
endclass  // spi_directed_test

`endif
