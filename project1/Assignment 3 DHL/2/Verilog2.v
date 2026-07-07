module cnt_9 (
    input clk,
    input rst,
    input en,
    output reg [3:0] val
);
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            val <= 0;
        end else if (en) begin
            if (val == 9) begin
                val <= 0;
            end else begin
                val <= val + 1;
            end
        end
    end
endmodule
