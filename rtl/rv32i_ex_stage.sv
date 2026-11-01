module rv32i_ex_stage (
    input  logic [31:0] pc,
    input  logic [31:0] rs1_data,
    input  logic [31:0] rs2_data,
    input  logic [31:0] immediate,
    input  logic [6:0]  opcode,
    input  logic [2:0]  funct3,
    input  logic [6:0]  funct7,
    input  logic        branch,
    input  logic        jump,
    input  logic        jump_register,
    input  logic        use_immediate,
    output logic [31:0] alu_result,
    output logic        branch_taken,
    output logic        redirect,
    output logic [31:0] redirect_target
);
    logic [31:0] operand_a;
    logic [31:0] operand_b;
    logic [3:0] alu_operation;
    logic equal_operands;
    logic signed_less;
    logic unsigned_less;

    always_comb begin
        if (opcode == 7'h37)
            operand_a = 32'b0;
        else if (opcode == 7'h17)
            operand_a = pc;
        else
            operand_a = rs1_data;

        operand_b = use_immediate ? immediate : rs2_data;
    end

    rv32i_alu_control u_alu_control (
        .opcode(opcode),
        .funct3(funct3),
        .funct7(funct7),
        .operation(alu_operation)
    );

    rv32i_alu u_alu (
        .operation(alu_operation),
        .operand_a(operand_a),
        .operand_b(operand_b),
        .result(alu_result),
        .equal(equal_operands),
        .signed_less(signed_less),
        .unsigned_less(unsigned_less)
    );

    always_comb begin
        branch_taken = 1'b0;
        if (branch) begin
            case (funct3)
                3'b000: branch_taken = equal_operands;
                3'b001: branch_taken = !equal_operands;
                3'b100: branch_taken = signed_less;
                3'b101: branch_taken = !signed_less;
                3'b110: branch_taken = unsigned_less;
                3'b111: branch_taken = !unsigned_less;
                default: branch_taken = 1'b0;
            endcase
        end
    end

    always_comb begin
        redirect = jump || jump_register || (branch && branch_taken);
        if (jump_register)
            redirect_target = {alu_result[31:1], 1'b0};
        else
            redirect_target = pc + immediate;
    end
endmodule
