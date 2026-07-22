`ifndef AGENT_SV
`define AGENT_SV

`timescale 1ns / 1ps
`include "uvm_macros.svh"
import uvm_pkg::*;
`include "I2C_seq_item.sv"
`include "I2C_driver.sv"
`include "I2C_monitor.sv"

typedef uvm_sequencer#(I2C_seq_item) I2C_sequencer;

class I2C_agent extends uvm_agent;
    `uvm_component_utils(I2C_agent)

    I2C_driver drv;
    I2C_monitor mon;
    I2C_sequencer sqr;


    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction  //new()
 
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        drv = I2C_driver::type_id::create("drv", this);
        mon = I2C_monitor::type_id::create("mon", this);
        sqr = I2C_sequencer::type_id::create("sqr", this);
    endfunction


    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        drv.seq_item_port.connect(sqr.seq_item_export);
    endfunction



endclass  //component 



`endif




