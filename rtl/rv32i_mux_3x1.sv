module rv32i_mux_3x1 (
    input  logic [31:0] input_0,
    input  logic [31:0] input_1,
    input  logic [31:0] input_2,
    input  logic [1:0]  select,
    output logic [31:0] output_data
);
    always_comb begin
        case (select)
            2'b00: output_data = input_0;
            2'b01: output_data = input_1;
            2'b10: output_data = input_2;
            default: output_data = 32'b0;
        endcase
    end
endmodule
