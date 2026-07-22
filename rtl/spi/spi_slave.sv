`timescale 1ns / 1ps

module spi_slave (
    input  logic       clk,
    input  logic       rst,
    input  logic       sclk,
    input  logic       cs_n,
    input  logic       mosi,
    input  logic [7:0] tx_data,
    output logic       miso,
    output logic       done,
    output logic       busy,
    output logic [7:0] rx_data
);

    logic falling_edge, rising_edge;

    edge_detector U_EDGE (
        .clk(clk),
        .rst(rst),
        .data_in(sclk),
        .falling_edge(falling_edge),
        .rising_edge(rising_edge)
    );



    typedef enum logic [2:0] {
        IDLE,
        START,
        // DATA,
        DATA_RX,
        DATA_TX,
        STOP
    } spi_state_e;

    spi_state_e state;
    logic [7:0] tx_shift_reg, rx_shift_reg;
    logic [2:0] bit_cnt;
    logic step, sclk_r;

    assign rx_data = rx_shift_reg;

    always_ff @(posedge clk, posedge rst) begin
        if (rst) begin
            state        <= IDLE;
            miso         <= 1'bz;
            bit_cnt      <= 3'd0;
            tx_shift_reg <= 8'h00;
            rx_shift_reg <= 8'h00;
            busy         <= 1'b0;
            done         <= 1'b0;
        end else begin
            case (state)
                IDLE: begin
                    miso <= 1'bz;
                    done <= 1'b0;
                    bit_cnt <= 0;
                    step <= 0;
                    if (!cs_n) begin
                        state <= START;
                        tx_shift_reg <= tx_data;
                        busy <= 1'b1;
                        // miso <= tx_data[7];
                    end
                end
                START: begin
                    miso <= tx_shift_reg[7];
                    if (rising_edge) begin
                        tx_shift_reg <= {tx_shift_reg[6:0], 1'b0};
                        state <= DATA_RX;
                    end
                end


                DATA_RX: begin
                    if (bit_cnt == 7) begin
                        if (falling_edge) begin
                            rx_shift_reg <= {rx_shift_reg[6:0], mosi};
                            bit_cnt <= 0;
                            state <= STOP;
                        end
                    end else begin
                        rx_shift_reg <= {rx_shift_reg[6:0], mosi};
                        state <= DATA_TX;
                    end
                end

                DATA_TX: begin
                    if (falling_edge) begin
                        miso <= tx_shift_reg[7];
                    end
                    if (rising_edge) begin
                        tx_shift_reg <= {tx_shift_reg[6:0], 1'b0};
                        state <= DATA_RX;
                        bit_cnt <= bit_cnt + 1;
                    end
                end
                // DATA: begin
                //     if (rising_edge) begin
                //         rx_shift_reg <= {rx_shift_reg[6:0], mosi};

                //         if (bit_cnt == 7) begin
                //             state <= STOP;
                //         end else begin
                //             bit_cnt <= bit_cnt + 1;
                //         end
                //     end
                //     if (falling_edge) begin
                //         miso <= tx_shift_reg[7];
                //         tx_shift_reg <= {tx_shift_reg[6:0], 1'b0};
                //     end
                // end

                STOP: begin
                    sclk_r <= 1'b0;
                    done   <= 1'b1;
                    busy   <= 1'b0;
                    miso   <= 1'bz;
                    state  <= IDLE;
                end
            endcase
        end
    end




endmodule


module edge_detector (
    input logic clk,
    input logic rst,
    input logic data_in,  // SCLK
    output logic falling_edge,
    output logic rising_edge
);


    logic ff;

    always_ff @(posedge clk, posedge rst) begin
        if (rst) begin
            ff <= 1'd0;
        end else begin
            ff <= data_in;
        end
    end

    assign rising_edge  = ((~ff) & data_in);
    assign falling_edge = (ff & (~data_in));



endmodule



