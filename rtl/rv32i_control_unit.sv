module rv32i_control_unit (
    input  logic [6:0] opcode,
    output logic       branch,
    output logic       jump,
    output logic       jump_register,
    output logic       use_immediate
);
    always_comb begin
        branch = 1'b0;
        jump = 1'b0;
        jump_register = 1'b0;
        use_immediate = 1'b0;

        case (opcode)
            7'h13, 7'h03, 7'h23, 7'h37, 7'h17: use_immediate = 1'b1;
            7'h63: branch = 1'b1;
            7'h6f: begin
                jump = 1'b1;
                use_immediate = 1'b1;
            end
            7'h67: begin
                jump_register = 1'b1;
                use_immediate = 1'b1;
            end
            default: begin
                branch = 1'b0;
                jump = 1'b0;
                jump_register = 1'b0;
                use_immediate = 1'b0;
            end
        endcase
    end
endmodule
