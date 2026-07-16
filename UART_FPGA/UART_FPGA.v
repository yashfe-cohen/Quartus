module UART_FPGA #(
    parameter CLK_FREQ = 50000000, // 50 MHz
    parameter BAUD_RATE = 9600
)(
    input wire clk,
    input wire reset,
    
    input wire uart_rx_pin,  // RX wire coming  outside world
    output wire uart_tx_pin, // TX wire going to outside world
    
	 
    // --- Internal FPGA Connections
    input wire start_tx,
    input wire [7:0] data_to_transmit, // data to send out
    output wire [7:0] data_received,   // data received from outside
    output wire rx_err
);

    
    cop #(
                                                               .CLK_FREQ(CLK_FREQ),
                                                               .BAUD_RATE(BAUD_RATE)
    ) my_uart (
                                                               .clk(clk),
                                                               .reset(reset),
                                                               .start(start_tx),
                                                               .data_in(data_to_transmit),
                                                               .tx_out(uart_tx_pin),
                                                               .rx_in(uart_rx_pin),
                                                               .err(rx_err),
                                                               .data_out(data_received)
    ); 

endmodule