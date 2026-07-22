

`timescale 1ns / 1ps

module i2c_demo_top (
    input  logic        clk,
    input  logic        rst,
    input  logic [15:0] sw,
    output logic        scl,
    input  logic        btn_start,
    output logic [ 7:0] fnd_data,
    output logic [ 3:0] fnd_digit,
    inout  wire         sda,
    output logic        busy
);

    typedef enum logic [2:0] {
        IDLE,
        START,
        ADDR,
        WRITE,
        STOP
    } i2c_state_e;

    i2c_state_e state;

    localparam SLA_W = {7'h12, 1'b0};  // Write Address

    logic [7:0] counter;
    logic cmd_start, cmd_write, cmd_read, cmd_stop, ack_in, done, ack_out, busy;

    logic [7:0] master_tx_data;  
    logic [7:0] master_rx_data;   
    logic [7:0] slave_rx_data;  

    logic [15:0] sw_reg, sw_edge;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            sw_reg  <= 16'b0;
            sw_edge <= 16'b0;
        end else begin
            sw_reg  <= sw;
            sw_edge <= sw & ~sw_reg;  
        end
    end

    logic btn_reg, btn_trig;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            btn_reg <= 1'b0;
        end else begin
            btn_reg <= btn_start;
        end
    end

    assign btn_trig = btn_start & ~btn_reg;

    // Master 인스턴스
    I2C_Master U_I2C_MASTER (
        .clk(clk),
        .rst(rst),
        .cmd_start(cmd_start_trig),
        .cmd_write(cmd_write),
        .cmd_read(cmd_read),
        .cmd_stop(cmd_stop),
        .tx_data(master_tx_data),
        .ack_in(ack_in),
        .rx_data(master_rx_data),  
        .done(done),
        .ack_out(ack_out),
        .busy(busy),
        .scl(scl),
        .sda(sda)
    );

    // Slave 인스턴스
    i2c_slave u_I2C_SLAVE (
        .clk(clk),
        .rst(rst),
        .ack_out(ack_out),
        .tx_data(8'h0),           
        .rx_data(slave_rx_data),  
        .ack_in(ack_in),
        .fnd_data(fnd_data),  
        .fnd_digit(fnd_digit),
        .scl(scl),
        .sda(sda)
    );


    logic cmd_start_reg, cmd_start_trig;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) cmd_start_reg <= 1'b0;
        else cmd_start_reg <= cmd_start;
    end

    assign cmd_start_trig = cmd_start & ~cmd_start_reg;




    always_ff @(posedge clk, posedge rst) begin
        if (rst) begin
            state          <= IDLE;
            counter        <= 8'h0;
            cmd_start      <= 1'b0;
            cmd_write      <= 1'b0;
            cmd_read       <= 1'b0;
            cmd_stop       <= 1'b0;
            master_tx_data <= 8'h0;
        end else begin
            case (state)
                IDLE: begin
                    cmd_start <= 1'b0;
                    cmd_write <= 1'b0;
                    cmd_read  <= 1'b0;
                    cmd_stop  <= 1'b0;
                    if (btn_trig) begin
                        state <= START;
                    end
                end
                START: begin
                    cmd_start <= 1'b1;
                    if (done) begin
                        state <= ADDR;
                    end
                end
                ADDR: begin
                    cmd_start <= 1'b0;
                    cmd_write <= 1'b1;
                    master_tx_data   <= SLA_W; 
                    if (done) begin
                        state <= WRITE;
                    end
                end
                WRITE: begin
                    cmd_write <= 1'b1;
                    master_tx_data   <= sw[7:0]; 
                    if (done) begin
                        state <= STOP;
                    end
                end
                STOP: begin
                    cmd_write <= 1'b0;
                    cmd_stop  <= 1'b1;
                    if (done) begin
                        state   <= IDLE;
                        counter <= counter + 1;
                    end
                end
                default: begin
                    state <= IDLE;
                end
            endcase
        end
    end

endmodule


