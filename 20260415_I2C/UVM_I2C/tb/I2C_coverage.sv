`ifndef COVERAGE_SV
`define COVERAGE_SV

`timescale 1ns / 1ps
`include "uvm_macros.svh"
import uvm_pkg::*;
`include "I2C_seq_item.sv"

class I2C_coverage extends uvm_subscriber #(I2C_seq_item);
    `uvm_component_utils(I2C_coverage)
    I2C_seq_item tx;

    covergroup I2C_cg;
        cp_sw: coverpoint tx.sw {
            bins all_zeros = {8'h00};
            bins all_ones = {8'hFF};
            bins alt_a = {8'hAA};
            bins alt_5 = {8'h55};
            bins range_low = {[8'h01 : 8'hFF]};
            bins range_mid = {[8'h00 : 8'hFF]};
        }

        cp_btn: coverpoint tx.btn_start {bins pressed = {1'b1};}

        cp_fnd_data: coverpoint tx.fnd_data {
            bins all_zeros = {8'h00};
            bins all_ones = {8'hFF};
            bins alt_a = {8'hAA};
            bins alt_5 = {8'h55};
            bins others = default;
        }
        cp_fnd_digit: coverpoint tx.fnd_digit {
            bins digit_active[] = {[0 : 15]};
        }

        cx_sw_fnd : cross cp_sw, cp_fnd_data;

    endgroup

    function new(string name, uvm_component parent);
        super.new(name, parent);
        I2C_cg = new();
    endfunction  //new()

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

    endfunction

    function void write(I2C_seq_item t);
        tx = t;
        I2C_cg.sample();

    endfunction

    virtual function void report_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "===== I2C Coverage Summary =====", UVM_LOW);
        `uvm_info(get_type_name(), $sformatf(
                  "Overall Coverage : %.1f%%", I2C_cg.get_coverage()), UVM_LOW);
        `uvm_info(get_type_name(), $sformatf(
                  "SW Input Cover   : %.1f%%", I2C_cg.cp_sw.get_coverage()),
                  UVM_LOW);
        `uvm_info(get_type_name(), $sformatf(
                  "FND Data Cover   : %.1f%%", I2C_cg.cp_fnd_data.get_coverage()
                  ), UVM_LOW);
        `uvm_info(get_type_name(), $sformatf(
                  "Cross (SW x FND) : %.1f%%", I2C_cg.cx_sw_fnd.get_coverage()),
                  UVM_LOW);
        `uvm_info(get_type_name(), "==================================\n\n",
                  UVM_LOW);
    endfunction


endclass  //component 



`endif




