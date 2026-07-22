`ifndef I2C_DRIVER_SV
`define I2C_DRIVER_SV

`timescale 1ns / 1ps
`include "uvm_macros.svh"
import uvm_pkg::*;

class I2C_driver extends uvm_driver #(I2C_seq_item);
    `uvm_component_utils(I2C_driver)

    virtual I2C_if vif;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction  //new()

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual I2C_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal(get_type_name(),
                       "driver 에서 vif config_db 에러 발생!!!")
        end
    endfunction

    virtual task run_phase(uvm_phase phase);
        init_signals();

        wait (vif.rst == 1'b0);
        `uvm_info(get_type_name(),
                  "리셋 해제 확인, transaction 대기 중 ...",
                  UVM_MEDIUM)

        forever begin
            I2C_seq_item tx;
            seq_item_port.get_next_item(tx);

            drive_top(tx);

            seq_item_port.item_done();
        end
    endtask

    task init_signals();
        vif.drv_cb.sw        <= 8'h0;
        vif.drv_cb.btn_start <= 1'b0;
    endtask

    task drive_top(I2C_seq_item tx);
        @(vif.drv_cb);

        vif.drv_cb.sw <= tx.sw;

        if (tx.btn_start) begin
            vif.drv_cb.btn_start <= 1'b1;
            @(vif.drv_cb);
            vif.drv_cb.btn_start <= 1'b0;

        end
        repeat (2) @(vif.drv_cb);
        wait (vif.busy == 1'b0);
        repeat(5) @(vif.drv_cb);

      `uvm_info(get_type_name(), "통신 완료! 다음 트랜잭션 준비.", UVM_MEDIUM)
    endtask

endclass  // I2C_driver

`endif
