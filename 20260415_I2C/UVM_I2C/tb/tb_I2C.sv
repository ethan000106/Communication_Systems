`timescale 1ns / 1ps
`include "uvm_macros.svh"
import uvm_pkg::*;



`include "I2C_interface.sv"
`include "I2C_seq_item.sv"
`include "I2C_sequence.sv"
`include "I2C_driver.sv"
`include "I2C_monitor.sv"
`include "I2C_agent.sv"
`include "I2C_scoreboard.sv"
`include "I2C_coverage.sv"
`include "I2C_env.sv"
`include "I2C_test.sv"



module tb_I2C ();

    logic clk;
    logic rst;
    // tri1  sda;

    initial clk = 0;
    always #5 clk = ~clk;

    I2C_if vif (
        clk,
        rst
        // sda
    );


    i2c_demo_top dut (
        .clk(clk),
        .rst(rst),
        .sw(vif.sw),
        .scl(vif.scl),
        .busy(vif.busy),
        .btn_start(vif.btn_start),
        .fnd_data(vif.fnd_data),
        .fnd_digit(vif.fnd_digit),
        .sda(vif.sda)
    );

    assign vif.slave_rx_data_probe = dut.u_I2C_SLAVE.rx_data;

    initial begin
        clk = 0;
        rst = 1;
        repeat (5) @(posedge clk);
        rst = 0;
    end

    initial begin
        uvm_config_db#(virtual I2C_if)::set(null, "*", "vif", vif);
        run_test();
    end

    initial begin
        $fsdbDumpfile("novas.fsdb");
        $fsdbDumpvars(0, tb_I2C, "+all");
    end





endmodule
