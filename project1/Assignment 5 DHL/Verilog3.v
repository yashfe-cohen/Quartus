`timescale 1ns / 1ps

module tb_alu();

    reg [3:0] A;
    reg [3:0] B;
    reg [2:0] Op;
    wire [3:0] alu_out;

    alu uut (
        .A(A),
        .B(B),
        .Op(Op),
        .alu_out(alu_out)
    );

    initial begin
        $monitor("Time = %0t | A = %b | B = %b | Op = %b | alu_out = %b", 
                 $time, A, B, Op, alu_out);

        A = 4'b0101; 
        B = 4'b0011; 
        Op = 3'b000;
        #10;         

        Op = 3'b001; 
        #10;

        Op = 3'b010;
        #10;

        Op = 3'b011;
        #10;

        Op = 3'b100;
        #10;

        $finish;
    end

endmodule