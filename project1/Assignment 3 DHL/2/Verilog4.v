`timescale 1ns / 1ps

module tb_top_cnt;

    reg clk;
    reg rst;
    wire [3:0] out_val;

    top_cnt #(.FREQ(10)) uut (
        .clk(clk),
        .rst(rst),
        .out_val(out_val)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst = 1;
        
        #20;
        
        rst = 0;
        
        #5000;
        
        $finish;
    end

endmodule