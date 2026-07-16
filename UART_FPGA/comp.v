module cop #(
    parameter CLK_FREQ = 50000000, // 50 MHz
    parameter BAUD_RATE = 9600
)(
    input wire clk,
    input wire reset,
    
    // TX ports
    input wire start,
    input wire [7:0] data_in,
    output wire tx_out,
    
    // RX ports
    input wire rx_in,
    output wire err,
    output wire [7:0] data_out 
  );
    uart_tx #(
                                                               .CLK_FREQ(CLK_FREQ),
                                                               .BAUD_RATE(BAUD_RATE)
    ) tx(
                                                               .clk(clk),
                                                               .reset(reset),
                                                               .start_tx(start),
                                                               .tx_data(data_in),
                                                               .tx_out(tx_out)
    );

    uart_rx #(
                                                               .CLK_FREQ(CLK_FREQ),
                                                               .BAUD_RATE(BAUD_RATE)
    )rx(
                                                               .clk(clk),
                                                               .reset(reset),
                                                               .rx_in(rx_in),
                                                               .parity_err(err),
                                                               .rx_data(data_out)
    );

endmodule