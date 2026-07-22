`ifndef SPI_COVERAGE_SV
`define SPI_COVERAGE_SV

`timescale 1ns / 1ps
`include "uvm_macros.svh"
import uvm_pkg::*;
`include "SPI_seq_item.sv"

class SPI_coverage extends uvm_subscriber #(SPI_seq_item);
    `uvm_component_utils(SPI_coverage)
    SPI_seq_item tx;

    covergroup spi_cg;

        cp_sw_pattern: coverpoint tx.sw {
            bins all_zeros = {8'h00};
            bins all_ones =  {8'hFF};
            bins pattern_a = {8'hAA};
            bins pattern_5 = {8'h55};
            bins other = default;
        }

        cp_sw_nibble: coverpoint tx.sw[3:0] {
            bins num_0_to_9 = {[4'h0 : 4'h9]};
            bins hex_A_to_F = {[4'hA : 4'hF]}; 
        }

        cp_btn: coverpoint tx.btn_start {bins pressed = {1'b1};}

        cx_sw_pattern_nibble : cross cp_sw_pattern, cp_sw_nibble;
    endgroup

    function new(string name, uvm_component parent);
        super.new(name, parent);
        spi_cg = new();
    endfunction  //new()

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
    endfunction

    function void write(SPI_seq_item t);
        tx = t;
        spi_cg.sample();  // Covergroup 샘플링(기록)
    endfunction

    virtual function void report_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "===== Coverage Summary =====", UVM_LOW);
        `uvm_info(get_type_name(), $sformatf(
                  "Overall : %.1f%%", spi_cg.get_coverage()), UVM_LOW);
        `uvm_info(get_type_name(), $sformatf(
                  "SW Pattern : %.1f%%", spi_cg.cp_sw_pattern.get_coverage()),
                  UVM_LOW);
        `uvm_info(get_type_name(), $sformatf(
                  "SW Nibble (0-F) : %.1f%%", spi_cg.cp_sw_nibble.get_coverage()
                  ), UVM_LOW);
        `uvm_info(get_type_name(), $sformatf(
                  "Button : %.1f%%", spi_cg.cp_btn.get_coverage()), UVM_LOW);
        `uvm_info(get_type_name(), "===== Coverage Summary =====\n\n", UVM_LOW);
    endfunction

endclass  // SPI_coverage 

`endif
