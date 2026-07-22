interface I2C_if (
    input logic clk,
    input logic rst
    // input tri1 sda
);
    logic [7:0] sw;
    logic       scl;
    logic       btn_start;
    logic [7:0] fnd_data;
    logic [3:0] fnd_digit;
    // wire        sda;
    tri1        sda;
    logic       busy;
    logic [7:0] slave_rx_data_probe;

    clocking drv_cb @(posedge clk);
        default input #1step output #0;

        input fnd_data;
        input fnd_digit;
        input busy;
        output sw;
        output btn_start;
        output scl;
        inout sda;

    endclocking

    clocking mon_cb @(posedge clk);
        default input #1step;

        input sw;
        input scl;
        input btn_start;
        input fnd_data;
        input fnd_digit;
        input busy;
        inout sda;
        input slave_rx_data_probe;



    endclocking

    modport mp_drv(clocking drv_cb, input clk, input rst);
    modport mp_mon(clocking mon_cb, input clk, input rst);


endinterface  //I2C_if
