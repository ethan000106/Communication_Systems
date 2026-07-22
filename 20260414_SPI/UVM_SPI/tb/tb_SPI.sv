`timescale 1ns / 1ps
`include "uvm_macros.svh"
import uvm_pkg::*;



`include "SPI_interface.sv"
`include "SPI_seq_item.sv"
`include "SPI_sequence.sv"
`include "SPI_driver.sv"
`include "SPI_monitor.sv"
`include "SPI_agent.sv"
`include "SPI_scoreboard.sv"
`include "SPI_coverage.sv"
`include "SPI_env.sv"
`include "SPI_test.sv"



module tb_SPI ();

    logic clk;
    logic rst;

    initial clk = 0;
    always #5 clk = ~clk;

    SPI_if vif (
        clk,
        rst
    );


    spi_top dut (
        .clk(clk),
        .rst(rst),
        .sw(vif.sw),
        .btn_start(vif.btn_start),
        .fnd_digit(vif.fnd_digit),
        .fnd_data(vif.fnd_data)
    );


    initial begin
        clk = 0;
        rst = 1;
        repeat (5) @(posedge clk);
        rst = 0;
    end

    initial begin
        uvm_config_db#(virtual SPI_if)::set(null, "*", "vif", vif);
        run_test();
    end

    initial begin
        $fsdbDumpfile("novas.fsdb");
        $fsdbDumpvars(0, tb_SPI, "+all");
    end





endmodule
