`timescale 1ns / 1ps

module i2c_slave (
    input  logic       clk,
    input  logic       rst,
    input  logic       ack_out,
    input  logic [7:0] tx_data,
    output logic [7:0] rx_data,
    output logic       ack_in,
    output logic [3:0] fnd_digit,
    output logic [7:0] fnd_data,
    input  logic       scl,
    inout  wire        sda
);

    localparam ADDRESS = 7'h12;

    logic falling_edge_l, rising_edge_l;
    logic sda_f, sda_r;
    logic sda_in, sda_out;
    logic [7:0] tx_shift_reg, rx_shift_reg;
    logic [7:0] rx_data_r;

    assign sda = sda_out ? 1'bz : 1'b0;
    // assign sda = (~sda_out) ? 1'b0 : 1'bz;
    assign sda_in = sda;

    // SCL edge detector
    edge_detector u_edge_dt_scl (
        .clk(clk),
        .rst(rst),
        .data_in(scl),
        .falling_edge(falling_edge_l),
        .rising_edge(rising_edge_l)
    );

    // SDA edge detector
    edge_detector u_edge_dt_sda (
        .clk(clk),
        .rst(rst),
        .data_in(sda_in),
        .falling_edge(sda_f),
        .rising_edge(sda_r)
    );

    fnd_controller U_FND (
        .fnd_in_data({8'd0, rx_data_r}),  // WDATA
        .clk(clk),
        .reset(rst),
        .fnd_digit(fnd_digit),
        .fnd_data(fnd_data)
    );

    logic scl_reg;
    logic start_cond, stop_cond;

    always_ff @(posedge clk, posedge rst) begin
        if (rst) scl_reg <= 1'b0;
        else scl_reg <= scl;
    end

    assign start_cond = scl_reg && sda_f;
    assign stop_cond  = scl_reg && sda_r;

    typedef enum logic [2:0] {
        IDLE,
        ADDR,
        ADDR_ACK,
        DATA,
        DATA_ACK
    } i2c_state_e;

    i2c_state_e state;
    logic [2:0] bit_cnt;
    logic is_read;

    assign rx_data = rx_data_r;

    always_ff @(posedge clk, posedge rst) begin
        if (rst) begin
            state        <= IDLE;
            bit_cnt      <= 3'd0;
            rx_shift_reg <= 8'd0;
            tx_shift_reg <= 8'd0;
            rx_data_r    <= 8'd0;
            sda_out      <= 1'b1;
            ack_in       <= 1'b1;
            is_read      <= 1'b0;
        end else begin
            case (state)
                IDLE: begin
                    sda_out <= 1'b1;
                    bit_cnt <= 0;

                    if (start_cond) begin
                        state <= ADDR;
                        $display("[%0t] START detected", $time);
                    end
                end

                ADDR: begin
                    if (stop_cond) begin
                        state <= IDLE;
                        $display("[%0t] STOP in ADDR", $time);
                    end else if (rising_edge_l) begin
                        rx_shift_reg <= {rx_shift_reg[6:0], sda_in};

                        if (bit_cnt == 7) begin
                            state <= ADDR_ACK;
                            $display("[%0t] ADDR received: 0x%02h", $time, {
                                     rx_shift_reg[6:0], sda_in});
                        end else begin
                            bit_cnt <= bit_cnt + 1;
                        end
                    end
                end

                ADDR_ACK: begin
                    if (stop_cond) begin
                        state <= IDLE;
                    end else begin
                        if (rx_shift_reg[7:1] == ADDRESS) begin
                            if (falling_edge_l) begin
                                sda_out <= 1'b0; // ACK 전송 (SDA를 0으로 당김)
                            end

                            if (rising_edge_l) begin
                                is_read <= rx_shift_reg[0];
                                bit_cnt <= 0;
                                state   <= DATA;
                            end
                        end else begin
                            if (rising_edge_l) state <= IDLE;
                        end
                    end
                end
                //             if (rising_edge_l) begin
                //                 is_read <= rx_shift_reg[0];
                //                 bit_cnt <= 0;
                //                 // sda_out <= 1'b1;

                //                 if (rx_shift_reg[0]) begin  // Read
                //                     tx_shift_reg <= tx_data;
                //                     $display("[%0t] READ mode, tx_data=0x%02h",
                //                              $time, tx_data);
                //                 end else begin  // Write
                //                     $display("[%0t] WRITE mode", $time);
                //                 end
                //                 sda_out <= 1'b1;
                //                 // sda_out <= 1'b1;
                //                 state   <= DATA;
                //             end
                //         end else begin
                //             if (falling_edge_l) begin
                //                 sda_out <= 1'b1;  // NACK = HIGH
                //             end
                //             if (rising_edge_l) begin
                //                 state <= IDLE;
                //             end
                //         end
                //     end
                // end
                DATA: begin
                    if (stop_cond) begin
                        state <= IDLE;
                    end else if (start_cond) begin
                        state   <= ADDR;
                        bit_cnt <= 0;  
                    end else begin
                        if (falling_edge_l && bit_cnt == 0) begin
                            sda_out <= 1'b1;
                        end

                        if (rising_edge_l) begin
                            // [핵심] 이 줄이 빠져서 0x24가 고여있었던 것입니다!
                            rx_shift_reg <= {rx_shift_reg[6:0], sda_in};

                            if (bit_cnt == 7) begin
                                rx_data_r <= {
                                    rx_shift_reg[6:0], sda_in
                                };  // 여기서 올바른 8비트 캡처 완료
                                state <= DATA_ACK;
                            end else begin
                                bit_cnt <= bit_cnt + 1;
                            end
                        end
                    end
                end
                // DATA: begin
                //     if (stop_cond) begin
                //         state <= IDLE;
                //         $display("[%0t] STOP in DATA", $time);
                //     end else if (start_cond) begin
                //         state   <= ADDR;
                //         bit_cnt <= 0;
                //         $display("[%0t] Repeated START", $time);
                //     end else begin
                //         if (is_read) begin
                //             if (falling_edge_l) begin
                //                 sda_out <= tx_shift_reg[7];
                //                 tx_shift_reg <= {tx_shift_reg[6:0], 1'b0};
                //                 // end

                //                 // if (rising_edge_l) begin
                //                 if (bit_cnt == 7) begin
                //                     state <= DATA_ACK;
                //                     $display("[%0t] TX byte complete", $time);
                //                 end else begin
                //                     bit_cnt <= bit_cnt + 1;
                //                 end
                //             end
                //         end else begin
                //             if (falling_edge_l) begin
                //                 sda_out <= 1'b1;  // Release SDA
                //             end

                //             if (rising_edge_l) begin
                //                 rx_shift_reg <= {rx_shift_reg[6:0], sda_in};
                //                 $display(
                //                     "[%0t] [SLAVE_DEBUG] bit_cnt:%0d, sda_in:%b, shift_reg:%h",
                //                     $time, bit_cnt, sda_in, rx_shift_reg);
                //                 if (bit_cnt == 7) begin
                //                     rx_data_r <= {rx_shift_reg[6:0], sda_in};
                //                     $display(
                //                         "[%0t] [SLAVE_DEBUG] BYTE 수신 완료! rx_data_r: 0x%h",
                //                         $time, {rx_shift_reg[6:0], sda_in});
                //                     state <= DATA_ACK;
                //                     $display("[%0t] RX byte: 0x%02h", $time, {
                //                              rx_shift_reg[6:0], sda_in});
                //                 end else begin
                //                     bit_cnt <= bit_cnt + 1;
                //                 end
                //             end
                //         end
                //     end
                // end

                DATA_ACK: begin
                    if (stop_cond) begin
                        state <= IDLE;
                    end else begin
                        if (!is_read) begin
                            if (falling_edge_l) begin
                                // sda_out <= ack_out;  // 보통 0 (ACK)
                                sda_out <= 1'b0;  // 보통 0 (ACK)
                            end
                            if (rising_edge_l) begin
                                bit_cnt <= 0;
                                // sda_out <= 1'b1;
                                state   <= DATA;
                            end
                        end else begin
                            sda_out <= 1'b1;  // Release SDA

                            if (rising_edge_l) begin
                                ack_in  <= sda_in;  // Master ACK 읽기
                                bit_cnt <= 0;

                                if (sda_in == 1'b0) begin  // ACK
                                    tx_shift_reg <= tx_data;
                                    state <= DATA;
                                end else begin  // NACK
                                    state <= IDLE;
                                end
                            end
                        end
                    end
                end
            endcase
        end
    end

endmodule


module edge_detector (
    input  logic clk,
    input  logic rst,
    input  logic data_in,
    output logic falling_edge,
    output logic rising_edge
);

    logic ff1, ff2;

    always_ff @(posedge clk, posedge rst) begin
        if (rst) begin
            ff1 <= 1'b0;
            ff2 <= 1'b0;
        end else begin
            ff1 <= data_in;
            ff2 <= ff1;
        end
    end

    assign rising_edge  = (~ff2) & ff1;
    assign falling_edge = ff2 & (~ff1);

endmodule


module fnd_controller (
    input [15:0] fnd_in_data,  // WDATA
    input clk,
    input reset,
    output [3:0] fnd_digit,
    output [7:0] fnd_data
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
            if (counter_r == 9) begin
                // if (counter_r == 99999) begin
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
    input  [15:0] in_data,
    output [ 3:0] digit_1,
    output [ 3:0] digit_10,
    output [ 3:0] digit_100,
    output [ 3:0] digit_1000
);


    assign digit_1    = in_data[3:0];
    assign digit_10   = in_data[7:4];
    assign digit_100  = in_data[11:8];
    assign digit_1000 = in_data[15:12];

endmodule

module bcd (
    input      [3:0] bcd,
    output reg [7:0] fnd_data
);

    always @(bcd) begin
        case (bcd)
            4'h0: fnd_data = 8'hC0;
            4'h1: fnd_data = 8'hF9;
            4'h2: fnd_data = 8'hA4;
            4'h3: fnd_data = 8'hB0;
            4'h4: fnd_data = 8'h99;
            4'h5: fnd_data = 8'h92;
            4'h6: fnd_data = 8'h82;
            4'h7: fnd_data = 8'hF8;
            4'h8: fnd_data = 8'h80;
            4'h9: fnd_data = 8'h90;
            4'hA: fnd_data = 8'h88;
            4'hB: fnd_data = 8'h83;
            4'hC: fnd_data = 8'hC6;
            4'hD: fnd_data = 8'hA1;
            4'hE: fnd_data = 8'h86;
            4'hF: fnd_data = 8'h8E;
            default: fnd_data = 8'hFF;
        endcase
    end
endmodule
