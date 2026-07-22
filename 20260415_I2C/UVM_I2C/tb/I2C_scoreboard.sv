`ifndef I2C_SCOREBOARD_SV
`define I2C_SCOREBOARD_SV

`timescale 1ns / 1ps
`include "uvm_macros.svh"
import uvm_pkg::*;

class I2C_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(I2C_scoreboard)

    uvm_analysis_imp #(I2C_seq_item, I2C_scoreboard) ap_imp;

    // 카운터 변수
    int                                              num_tx     = 0;
    int                                              num_errors = 0;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction  //new()

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        ap_imp = new("ap_imp", this);
    endfunction

    function void write(I2C_seq_item tx);
        if (tx.btn_start) begin
                num_tx++;
            if (tx.sw[7:0] === tx.actual_data) begin
                `uvm_info("SCB", "PASS! 데이터 일치", UVM_LOW)
            end else begin
                num_errors++;
                `uvm_error(
                    "SCB", $sformatf(
                    "FAIL! 기대:%h, 실제:%h", tx.sw[7:0], tx.actual_data))
            end
        end
    endfunction

    virtual function void report_phase(uvm_phase phase);
        string result = (num_errors == 0 && num_tx > 0) ? "*** PASS ***" : "*** FAIL ***";

        `uvm_info(get_type_name(),
                  "\n=========== Scoreboard Summary ==========", UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("Test Result    : %s", result),
                  UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("Total Transact : %0d", num_tx),
                  UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("Total Errors   : %0d", num_errors
                  ), UVM_LOW)
        `uvm_info(get_type_name(),
                  "=========================================\n", UVM_LOW)
    endfunction

endclass  // I2C_scoreboard

`endif
