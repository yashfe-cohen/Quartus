module uart_rx #(
    parameter CLK_FREQ = 50000000, // 50 MHz
    parameter BAUD_RATE = 9600
)(
    input wire clk,       // clock
    input wire reset,     // reset
    input wire rx_in,     // input line
	 output wire [7:0] rx_data,
	 
    output reg parity_err // parity error 
	 
);

    // states
    localparam IDLE   = 2'd0;
    localparam DATA   = 2'd1;
    localparam PARITY = 2'd2;
    localparam STOP   = 2'd3;
	 
	 localparam BIT_TICK = (CLK_FREQ / BAUD_RATE) - 1; // count and send 1 tik
    localparam HALF_TICK = ((CLK_FREQ / BAUD_RATE) / 2) - 1;  // be In the middle of the bit

	 
    reg [1:0] state;    // FSM state
    reg [2:0] bit_idx;  // counter
    reg [7:0] rx_data;  // DATA register
    reg [12:0] baud_cnt; // baud rate counter (50MHz / 9600 = 5208)

    always @(posedge clk or negedge reset) begin
        if (reset == 0) begin
            state <= IDLE;
            parity_err <= 1'b0;
            bit_idx <= 3'd0;
            rx_data <= 8'b0;
            baud_cnt <= 13'd0;
        end else begin
            case (state)
                IDLE: begin 
                    if (rx_in == 1'b0) begin // wait for start bit
                        if (baud_cnt == HALF_TICK) begin // half bit duration to sample in the middle
                            state <= DATA;
                            baud_cnt <= 13'd0;
                            bit_idx <= 3'd0;
                        end else begin
                            baud_cnt <= baud_cnt + 1'b1;
                        end
                    end else begin
                        baud_cnt <= 13'd0;
                    end
                end
                
                DATA: begin 
                    if (baud_cnt == BIT_TICK) begin // full bit duration
                        baud_cnt <= 13'd0;
                        rx_data[bit_idx] <= rx_in; // sample data bit
                        
                        if (bit_idx == 3'd7) begin   // byte complete
                            state <= PARITY;
                        end else begin
                            bit_idx <= bit_idx + 1'b1;
                        end
                    end else begin
                        baud_cnt <= baud_cnt + 1'b1;
                    end
                end
                
                PARITY: begin 
                    if (baud_cnt == BIT_TICK) begin // wait full bit duration
                        baud_cnt <= 13'd0;
                        // check even parity
                        if (rx_in != ^rx_data) begin 
                            parity_err <= 1'b1; // error
                        end else begin
                            parity_err <= 1'b0; // ok
                        end
                        state <= STOP;
                    end else begin
                        baud_cnt <= baud_cnt + 1'b1;
                    end
                end
                
                STOP: begin 
                    if (baud_cnt == BIT_TICK) begin // wait full bit duration
                        baud_cnt <= 13'd0;
                        state <= IDLE; // frame done
                    end else begin
                        baud_cnt <= baud_cnt + 1'b1;
                    end
                end
                
                default: state <= IDLE;
            endcase
        end
    end
    
endmodule