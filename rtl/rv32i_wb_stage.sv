module rv32i_wb_stage (
    input logic [31:0] mem_out,
    input logic [31:0] alu_out,
    input logic [1:0] memtoreg,
    input logic [31:0] return_addr,
    input logic [31:0] imm_out,
    input logic [31:0] pc_signed_offset,
    input logic [6:0] opcode_out_d,
    output logic [31:0] wb_data
);
    logic [1:0] u_control;
    logic [31:0] special_data;

    rv32i_wb_control_gen u_control_gen (
        .opcode_out_d(opcode_out_d),
        .u_control(u_control)
    );

    rv32i_mux_3x1 u_special_data_mux (
        .input_0(return_addr),
        .input_1(imm_out),
        .input_2(pc_signed_offset),
        .select(u_control),
        .output_data(special_data)
    );

    rv32i_mux_3x1 u_writeback_mux (
        .input_0(alu_out),
        .input_1(mem_out),
        .input_2(special_data),
        .select(memtoreg),
        .output_data(wb_data)
    );
endmodule
