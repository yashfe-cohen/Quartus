module uart_tx (
    input wire clk,       // clock
    input wire reset,     // reset
    input wire start_tx,  // start trigger
    input wire [7:0] tx_data, // data to send
    output reg tx_out     // output line
);

    // states
    localparam IDLE   = 2'd0;
    localparam DATA   = 2'd1;
    localparam PARITY = 2'd2;
    localparam STOP   = 2'd3;

    reg [1:0] state;
    reg [2:0] bit_idx;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
            tx_out <= 1; 
            bit_idx <= 0;
        end else begin
            case (state)
                IDLE: begin 
                    if (start_tx) begin
                        tx_out <= 0; // start bit
                        state <= DATA;
                        bit_idx <= 0;
                    end else begin
                        tx_out <= 1; // line idle 
                    end
                end
                
                DATA: begin 
                    tx_out <= tx_data[bit_idx];
                    if (bit_idx == 7) begin
                        state <= PARITY;
                    end else begin
                        bit_idx <= bit_idx + 1;
                    end
                end
                
                PARITY: begin 
                    tx_out <= ^tx_data; // parity bit send to rx_in
                    state <= STOP;
                end
                
                STOP: begin 
                    tx_out <= 1; // stop bit
                    state <= IDLE;
                end
                
                default: state <= IDLE;
            endcase
        end
    end
    
endmodule