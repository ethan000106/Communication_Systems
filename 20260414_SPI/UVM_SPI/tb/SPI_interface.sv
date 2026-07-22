interface SPI_if (
    input logic clk,
    input logic rst
);
    logic [15:0] sw;
    logic        btn_start;
    logic [ 3:0] fnd_digit;
    logic [ 7:0] fnd_data;

    clocking drv_cb @(posedge clk);
        default input #1step output #0;

        output sw;
        output btn_start;
        input fnd_digit;
        input fnd_data;

    endclocking

    clocking mon_cb @(posedge clk);
        default input #1step;

        input sw;
        input btn_start;
        input fnd_digit;
        input fnd_data;

    endclocking

    modport mp_drv(clocking drv_cb, input clk, input rst);
    modport mp_mon(clocking mon_cb, input clk, input rst);


endinterface  //SPI_if
