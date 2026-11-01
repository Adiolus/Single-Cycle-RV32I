module rv32i_pc_mux (
    input  logic [31:0] pc_plus4,
    input  logic [31:0] redirect_target,
    input  logic        redirect,
    output logic [31:0] next_pc
);
    rv32i_mux_2x1 u_pc_mux (
        .input_0(pc_plus4),
        .input_1(redirect_target),
        .select(redirect),
        .output_data(next_pc)
    );
endmodule
