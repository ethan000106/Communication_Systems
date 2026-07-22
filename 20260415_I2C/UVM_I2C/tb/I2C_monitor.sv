`ifndef MONITOR_SV
`define MONITOR_SV

`timescale 1ns / 1ps
`include "uvm_macros.svh"
import uvm_pkg::*;
`include "I2C_seq_item.sv"

class I2C_monitor extends uvm_monitor;
    `uvm_component_utils(I2C_monitor)

    uvm_analysis_port #(I2C_seq_item) ap;
    virtual I2C_if vif;
    logic prev_btn_start = 1'b0;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction  //new()

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        ap = new("ap", this);
        if (!uvm_config_db#(virtual I2C_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal(get_type_name(),
                       "monitor 에서 config_db 에러 발생!!!");
        end
    endfunction

    virtual task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "I2C monitoring 시작!!!!!", UVM_MEDIUM)

        forever begin
            collect_transaction();
        end

    endtask

    task collect_transaction();
        I2C_seq_item tx;
        logic current_btn = vif.mon_cb.btn_start;

        @(vif.mon_cb);
        if (current_btn == 1'b1 && prev_btn_start == 1'b0) begin
            `uvm_info(get_type_name(), "버튼 감지! 통신 대기 중...",
                      UVM_MEDIUM)
            tx = I2C_seq_item::type_id::create("mon_tx");
            tx.sw = vif.mon_cb.sw;

            tx.btn_start = 1'b1;
            tx.sw = vif.mon_cb.sw;

            wait (vif.busy == 1'b1);  // 시작 대기
            wait (vif.busy == 1'b0);  // 종료 대기
            repeat (2) @(vif.mon_cb);  // Settling 타임


            tx.actual_data = vif.slave_rx_data_probe;
            `uvm_info(get_type_name(),
                      $sformatf("Mon 캡처: sw=0x%02h, actual=0x%02h",
                                tx.sw[7:0], tx.actual_data), UVM_LOW)
            ap.write(tx);
        end
        prev_btn_start = current_btn;
        @(vif.mon_cb);
    endtask  //collect_transaction
endclass  //component 



`endif




