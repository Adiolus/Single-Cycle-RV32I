module rv32i_if_stage #(
    parameter logic [31:0] RESET_ADDRESS = 32'h80000000
)(
    input  logic        clk,
    input  logic        reset,
    input  logic [31:0] instruction_in,
    input  logic        redirect,
    input  logic [31:0] redirect_target,
    output logic [31:0] pc,
    output logic [31:0] pc_plus4,
    output logic [31:0] instruction
);
    logic [31:0] next_pc;

    assign pc_plus4 = pc + 32'd4;
    assign next_pc = redirect ? redirect_target : pc_plus4;
    assign instruction = instruction_in;

    rv32i_program_counter #(
        .RESET_ADDRESS(RESET_ADDRESS)
    ) u_pc (
        .clk(clk),
        .reset(reset),
        .hold(1'b0),
        .next_address(next_pc),
        .current_address(pc)
    );
endmodule
