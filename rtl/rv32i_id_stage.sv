module rv32i_id_stage (
    input  logic        clk,
    input  logic        reset,
    input  logic [31:0] instruction,
    input  logic        rf_external_we,
    input  logic [4:0]  rf_external_waddr,
    input  logic [31:0] rf_external_wdata,
    output logic [6:0]  opcode,
    output logic [2:0]  funct3,
    output logic [6:0]  funct7,
    output logic [4:0]  rs1,
    output logic [4:0]  rs2,
    output logic [4:0]  rd,
    output logic [31:0] rs1_data,
    output logic [31:0] rs2_data,
    output logic [31:0] immediate,
    output logic        branch,
    output logic        jump,
    output logic        jump_register,
    output logic        use_immediate
);
    rv32i_decoder u_decoder (
        .instruction(instruction),
        .opcode(opcode),
        .funct3(funct3),
        .funct7(funct7),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd)
    );

    rv32i_immediate_unit u_immediate (
        .instruction(instruction),
        .opcode(opcode),
        .immediate(immediate)
    );

    rv32i_control_unit u_control (
        .opcode(opcode),
        .branch(branch),
        .jump(jump),
        .jump_register(jump_register),
        .use_immediate(use_immediate)
    );

    rv32i_register_bank u_register_bank (
        .clk(clk),
        .reset(reset),
        .write_enable(rf_external_we),
        .read_address_a(rs1),
        .read_address_b(rs2),
        .write_address(rf_external_waddr),
        .write_data(rf_external_wdata),
        .read_data_a(rs1_data),
        .read_data_b(rs2_data)
    );
endmodule
