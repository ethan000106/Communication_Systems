`timescale 1ns / 1ps

module tb_spi_slave ();

    logic clk, rst, sclk, mosi, miso, cs_n, cpol, cpha;
    logic [7:0] tx_data, rx_data;
    logic done, busy;

    spi_slave dut (.*);

    always #5 clk = ~clk;  // 100MHz


    task spi_set_mode(logic [1:0] mode);
        {cpol, cpha} = mode;
        @(posedge clk);
    endtask

    // task spi_receive_data(logic [7:0] data);
    //     tx_data = data;
    //     wait (!cs_n);
    //     wait (done);
    //     repeat (5) @(posedge clk);
    // endtask


    task spi_receive_data(input logic [7:0] send_val);
        tx_data = send_val;
        @(posedge clk);
        cs_n = 0;
        @(posedge clk);

        for (int i = 0; i < 8; i++) begin
            mosi = send_val[7-i];

            // repeat (5) @(posedge clk);
            repeat (5) @(negedge clk);
            sclk = 1;
            // repeat (5) @(posedge clk);
            repeat (5) @(negedge clk);
            sclk = 0;
        end

        repeat (10) @(posedge clk);
        cs_n = 1;
        @(posedge clk);
    endtask


    initial begin
        clk  = 0;
        rst  = 1;
        sclk = 0;
        mosi = 0;
        cs_n = 1;
        repeat (3) @(posedge clk);
        rst = 0;
        @(posedge clk);
        @(posedge clk);

        spi_set_mode(0);
        spi_receive_data(8'haa);


        spi_set_mode(1);
        spi_receive_data(8'hbb);


        spi_set_mode(2);
        spi_receive_data(8'hcc);


        spi_set_mode(3);
        spi_receive_data(8'hdd);

        @(posedge clk);
        #20;
        $stop;


    end
endmodule
