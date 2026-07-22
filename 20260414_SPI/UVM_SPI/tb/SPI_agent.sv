`ifndef AGENT_SV
`define AGENT_SV

`timescale 1ns / 1ps
`include "uvm_macros.svh"
import uvm_pkg::*;
`include "SPI_seq_item.sv"
`include "SPI_driver.sv"    
`include "SPI_monitor.sv"   

typedef uvm_sequencer#(SPI_seq_item) SPI_sequencer;

class SPI_agent extends uvm_agent;
    `uvm_component_utils(SPI_agent)

    SPI_driver drv;
    SPI_monitor mon;
    SPI_sequencer sqr;


    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction  //new()

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        drv = SPI_driver::type_id::create("drv", this);
        mon = SPI_monitor::type_id::create("mon", this);
        sqr = SPI_sequencer::type_id::create("sqr", this);
    endfunction


    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        drv.seq_item_port.connect(sqr.seq_item_export);
    endfunction



endclass  //component 



`endif




