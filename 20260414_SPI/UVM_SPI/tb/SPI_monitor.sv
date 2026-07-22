`ifndef SPI_MONITOR_SV
`define SPI_MONITOR_SV

`timescale 1ns / 1ps
`include "uvm_macros.svh"
import uvm_pkg::*;
`include "SPI_seq_item.sv"

class SPI_monitor extends uvm_monitor;
    `uvm_component_utils(SPI_monitor)

    uvm_analysis_port #(SPI_seq_item) ap;

    virtual SPI_if vif;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction  //new()

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        ap = new("ap", this);
        if (!uvm_config_db#(virtual SPI_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal(
                get_type_name(),
                "monitor에서 config_db 에러 발생! (vif 매핑 실패)");
        end
    endfunction

    virtual task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "SPI Top Board monitoring 시작!!!!!",
                  UVM_MEDIUM)

        forever begin
            collect_transaction();
        end
    endtask

    task collect_transaction();
        SPI_seq_item tx;

        wait (vif.mon_cb.btn_start == 1'b1);
        tx = SPI_seq_item::type_id::create("mon_tx");
        tx.sw = vif.mon_cb.sw;
        tx.btn_start = 1'b1;

        repeat (300) @(vif.mon_cb);

        wait (vif.mon_cb.fnd_digit != 4'b1110);

        wait (vif.mon_cb.fnd_digit == 4'b1110);

        @(vif.mon_cb);

        tx.fnd_data  = vif.mon_cb.fnd_data;
        tx.fnd_digit = vif.mon_cb.fnd_digit;

        `uvm_info(
            get_type_name(),
            "통신 완료 및 정확한 1의 자리 데이터 캡처 성공!",
            UVM_MEDIUM)
        ap.write(tx);
    endtask
    // @(vif.mon_cb);

    // if (vif.mon_cb.btn_start == 1'b1) begin
    //     tx = SPI_seq_item::type_id::create("mon_tx");

    // tx.sw        = vif.mon_cb.sw;
    // tx.btn_start = vif.mon_cb.btn_start;
    //     tx.fnd_digit = vif.mon_cb.fnd_digit;
    //     tx.fnd_data  = vif.mon_cb.fnd_data;

    //     `uvm_info(get_type_name(), 
    //               $sformatf("Monitor Captured : %s", tx.convert2string()), UVM_MEDIUM)

    //     ap.write(tx);
    // end

    // endtask
endclass

`endif
