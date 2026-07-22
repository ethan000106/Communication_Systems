// `timescale 1ns / 1ps

// module i2c_demo_top (
//     input  logic        clk,
//     input  logic        rst,
//     input  logic [15:0] sw,
//     output logic        scl,
//     output logic [ 7:0] fnd_data,
//     output logic [ 3:0] fnd_digit,
//     inout  wire         sda
// );





//     typedef enum logic [2:0] {
//         IDLE,
//         START,
//         ADDR,
//         WRITE,
//         READ,
//         STOP
//     } i2c_state_e;

//     i2c_state_e state;

//     localparam SLA_W = {7'h12, 1'b0};
//     //counter
//     logic [7:0] counter;
//     logic cmd_start, cmd_write, cmd_read, cmd_stop, ack_in, done, ack_out, busy;
//     logic [7:0] tx_data, rx_data;
//     logic [15:0] sw_reg, sw_edge;

//     always_ff @(posedge clk or posedge rst) begin
//         if (rst) begin
//             sw_reg  <= 1'b0;
//             sw_edge <= 1'b0;
//         end else begin
//             sw_reg  <= sw;
//             sw_edge <= sw && ~sw_reg;
//         end
//     end

//     I2C_Master U_I2C_MASTER (
//         .clk(clk),
//         .rst(rst),
//         .cmd_start(cmd_start),
//         .cmd_write(cmd_write),
//         .cmd_read(cmd_read),
//         .cmd_stop(cmd_stop),
//         .tx_data(tx_data),
//         .ack_in(ack_in),
//         .rx_data(rx_data),
//         .done(done),
//         .ack_out(ack_out),
//         .busy(busy),
//         .scl(scl),
//         .sda(sda)
//     );
//     i2c_slave u_I2C_SLAVE (
//         .clk(clk),
//         .rst(rst),
//         .ack_out(ack_out),  // slave가 받는거 master 가 write 일때
//         .tx_data(tx_data),  // slave가 master에게 주는 값
//         .rx_data(rx_data),  // slave가 master에게 주는 값
//         .ack_in(ack_in),  // slave가 주는거 master가 read일때
//         .fnd_data(fnd_data),  // FND
//         .fnd_digit(fnd_digit),  // FND
//         .scl(scl),
//         .sda(sda)
//     );







//     always_ff @(posedge clk, posedge rst) begin
//         if (rst) begin
//             state     <= IDLE;
//             counter   <= 8'h0;
//             cmd_start <= 1'b0;
//             cmd_write <= 1'b0;
//             cmd_read  <= 1'b0;
//             cmd_stop  <= 1'b0;
//             tx_data   <= 8'h0;
//         end else begin
//             case (state)
//                 IDLE: begin
//                     cmd_start <= 1'b0;
//                     cmd_write <= 1'b0;
//                     cmd_read  <= 1'b0;
//                     cmd_stop  <= 1'b0;
//                     if (|sw_edge[7:0]) begin
//                         state <= START;
//                     end

//                 end
//                 START: begin
//                     cmd_start <= 1'b1;
//                     cmd_write <= 1'b0;
//                     cmd_read  <= 1'b0;
//                     cmd_stop  <= 1'b0;
//                     if (done) begin
//                         state <= ADDR;
//                     end
//                 end
//                 ADDR: begin
//                     cmd_start <= 1'b0;
//                     cmd_write <= 1'b1;
//                     cmd_read  <= 1'b0;
//                     cmd_stop  <= 1'b0;
//                     tx_data   <= SLA_W;
//                     if (done) begin
//                         state <= WRITE;
//                     end
//                 end
//                 WRITE: begin
//                     cmd_start <= 1'b0;
//                     cmd_write <= 1'b1;
//                     cmd_read  <= 1'b0;
//                     cmd_stop  <= 1'b0;
//                     tx_data   <= sw[7:0];
//                     if (done) begin
//                         state <= STOP;
//                     end
//                 end
//                 READ: begin
//                     cmd_start <= 1'b0;
//                     cmd_write <= 1'b0;
//                     cmd_read  <= 1'b1;
//                     cmd_stop  <= 1'b0;
//                     tx_data   <= sw[7:0];
//                     if (done) begin
//                         state <= STOP;
//                     end
//                 end
//                 STOP: begin
//                     cmd_start <= 1'b0;
//                     cmd_write <= 1'b0;
//                     cmd_read  <= 1'b0;
//                     cmd_stop  <= 1'b1;
//                     if (done) begin
//                         state   <= IDLE;
//                         counter <= counter + 1;
//                     end
//                 end
//                 default: begin
//                     state <= IDLE;
//                 end
//             endcase
//         end
//     end





// endmodule

`timescale 1ns / 1ps

module i2c_demo_top (
    input  logic        clk,
    input  logic        rst,
    input  logic [15:0] sw,
    output logic        scl,
    output logic [ 7:0] fnd_data,
    output logic [ 3:0] fnd_digit,
    inout  wire         sda
);

    typedef enum logic [2:0] {
        IDLE,
        START,
        ADDR,
        WRITE,
        STOP
    } i2c_state_e;

    i2c_state_e state;

    localparam SLA_W = {7'h12, 1'b0}; // Write Address
    
    logic [7:0] counter;
    logic cmd_start, cmd_write, cmd_read, cmd_stop, ack_in, done, ack_out, busy;
    
    // 핵심 수정: tx, rx 신호선 분리
    logic [7:0] master_tx_data;   // Top -> Master 로 주는 데이터
    logic [7:0] master_rx_data;   // Master가 읽어온 데이터 (현재 안 씀)
    logic [7:0] slave_rx_data;    // Slave가 받은 데이터
    
    logic [15:0] sw_reg, sw_edge;

    // 스위치 엣지 검출 (스위치를 올리는 순간 1번만 전송 시작)
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            sw_reg  <= 16'b0;
            sw_edge <= 16'b0;
        end else begin
            sw_reg  <= sw;
            sw_edge <= sw & ~sw_reg; // rising edge 감지
        end
    end

    // Master 인스턴스
    I2C_Master U_I2C_MASTER (
        .clk(clk),
        .rst(rst),
        .cmd_start(cmd_start),
        .cmd_write(cmd_write),
        .cmd_read(cmd_read),
        .cmd_stop(cmd_stop),
        .tx_data(master_tx_data), 
        .ack_in(ack_in),
        .rx_data(master_rx_data), // Master의 전용 수신선
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
        .tx_data(8'h0),           // 현재 Slave가 보낼 데이터는 안 쓰므로 0 고정
        .rx_data(slave_rx_data),  // Slave의 전용 수신선 (충돌 해결!)
        .ack_in(ack_in),  
        .fnd_data(fnd_data),      // Slave 내부에서 FND 제어
        .fnd_digit(fnd_digit),  
        .scl(scl),
        .sda(sda)
    );

    // 상태 머신: 스위치 조작 -> START -> 주소 쓰기 -> 데이터(스위치값) 쓰기 -> STOP
    always_ff @(posedge clk, posedge rst) begin
        if (rst) begin
            state     <= IDLE;
            counter   <= 8'h0;
            cmd_start <= 1'b0;
            cmd_write <= 1'b0;
            cmd_read  <= 1'b0;
            cmd_stop  <= 1'b0;
            master_tx_data   <= 8'h0;
        end else begin
            case (state)
                IDLE: begin
                    cmd_start <= 1'b0;
                    cmd_write <= 1'b0;
                    cmd_read  <= 1'b0;
                    cmd_stop  <= 1'b0;
                    // 스위치 0~7 중 하나라도 위로 올라가는 순간 전송 시작
                    if (|sw_edge[15:0]) begin 
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
                    master_tx_data   <= SLA_W; // 슬레이브 주소(Write) 전송
                    if (done) begin
                        state <= WRITE;
                    end
                end
                WRITE: begin
                    cmd_write <= 1'b1;
                    master_tx_data   <= sw[15:0]; // 켜져있는 스위치 값을 전송
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


