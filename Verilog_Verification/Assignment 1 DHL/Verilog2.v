`timescale 1ns / 1ps

module verilog2;

    reg tb_in;        
    wire tb_out;      

    Assignment1DHL uut (
        .in_bit(tb_in),
        .out_bit(tb_out)
    );

    initial begin
        $monitor("Time = %0t | Input = %b | Output = %b", $time, tb_in, tb_out);

        tb_in = 1'b0;
        #10; 
        
        tb_in = 1'b1;
        #10;
        
        tb_in = 1'b0;
        #10;

        $finish;
    end

endmodule