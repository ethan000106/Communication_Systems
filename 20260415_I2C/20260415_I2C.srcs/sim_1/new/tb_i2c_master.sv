`timescale 1ns / 1ps

module tb_i2c_master ();

    logic       clk;
    logic       rst;
    logic       cmd_start;
    logic       cmd_write;
    logic       cmd_read;
    logic       cmd_stop;
    logic [7:0] tx_data_m;
    logic [7:0] tx_data_s;
    logic       ack_in_m;
    logic       ack_in_s;
    logic [7:0] rx_data_m;
    logic [7:0] rx_data_s;
    logic       done;
    logic       ack_out_m;
    logic       ack_out_s;
    logic       busy;
    logic       scl;
    // wire        sda;
    tri1        sda;


    // assign scl = 1'b1;
    // assign sda = 1'b1;

    localparam SLA = 7'h12;

    I2C_Master dut_1 (
        .*,
        .ack_in(ack_in_m),
        .ack_out(ack_out_m),
        .rx_data(rx_data_m),
        .tx_data(tx_data_m),
        .scl(scl),
        .sda(sda)
    );
    i2c_slave dut_2 (
        .clk(clk),
        .rst(rst),
        .ack_out(ack_out_m),
        .tx_data(tx_data_s),
        .rx_data(rx_data_s),
        .ack_in(ack_in_m),
        .scl(scl),
        .sda(sda)
    );

    always #5 clk = ~clk;


    task i2c_start();
        cmd_start = 1'b1;
        cmd_write = 1'b0;
        cmd_read  = 1'b0;
        cmd_stop  = 1'b0;
        @(negedge clk);
        wait (done);  // done =1 end of start ,  go to wait_cmd
        @(negedge clk);
        cmd_start = 1'b0;
    endtask  //12c_start


    task i2c_addr(byte addr);
        tx_data_m = addr;
        cmd_start = 1'b0;
        cmd_write = 1'b1;
        cmd_read  = 1'b0;
        cmd_stop  = 1'b0;
        @(negedge clk);
        wait (done);  // ack complete
        @(negedge clk);
        cmd_write = 1'b0;
    endtask  //12c_start

    task i2c_write(byte data);
        tx_data_m = data;
        cmd_start = 1'b0;
        cmd_write = 1'b1;
        cmd_read  = 1'b0;
        cmd_stop  = 1'b0;
        @(negedge clk);
        @(negedge clk);
        @(negedge clk);
        @(negedge clk);
        @(negedge clk);
        wait (done);  // ack complete
        @(negedge clk);
        cmd_write = 1'b0;
    endtask  //12c_start


    task i2c_read();
        cmd_start = 1'b0;
        cmd_write = 1'b0;  //write
        cmd_read  = 1'b1;
        cmd_stop  = 1'b0;
        @(negedge clk);
        wait (done);
        @(negedge clk);
        cmd_read = 1'b0;
    endtask  //12c_start


    task i2c_stop();
        cmd_start = 1'b0;
        cmd_write = 1'b0;  //write
        cmd_read  = 1'b0;
        cmd_stop  = 1'b1;
        @(negedge clk);
        wait (done);
        @(negedge clk);
        cmd_stop = 1'b0;
    endtask  //12c_start

    initial begin
        clk = 0;
        rst = 1;
        tx_data_m = 8'h0;
        tx_data_s = 8'haa;
        ack_out_m = 1'b0;
        repeat (3) @(negedge clk);
        rst = 0;


        i2c_start();
        i2c_addr((SLA << 1) | 1'b0);
        i2c_write(8'h55);
        i2c_write(8'haa);
        i2c_write(8'h01);
        i2c_write(8'h02);
        i2c_write(8'h03);
        i2c_write(8'h04);
        i2c_write(8'h05);
        i2c_write(8'h06);
        i2c_write(8'hff);
        i2c_stop();

        @(negedge clk);
        @(negedge clk);
        @(negedge clk);
        @(negedge clk);
        @(negedge clk);


        tx_data_s = 8'h01;
        i2c_start();
        i2c_addr((SLA << 1) | 1'b1);
        i2c_read();
        i2c_stop();

        repeat (5) @(negedge clk);  

        // --- 2번째 데이터 ---
        tx_data_s = 8'h02;
        i2c_start();  
        i2c_addr((SLA << 1) | 1'b1); 
        i2c_read();
        i2c_stop();

        repeat (5) @(negedge clk);

        // --- 3번째 데이터 ---
        tx_data_s = 8'h03;
        i2c_start();
        i2c_addr((SLA << 1) | 1'b1);
        i2c_read();
        i2c_stop();
        repeat (5) @(negedge clk);

        // --- 4번째 데이터 ---
        tx_data_s = 8'h04;
        i2c_start();
        i2c_addr((SLA << 1) | 1'b1);
        i2c_read();
        i2c_stop();
        repeat (5) @(negedge clk);

        // --- 5번째 데이터 ---
        tx_data_s = 8'h05;
        i2c_start();
        i2c_addr((SLA << 1) | 1'b1);
        i2c_read();
        i2c_stop();








        /*
        //start
        cmd_start = 1'b1;
        cmd_write = 1'b0;
        cmd_read  = 1'b0;
        cmd_stop  = 1'b0;
        @(negedge clk);
        wait (done);  // done =1 end of start ,  go to wait_cmd
        @(negedge clk);

        // tx_data =  address(8'h12) + r/w signal 
        tx_data   = (SLA << 1) + 1'b0;  //write
        cmd_start = 1'b0;
        cmd_write = 1'b1;
        cmd_read  = 1'b0;
        cmd_stop  = 1'b0;
        @(negedge clk);
        wait (done);  // ack complete

        // tx_data =  data 
        tx_data   = 8'h55;
        cmd_start = 1'b0;
        cmd_write = 1'b1;  //write
        cmd_read  = 1'b0;
        cmd_stop  = 1'b0;
        @(negedge clk);
        wait (done);
        @(negedge clk);

        // stop
        cmd_start = 1'b0;
        cmd_write = 1'b0;  //write
        cmd_read  = 1'b0;
        cmd_stop  = 1'b1;
        @(negedge clk);
        wait (done);
        @(negedge clk);
*/
        // IDLE state
        #10000;
        $finish;
    end


endmodule
