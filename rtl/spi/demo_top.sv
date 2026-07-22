module spi_top (
    input  logic        clk,
    input  logic        rst,
    input  logic [15:0] sw,       
    input  logic        btn_send, 
    output logic [ 3:0] fnd_digit,
    output logic [ 7:0] fnd_data
);

    logic sclk, mosi, miso, cs_n;
    logic [15:0] slave_rx_data;

    spi_master U_MASTER (
        .clk    (clk),
        .rst    (rst),
        .cpol   (1'b0),        
        .cpha   (1'b0),
        .clk_div(8'd100),      
        .tx_data(sw),          
        .start  (btn_send),    
        .sclk   (sclk),        
        .mosi   (mosi),
        .miso   (miso),
        .cs_n   (cs_n),
        .rx_data(),            
        .done   (),
        .busy   ()
    );

    spi_slave U_SLAVE (
        .clk    (clk),
        .rst    (rst),
        .sclk   (sclk),          
        .cs_n   (cs_n),          
        .mosi   (mosi),          
        .miso   (miso),          
        .tx_data(16'h0),         
        .rx_data(slave_rx_data), 
        .done   (),
        .busy   ()
    );

    fnd_controller U_FND (
        .fnd_in_data(slave_rx_data[13:0]), 
        .clk        (clk),
        .reset      (rst),
        .fnd_digit  (fnd_digit),
        .fnd_data   (fnd_data)
    );

endmodule