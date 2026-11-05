module rv32i_if_id_ex #(
    parameter logic [31:0] RESET_ADDRESS = 32'h80000000
)(
    input logic clk,
    input logic reset,
    input logic [31:0] instruction_in,
    input logic rf_external_we,
    input logic [4:0] rf_external_waddr,
    input logic [31:0] mem_out,
    input logic [1:0] memtoreg,
    output logic [31:0] pc,
    output logic [31:0] instruction,
    output logic [6:0] opcode,
    output logic [2:0] funct3,
    output logic [6:0] funct7,
    output logic [4:0] rs1,
    output logic [4:0] rs2,
    output logic [4:0] rd,
    output logic [31:0] rs1_data,
    output logic [31:0] rs2_data,
    output logic [31:0] immediate,
    output logic [31:0] alu_result,
    output logic [31:0] wb_data,
    output logic branch_taken,
    output logic redirect,
    output logic [31:0] redirect_target
);
    logic [31:0] pc_plus4;
    logic branch;
    logic jump;
    logic jump_register;
    logic use_immediate;

    rv32i_if_stage #(.RESET_ADDRESS(RESET_ADDRESS)) u_if_stage (
        .clk(clk), .reset(reset), .instruction_in(instruction_in),
        .redirect(redirect), .redirect_target(redirect_target),
        .pc(pc), .pc_plus4(pc_plus4), .instruction(instruction)
    );

    rv32i_id_stage u_id_stage (
        .clk(clk), .reset(reset), .instruction(instruction),
        .rf_external_we(rf_external_we),
        .rf_external_waddr(rf_external_waddr),
        .rf_external_wdata(wb_data),
        .opcode(opcode), .funct3(funct3), .funct7(funct7),
        .rs1(rs1), .rs2(rs2), .rd(rd),
        .rs1_data(rs1_data), .rs2_data(rs2_data),
        .immediate(immediate), .branch(branch), .jump(jump),
        .jump_register(jump_register), .use_immediate(use_immediate)
    );

    rv32i_ex_stage u_ex_stage (
        .pc(pc), .rs1_data(rs1_data), .rs2_data(rs2_data),
        .immediate(immediate), .opcode(opcode), .funct3(funct3),
        .funct7(funct7), .branch(branch), .jump(jump),
        .jump_register(jump_register), .use_immediate(use_immediate),
        .alu_result(alu_result), .branch_taken(branch_taken),
        .redirect(redirect), .redirect_target(redirect_target)
    );

    rv32i_wb_stage u_wb_stage (
        .mem_out(mem_out), .alu_out(alu_result), .memtoreg(memtoreg),
        .return_addr(pc_plus4), .imm_out(immediate),
        .pc_signed_offset(alu_result), .opcode_out_d(opcode),
        .wb_data(wb_data)
    );
endmodule
