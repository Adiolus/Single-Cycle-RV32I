module rv32i_ex_stage(input logic [31:0] pc,input logic [31:0] rs1_data,input logic [31:0] rs2_data,input logic [31:0] immediate,input logic [6:0] opcode,input logic [2:0] funct3,input logic [6:0] funct7,input logic branch,input logic jump,input logic jump_register,input logic use_immediate,output logic [31:0] alu_result,output logic branch_taken,output logic redirect,output logic [31:0] redirect_target);
logic [31:0] operand_a,operand_b,pc_relative_target,register_target,base_result,m_result;
logic [1:0] operand_a_select;
logic [3:0] alu_operation;
logic equal_operands,signed_less,unsigned_less,m_enable;
always_comb begin
case(opcode)
7'h17:operand_a_select=2'b01;
7'h37:operand_a_select=2'b10;
default:operand_a_select=2'b00;
endcase
end
rv32i_alu_source_mux u_alu_source_mux(.rs1_data(rs1_data),.pc(pc),.rs2_data(rs2_data),.immediate(immediate),.operand_a_select(operand_a_select),.use_immediate(use_immediate),.operand_a(operand_a),.operand_b(operand_b));
rv32i_alu_control u_alu_control(.opcode(opcode),.funct3(funct3),.funct7(funct7),.operation(alu_operation));
rv32i_alu u_alu(.operation(alu_operation),.operand_a(operand_a),.operand_b(operand_b),.result(base_result),.equal(equal_operands),.signed_less(signed_less),.unsigned_less(unsigned_less));
rv32m_control u_m_control(.opcode(opcode),.funct7(funct7),.m_enable(m_enable));
rv32m_alu u_m_alu(.enable(m_enable),.funct3(funct3),.operand_a(rs1_data),.operand_b(rs2_data),.result(m_result));
assign alu_result=m_enable?m_result:base_result;
always_comb begin
branch_taken=1'b0;
if(branch)case(funct3)
3'b000:branch_taken=equal_operands;
3'b001:branch_taken=!equal_operands;
3'b100:branch_taken=signed_less;
3'b101:branch_taken=!signed_less;
3'b110:branch_taken=unsigned_less;
3'b111:branch_taken=!unsigned_less;
default:branch_taken=1'b0;
endcase
end
assign redirect=jump||jump_register||(branch&&branch_taken);
assign pc_relative_target=pc+immediate;
assign register_target={alu_result[31:1],1'b0};
rv32i_mux_2x1 u_redirect_target_mux(.input_0(pc_relative_target),.input_1(register_target),.select(jump_register),.output_data(redirect_target));
endmodule
