module clk_div #(parameter MAX = 50000000) 
(
    input clk,
    input rst,
    output reg p_sec
);  
    reg [26:0] cnt;
    
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            cnt <= 0;
            p_sec <= 0;
        end else if (cnt == MAX - 1) begin
            cnt <= 0;
            p_sec <= 1;
        end else begin
            cnt <= cnt + 1;
            p_sec <= 0;
        end
    end
endmodule