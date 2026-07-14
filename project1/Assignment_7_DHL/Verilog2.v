module uart_rx (
    input wire clk,       //  clock
    input wire reset,     // reset
    input wire rx_in,     // input line
    output reg parity_err // parity error 
);

    // states
    localparam IDLE   = 2'd0;
    localparam DATA   = 2'd1;
    localparam PARITY = 2'd2;
    localparam STOP   = 2'd3;

    reg [1:0] state;    // FSM state
    reg [2:0] bit_idx;  // counter
    reg [7:0] rx_data;  // DATA register

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
            parity_err <= 0;
            bit_idx <= 0;
            rx_data <= 8'b0;
        end else begin
            case (state)
                IDLE: begin 
                    if (rx_in == 0) begin // wait for start bit
                        state <= DATA;
                        bit_idx <= 0;
                    end
                end
                
                DATA: begin 
                    rx_data[bit_idx] <= rx_in; // sample data bit
                    if (bit_idx == 7) begin   // byte complete
                        state <= PARITY;
                    end else begin
                        bit_idx <= bit_idx + 1;
                    end
                end
                
                PARITY: begin 
                    // check even parity
                    if (rx_in != ^rx_data) begin // tx_out == rx_in in tx compnant
                        parity_err <= 1; // error
                    end else begin
                        parity_err <= 0; // ok
                    end
                    state <= STOP;
                end
                
                STOP: begin 
                    state <= IDLE; // frame done
                end
                
                default: state <= IDLE;
            endcase
        end
    end
    
endmodule