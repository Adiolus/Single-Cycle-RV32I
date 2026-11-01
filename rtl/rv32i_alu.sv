module rv32i_alu (
    input  logic [3:0]  operation,
    input  logic [31:0] operand_a,
    input  logic [31:0] operand_b,
    output logic [31:0] result,
    output logic        equal,
    output logic        signed_less,
    output logic        unsigned_less
);

    always_comb begin
        equal = operand_a == operand_b;
        signed_less = $signed(operand_a) < $signed(operand_b);
        unsigned_less = operand_a < operand_b;
        result = 32'b0;

        case (operation)
            4'h0: result = operand_a + operand_b;
            4'h1: result = operand_a - operand_b;
            4'h2: result = operand_a << operand_b[4:0];
            4'h3: result = {31'b0, signed_less};
            4'h4: result = {31'b0, unsigned_less};
            4'h5: result = operand_a ^ operand_b;
            4'h6: result = operand_a >> operand_b[4:0];
            4'h7: result = $signed(operand_a) >>> operand_b[4:0];
            4'h8: result = operand_a | operand_b;
            4'h9: result = operand_a & operand_b;
            default: result = 32'b0;
        endcase
    end

endmodule
