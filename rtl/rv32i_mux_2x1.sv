module rv32i_mux_2x1 (
    input  logic [31:0] input_0,
    input  logic [31:0] input_1,
    input  logic        select,
    output logic [31:0] output_data
);
    always_comb begin
        case (select)
            1'b0: output_data = input_0;
            1'b1: output_data = input_1;
            default: output_data = 32'b0;
        endcase
    end
endmodule
