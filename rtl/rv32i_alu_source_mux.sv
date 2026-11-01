module rv32i_alu_source_mux (
    input  logic [31:0] rs1_data,
    input  logic [31:0] pc,
    input  logic [31:0] rs2_data,
    input  logic [31:0] immediate,
    input  logic [1:0]  operand_a_select,
    input  logic        use_immediate,
    output logic [31:0] operand_a,
    output logic [31:0] operand_b
);
    rv32i_mux_3x1 u_operand_a_mux (
        .input_0(rs1_data),
        .input_1(pc),
        .input_2(32'b0),
        .select(operand_a_select),
        .output_data(operand_a)
    );

    rv32i_mux_2x1 u_operand_b_mux (
        .input_0(rs2_data),
        .input_1(immediate),
        .select(use_immediate),
        .output_data(operand_b)
    );
endmodule
