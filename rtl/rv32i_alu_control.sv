module rv32i_alu_control (
    input  logic [6:0] opcode,
    input  logic [2:0] funct3,
    input  logic [6:0] funct7,
    output logic [3:0] operation
);

    always_comb begin
        operation = 4'h0;

        case (opcode)
            7'h33: begin
                case (funct3)
                    3'b000: operation = (funct7 == 7'h20) ? 4'h1 : 4'h0;
                    3'b001: operation = 4'h2;
                    3'b010: operation = 4'h3;
                    3'b011: operation = 4'h4;
                    3'b100: operation = 4'h5;
                    3'b101: operation = (funct7 == 7'h20) ? 4'h7 : 4'h6;
                    3'b110: operation = 4'h8;
                    3'b111: operation = 4'h9;
                    default: operation = 4'h0;
                endcase
            end
            7'h13: begin
                case (funct3)
                    3'b000: operation = 4'h0;
                    3'b001: operation = 4'h2;
                    3'b010: operation = 4'h3;
                    3'b011: operation = 4'h4;
                    3'b100: operation = 4'h5;
                    3'b101: operation = (funct7 == 7'h20) ? 4'h7 : 4'h6;
                    3'b110: operation = 4'h8;
                    3'b111: operation = 4'h9;
                    default: operation = 4'h0;
                endcase
            end
            default: operation = 4'h0;
        endcase
    end

endmodule
