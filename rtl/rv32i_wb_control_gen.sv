module rv32i_wb_control_gen (
    input logic [6:0] opcode_out_d,
    output logic [1:0] u_control
);
    always_comb begin
        case (opcode_out_d)
            7'b1101111, 7'b1100111: u_control = 2'b00;
            7'b0110111: u_control = 2'b01;
            7'b0010111: u_control = 2'b10;
            default: u_control = 2'b00;
        endcase
    end
endmodule
