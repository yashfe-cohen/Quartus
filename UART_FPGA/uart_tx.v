module uart_tx #(
    parameter CLK_FREQ = 50000000, // 50 MHz
    parameter BAUD_RATE = 9600
)(
    input wire clk,           // clock
    input wire reset,         // reset
    input wire start_tx,      // start trigger
    input wire [7:0] tx_data, // data to send
    output reg tx_out         // output line
);

    // states
    localparam IDLE   = 2'd0;
    localparam DATA   = 2'd1;
    localparam PARITY = 2'd2;
    localparam STOP   = 2'd3;
    
	 localparam BIT_TICK = (CLK_FREQ / BAUD_RATE) - 1;
	
    reg [1:0] state = 2'd0;
    reg [2:0] bit_idx = 3'd0;
    reg [12:0] baud_cnt = 48'd0; // baud rate counter (50MHz / 9600 = 5208)

    always @(posedge clk or negedge reset) begin
        if (reset == 0) begin
            state <= IDLE;
            tx_out <= 1'b1; 
            bit_idx <= 3'd0;
            baud_cnt <= BIT_TICK; // start ready to transmit immediately
        end else begin
            case (state)
                IDLE: begin 
                    if (baud_cnt < BIT_TICK) begin
                        baud_cnt <= baud_cnt + 1'b1; // enforce stop bit wait time
                        tx_out <= 1'b1;
                    end else begin
                        tx_out <= 1'b1; // line idle 
                        if (start_tx) begin
                            tx_out <= 1'b0; // start bit
                            state <= DATA;
                            bit_idx <= 3'd0;
                            baud_cnt <= 13'd0;
                        end
                    end
                end
                
                DATA: begin 
                    if (baud_cnt == BIT_TICK) begin // wait full bit duration
                        baud_cnt <= 13'd0;
                        tx_out <= tx_data[bit_idx]; // send data bit
                        
                        if (bit_idx == 3'd7) begin
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
                        tx_out <= ^tx_data; // parity bit send to rx_in
                        state <= STOP;
                    end else begin
                        baud_cnt <= baud_cnt + 1'b1;
                    end
                end
                
                STOP: begin 
                    if (baud_cnt == BIT_TICK) begin // wait full bit duration
                        baud_cnt <= 13'd0;
                        tx_out <= 1'b1; // stop bit
                        state <= IDLE;
                    end else begin
                        baud_cnt <= baud_cnt + 1'b1;
                    end
                end
                
                default: state <= IDLE;
            endcase
        end
    end
    
endmodule