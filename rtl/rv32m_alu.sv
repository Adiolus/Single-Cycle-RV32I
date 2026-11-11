module rv32m_alu(input logic enable,input logic [2:0] funct3,input logic [31:0] operand_a,input logic [31:0] operand_b,output logic [31:0] result);
logic signed [63:0] product_ss;
logic signed [64:0] product_su;
logic [63:0] product_uu;
logic signed [31:0] quotient_s,remainder_s;
logic [31:0] quotient_u,remainder_u;
always_comb begin
product_ss=$signed(operand_a)*$signed(operand_b);
product_su=$signed({operand_a[31],operand_a})*$signed({1'b0,operand_b});
product_uu=operand_a*operand_b;
if(operand_b==0)begin
quotient_s=32'hffffffff;
remainder_s=operand_a;
quotient_u=32'hffffffff;
remainder_u=operand_a;
end else begin
quotient_s=$signed(operand_a)/$signed(operand_b);
remainder_s=$signed(operand_a)%$signed(operand_b);
quotient_u=operand_a/operand_b;
remainder_u=operand_a%operand_b;
end
if(operand_a==32'h80000000&&operand_b==32'hffffffff)begin
quotient_s=32'h80000000;
remainder_s=32'b0;
end
result=32'b0;
if(enable)case(funct3)
3'b000:result=product_uu[31:0];
3'b001:result=product_ss[63:32];
3'b010:result=product_su[63:32];
3'b011:result=product_uu[63:32];
3'b100:result=quotient_s;
3'b101:result=quotient_u;
3'b110:result=remainder_s;
3'b111:result=remainder_u;
default:result=32'b0;
endcase
end
endmodule
