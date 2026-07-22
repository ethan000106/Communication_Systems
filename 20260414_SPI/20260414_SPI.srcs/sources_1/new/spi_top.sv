`timescale 1ns / 1ps

module spi_top (
    input  logic        clk,
    input  logic        rst,
    // input  logic        cpol,
    // input  logic        cpha,
    input  logic [15:0] sw,
    // input  logic [ 7:0] clk_div,
    input  logic [ 7:0] tx_data,
    input  logic        btn_start,
    // output logic [ 7:0] rx_data,
    // output logic        done,
    // output logic        busy,
    output logic [ 3:0] fnd_digit,
    output logic [ 7:0] fnd_data
);

    logic sclk, mosi, miso, cs_n;
    logic [ 7:0] master_rx_data;
    logic [15:0] slave_rx_data;
    logic master_done, slave_done;
    logic master_busy, slave_busy;

    spi_master U_MASTER (
        .clk    (clk),
        .rst    (rst),
        .cpol   (cpol),
        .cpha   (cpha),
        .clk_div(16'd5000),
        .tx_data(sw),
        .start  (w_start_pulse),
        .rx_data(master_rx_data),
        .done   (master_done),
        .busy   (master_busy),
        .sclk   (sclk),
        .mosi   (mosi),
        .miso   (miso),
        .cs_n   (cs_n)
    );

    spi_slave U_SLAVE (
        .clk    (clk),
        .rst    (rst),
        .sclk   (sclk),
        .cs_n   (cs_n),
        .mosi   (mosi),
        .tx_data(tx_data),
        .miso   (miso),
        .done   (slave_done),
        .busy   (slave_busy),
        .rx_data(slave_rx_data[13:0])
    );



    fnd_controller U_FND (
        .fnd_in_data({6'h0, slave_rx_data}),
        .clk        (clk),
        .reset      (rst),
        .fnd_digit  (fnd_digit),
        .fnd_data   (fnd_data)
    );

    logic btn_reg, btn_sync;
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            btn_reg  <= 1'b0;
            btn_sync <= 1'b0;
        end else begin
            btn_reg  <= btn_start;
            btn_sync <= btn_reg;
        end
    end

    assign w_start_pulse = btn_reg & ~btn_sync;


endmodule




module fnd_controller (
    input  [13:0] fnd_in_data,  // WDATA
    input         clk,
    input         reset,
    output [ 3:0] fnd_digit,
    output [ 7:0] fnd_data
);
    wire [1:0] w_digit_sel;
    wire [3:0] w_digit_1, w_digit_10, w_digit_100, w_digit_1000;
    wire [3:0] w_mux_4_1_out;
    wire w_1kz;

    clk_div U_CLK_DIV (
        .clk(clk),
        .reset(reset),
        .o_1khz(w_1kz)
    );


    counter_4 U_COUNTER_4 (
        .clk(w_1kz),
        .reset(reset),
        .digit_sel(w_digit_sel)
    );

    decoder_2_4 U_DECODER_2_4 (
        .btn(w_digit_sel),
        .fnd_digit(fnd_digit)
    );


    digit_splitter U_DIGIT_SPL (
        .in_data(fnd_in_data),
        .digit_1(w_digit_1),
        .digit_10(w_digit_10),
        .digit_100(w_digit_100),
        .digit_1000(w_digit_1000)
    );


    mux4_1 U_MUX_4_1 (
        .digit_1(w_digit_1),
        .digit_10(w_digit_10),
        .digit_100(w_digit_100),
        .digit_1000(w_digit_1000),
        .sel(w_digit_sel),
        .mux_out(w_mux_4_1_out)
    );



    bcd U_BCD (
        .bcd(w_mux_4_1_out),
        .fnd_data(fnd_data)
    );


endmodule

module clk_div (
    input clk,
    input reset,
    output reg o_1khz
);
    reg [16:0] counter_r;


    always @(posedge clk, posedge reset) begin
        if (reset) begin
            counter_r <= 1'b0;
            o_1khz <= 1'b0;
        end else begin
            if (counter_r == 99999) begin
                counter_r <= 0;
                o_1khz <= 1'b1;
            end else begin
                counter_r <= counter_r + 1;
                o_1khz <= 1'b0;
            end
        end


    end

endmodule

module counter_4 (
    input        clk,
    input        reset,
    output [1:0] digit_sel
);
    reg [1:0] counter_r;

    assign digit_sel = counter_r;

    always @(posedge clk, posedge reset) begin
        if (reset) counter_r <= 0;
        else begin
            counter_r <= counter_r + 1;
        end
    end



endmodule



module decoder_2_4 (
    input [1:0] btn,
    output reg [3:0] fnd_digit
);

    always @(btn) begin
        case (btn)
            2'b00:   fnd_digit = 4'b1110;
            2'b01:   fnd_digit = 4'b1101;
            2'b10:   fnd_digit = 4'b1011;
            default: fnd_digit = 4'b0111;
        endcase
    end

endmodule


module mux4_1 (
    input [3:0] digit_1,
    input [3:0] digit_10,
    input [3:0] digit_100,
    input [3:0] digit_1000,
    input [1:0] sel,
    output reg [3:0] mux_out
);


    always @(*) begin
        case (sel)
            2'b00:   mux_out = digit_1;
            2'b01:   mux_out = digit_10;
            2'b10:   mux_out = digit_100;
            default: mux_out = digit_1000;
        endcase


    end



endmodule





module digit_splitter (
    input  [13:0] in_data,
    output [ 3:0] digit_1,
    output [ 3:0] digit_10,
    output [ 3:0] digit_100,
    output [ 3:0] digit_1000
);

    assign digit_1    =  in_data % 10;
    assign digit_10   = (in_data / 10) % 10;
    assign digit_100  = (in_data / 100) % 10;
    assign digit_1000 = (in_data / 1000) % 10;

endmodule


module bcd (
    input      [3:0] bcd,
    output reg [7:0] fnd_data
);

    always @(bcd) begin
        case (bcd)
            4'd0: fnd_data = 8'hC0;
            4'd1: fnd_data = 8'hf9;
            4'd2: fnd_data = 8'ha4;
            4'd3: fnd_data = 8'hB0;
            4'd4: fnd_data = 8'h99;
            4'd5: fnd_data = 8'h92;
            4'd6: fnd_data = 8'h82;
            4'd7: fnd_data = 8'hf8;
            4'd8: fnd_data = 8'h80;
            4'd9: fnd_data = 8'h90;
            default: fnd_data = 8'hFF;
        endcase
    end
endmodule

