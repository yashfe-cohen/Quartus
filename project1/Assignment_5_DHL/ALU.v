module ALU (
    input [3:0] A, B,
    input [2:0] Op,          // The selector chooses which operation the ALU performs
    output reg [3:0] alu_out
);

    // Operation set: maps the 3-bit selector to specific functions
    localparam OP_NOP   = 3'b000; // Do nothing
    localparam OP_ADD   = 3'b001; // Result = A + B
    localparam OP_SUB   = 3'b010; // Result = A - B
    localparam OP_AND   = 3'b011; // Bitwise AND
    localparam OP_OR    = 3'b100; // Bitwise OR
    localparam OP_NOT_A = 3'b101; // Bitwise NOT of A
    localparam OP_NOT_B = 3'b110; // Bitwise NOT of B
    localparam OP_RST   = 3'b111; // Force output to zero

    always @(*) begin
        case (Op)
            OP_NOP:   alu_out = 4'b0000;
            OP_ADD:   alu_out = A + B;
            OP_SUB:   alu_out = A - B;
            OP_AND:   alu_out = A & B;
            OP_OR:    alu_out = A | B;
            OP_NOT_A: alu_out = ~A;
            OP_NOT_B: alu_out = ~B;
            OP_RST:   alu_out = 4'b0000;
            default:  alu_out = 4'b0000;
        endcase
    end

endmodule