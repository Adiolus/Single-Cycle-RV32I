module rv32m_control(input logic [6:0] opcode,input logic [6:0] funct7,output logic m_enable);
assign m_enable=(opcode==7'h33)&&(funct7==7'b0000001);
endmodule
