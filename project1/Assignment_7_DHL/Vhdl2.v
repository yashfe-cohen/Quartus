`timescale 1ns / 1ps

module tb_top_level();

    reg clk;
    reg reset;
    
    reg start_a;
    reg [7:0] data_a;
    wire err_a;
    
    reg start_b;
    reg [7:0] data_b;
    wire err_b;

    // dut
    UART uut (
                                                                     .clk(clk),
                                                                     .reset(reset),
                                                                     .start_a(start_a),
                                                                     .data_a(data_a),
                                                                     .err_a(err_a),
                                                                     .start_b(start_b),
                                                                     .data_b(data_b),
                                                                     .err_b(err_b)
    );

    // clock gen (10ns period)
    always #5 clk = ~clk;

    initial begin
        // init
        clk = 0;
        reset = 1;
        start_a = 0;
        start_b = 0;
        
        // assignment data
        data_a = 8'b11010101;
        data_b = 8'b01001100;
        
        #20 reset = 0;
        
        // tx A
        #10 start_a = 1;
        #10 start_a = 0;
        
        #150; // wait for tx, The time it will take for all 11 bits of 'A' (including the stop bit) to travel along the wire.
        
        // tx B
        start_b = 1;
        #10 start_b = 0;
        
        #150; // wait for tx,  The time it will take for all 11 bits of 'B' (including the stop bit) to travel along the wire.
        
        $finish;
    end

endmodule