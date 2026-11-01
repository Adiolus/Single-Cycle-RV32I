module rv32i_control_unit (
    input  logic [6:0] opcode,
    output logic       register_write,
    output logic       memory_read,
    output logic       memory_write,
    output logic       branch,
    output logic       jump,
    output logic       jump_register,
    output logic       use_immediate,
    output logic [1:0] writeback_select
);

    always_comb begin
        register_write = 1'b0;
        memory_read = 1'b0;
        memory_write = 1'b0;
        branch = 1'b0;
        jump = 1'b0;
        jump_register = 1'b0;
        use_immediate = 1'b0;
        writeback_select = 2'b00;

        case (opcode)
            7'h33: register_write = 1'b1;
            7'h13: begin
                register_write = 1'b1;
                use_immediate = 1'b1;
            end
            7'h03: begin
                register_write = 1'b1;
                memory_read = 1'b1;
                use_immediate = 1'b1;
                writeback_select = 2'b01;
            end
            7'h23: begin
                memory_write = 1'b1;
                use_immediate = 1'b1;
            end
            7'h63: branch = 1'b1;
            7'h6f: begin
                register_write = 1'b1;
                jump = 1'b1;
                writeback_select = 2'b10;
            end
            7'h67: begin
                register_write = 1'b1;
                jump_register = 1'b1;
                use_immediate = 1'b1;
                writeback_select = 2'b10;
            end
            7'h37: begin
                register_write = 1'b1;
                use_immediate = 1'b1;
            end
            7'h17: begin
                register_write = 1'b1;
                use_immediate = 1'b1;
            end
            default: begin
                register_write = 1'b0;
                memory_read = 1'b0;
                memory_write = 1'b0;
                branch = 1'b0;
                jump = 1'b0;
                jump_register = 1'b0;
                use_immediate = 1'b0;
                writeback_select = 2'b00;
            end
        endcase
    end

endmodule
