`ifndef SPI_SCOREBOARD_SV
`define SPI_SCOREBOARD_SV

`timescale 1ns / 1ps
`include "uvm_macros.svh"
import uvm_pkg::*;
`include "SPI_seq_item.sv"

class SPI_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(SPI_scoreboard)

    uvm_analysis_imp #(SPI_seq_item, SPI_scoreboard) ap_imp;

    int num_matches = 0;
    int num_errors = 0;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction  //new()

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        ap_imp = new("ap_imp", this);
    endfunction

    function logic [7:0] get_expected_fnd(logic [3:0] hex_val);
        case (hex_val)
            4'h0: return 8'hC0;
            4'h1: return 8'hF9;
            4'h2: return 8'hA4;
            4'h3: return 8'hB0;
            4'h4: return 8'h99;
            4'h5: return 8'h92;
            4'h6: return 8'h82;
            4'h7: return 8'hF8;
            4'h8: return 8'h80;
            4'h9: return 8'h90;
            4'hA: return 8'h88;
            4'hB: return 8'h83;
            4'hC: return 8'hC6;
            4'hD: return 8'hA1;
            4'hE: return 8'h86;
            4'hF: return 8'h8E;
            default: return 8'hFF;
        endcase
    endfunction

    function void write(SPI_seq_item tx);
        logic [7:0] expected_data;

        expected_data = get_expected_fnd(tx.sw[3:0]);

        if (expected_data !== tx.fnd_data) begin
            num_errors++;
            `uvm_error(
                get_type_name(),
                $sformatf(
                    "FAIL! sw = 8'h%02h | Expected FND = 8'h%02h, Actual FND = 8'h%02h",
                    tx.sw, expected_data, tx.fnd_data))
        end else begin
            num_matches++;
            `uvm_info(
                get_type_name(), $sformatf(
                "PASS! sw = 8'h%02h | Output FND = 8'h%02h", tx.sw, tx.fnd_data
                ), UVM_MEDIUM)
        end
    endfunction

    virtual function void report_phase(uvm_phase phase);
        string result = (num_errors == 0) ? "*** PASS ***" : "*** FAIL ***";
        `uvm_info(get_type_name(), "\n*********** Summary Report **********\n",
                  UVM_MEDIUM)
        `uvm_info(get_type_name(), $sformatf("Result : %s", result), UVM_MEDIUM)
        `uvm_info(get_type_name(), $sformatf("Match num : %0d", num_matches),
                  UVM_MEDIUM)
        `uvm_info(get_type_name(), $sformatf("Error num : %0d", num_errors),
                  UVM_MEDIUM)
        `uvm_info(get_type_name(), "***************************", UVM_MEDIUM)
    endfunction

endclass  // SPI_scoreboard 

`endif
