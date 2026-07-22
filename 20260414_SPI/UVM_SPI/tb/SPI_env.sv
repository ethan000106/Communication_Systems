`ifndef I2C_ENV_SV
`define I2C_ENV_SV

`timescale 1ns / 1ps
`include "uvm_macros.svh"
import uvm_pkg::*;

class SPI_env extends uvm_env;
    `uvm_component_utils(SPI_env)
    
    SPI_agent      agt;
    SPI_scoreboard scb;
    SPI_coverage   cov;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction  //new()

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        agt = SPI_agent::type_id::create("agt", this);
        scb = SPI_scoreboard::type_id::create("scb", this);
        cov = SPI_coverage::type_id::create("cov", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        
        agt.mon.ap.connect(scb.ap_imp);
        agt.mon.ap.connect(cov.analysis_export);
    endfunction

endclass  // component 

`endif