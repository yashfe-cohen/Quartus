module ALU (
    input [3:0] A, B, // The magnitude of the numbers that can be added 
    input [2:0] Op, // How many actions can be performed
    output reg [3:0] alu_out // The ALU output matches the input size to fit the system's data bus and save hardware resources. Overflows are handled by a separate Carry flag.
	 // Overflow 
);

    always @(*) begin
        case (Op)
            3'b000: alu_out = 4'b0000;
            3'b001: alu_out = A + B;       
            3'b010: alu_out = A - B;       
            3'b011: alu_out = A & B;       
            3'b100: alu_out = A | B;       
            3'b101: alu_out = ~A;          
            3'b110: alu_out = ~B;          
            3'b111: alu_out = 4'b0000;
            default: alu_out = 4'b0000;
        endcase
    end

endmodule