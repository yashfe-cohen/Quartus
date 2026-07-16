module UART (
    input wire clk,
    input wire reset,
    
    input wire start_a,
    input wire [7:0] data_a, // data for a
    output wire err_a,
    
    input wire start_b,
    input wire [7:0] data_b, // data for b 
    output wire err_b
);

    wire w_a_to_b;
    wire w_b_to_a;

    // --- side A ---
    uart_tx tx_a (
                                                                    .clk(clk),
                                                                    .reset(reset),
                                                                    .start_tx(start_a),
                                                                    .tx_data(data_a), // Inserting data into the register via the testbench for A.
                                                                    .tx_out(w_a_to_b)
    );

    uart_rx rx_a (
                                                                     .clk(clk),
                                                                     .reset(reset),
                                                                     .rx_in(w_b_to_a),
                                                                     .parity_err(err_a)
    );

    // --- side B ---
    uart_tx tx_b (
                                                                      .clk(clk),
                                                                      .reset(reset),
                                                                      .start_tx(start_b),
                                                                      .tx_data(data_b), // Inserting data into the register via the testbench for B.
                                                                      .tx_out(w_b_to_a)
    );

    uart_rx rx_b (
                                                                       .clk(clk),
                                                                       .reset(reset),
                                                                       .rx_in(w_a_to_b),
                                                                       .parity_err(err_b)
    ); 

endmodule