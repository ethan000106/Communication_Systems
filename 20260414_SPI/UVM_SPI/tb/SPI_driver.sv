`ifndef SPI_DRIVER_SV
`define SPI_DRIVER_SV

`timescale 1ns / 1ps
`include "uvm_macros.svh"
import uvm_pkg::*;
`include "SPI_seq_item.sv"

class SPI_driver extends uvm_driver #(SPI_seq_item);
    `uvm_component_utils(SPI_driver)

    virtual SPI_if vif;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction  //new()

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual SPI_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal(get_type_name(),
                       "driver에서 config_db 에러 발생!");
        end
    endfunction

    virtual task run_phase(uvm_phase phase);
        spi_bus_init();

        wait (vif.rst == 1'b0);
        `uvm_info(get_type_name(),
                  "리셋 해제 확인, transaction 대기 중 ...",
                  UVM_MEDIUM)

        forever begin
            SPI_seq_item tx;
            seq_item_port.get_next_item(
                tx);  // 시퀀서로부터 트랜잭션 수신

            drive_pins(tx);  // 물리 핀 구동

            seq_item_port.item_done();  // 구동 완료 보고
        end
    endtask

    task spi_bus_init();
        vif.drv_cb.sw        <= 16'd0;
        vif.drv_cb.btn_start <= 1'b0;
    endtask  //spi_bus_init

    task drive_pins(SPI_seq_item tx);

        @(vif.drv_cb);
        vif.drv_cb.sw        <= tx.sw;
        vif.drv_cb.btn_start <= 1'b1;

        @(vif.drv_cb);
        vif.drv_cb.btn_start <= 1'b0;
        repeat (600) @(vif.drv_cb);

        `uvm_info(get_type_name(), $sformatf("Driver 완료! : %s",
                                             tx.convert2string()), UVM_MEDIUM)


    endtask  //drive_pins

endclass  // SPI_driver 

`endif
