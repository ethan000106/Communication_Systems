`timescale 1ns / 1ps


module tb_spi_master ();

    logic       clk;
    logic       rst;
    logic       cpol;
    logic       cpha;
    logic [7:0] clk_div;
    logic [7:0] tx_data_m;
    logic [7:0] tx_data_s;
    logic [7:0] rx_data_m;
    logic [7:0] rx_data_s;
    logic       start;
    logic       done_m;
    logic       done_s;
    logic       busy_m;
    logic       busy_s;
    logic       sclk;
    logic       mosi;
    logic       miso;
    logic       cs_n;
    logic [3:0] fnd_digit;
    logic [7:0] fnd_data;




    spi_master dut_1 (
        .*,
        .done(done_m),
        .busy(busy_m),
        .tx_data(tx_data_m),
        .rx_data(rx_data_m)
    );
    spi_slave dut_2 (
        .*,
        .done(done_s),
        .busy(busy_s),
        .tx_data(tx_data_s),
        .rx_data(rx_data_s)
    );

    fnd_controller dut_3 (
        .fnd_in_data({6'd0, rx_data_s}),  // WDATA
        .clk(clk),
        .reset(rst),
        .fnd_digit(fnd_digit),
        .fnd_data(fnd_data)
    );

    always #5 clk = ~clk;
    assign miso = mosi;



    task spi_set_mode(logic [1:0] mode);
        {cpol, cpha} = mode;
        @(posedge clk);
    endtask  //spi_set_mode



    task spi_master_send_data(logic [7:0] data);

        tx_data_m = data;
        start = 1'b1;
        @(posedge clk);
        start = 1'b0;
        @(posedge clk);
        wait (done_m);
        @(posedge clk);

    endtask  //spi_master_send_data

    task spi_slave_send_data(logic [7:0] data);

        tx_data_s = data;
        wait (!cs_n);
        wait (done_s);
        @(posedge clk);

    endtask



    initial begin
        clk = 0;
        rst = 1;
        repeat (3) @(posedge clk);
        rst = 0;
        @(posedge clk);
        clk_div = 4;  // 10Mhz  :   (10mhz /(10mhz * 2))-1
        @(posedge clk);

        spi_set_mode(0);
        fork
            spi_master_send_data(8'haa);
            spi_slave_send_data(8'hff);
        join



        spi_set_mode(0);
        fork
            spi_master_send_data(8'hbb);
            spi_slave_send_data(8'hee);
        join

        spi_set_mode(0);
        fork
            spi_master_send_data(8'hcc);
            spi_slave_send_data(8'hbb);
        join


        spi_set_mode(0);
        fork
            spi_master_send_data(8'hdd);
            spi_slave_send_data(8'haa);
        join

        @(posedge clk);
        #20;
        $stop;

    end


endmodule
