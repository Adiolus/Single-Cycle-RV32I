module tb_rv32m_compliance;
logic enable;
logic [2:0] funct3;
logic [31:0] a,b,result;
integer passed,failed;
rv32m_alu dut(.enable(enable),.funct3(funct3),.operand_a(a),.operand_b(b),.result(result));
task automatic check(input logic [2:0] f,input logic [31:0] x,input logic [31:0] y,input logic [31:0] expected);
begin
funct3=f;a=x;b=y;#1;
if(result===expected)passed=passed+1;
else begin failed=failed+1;$display("FAIL funct3=%b a=%h b=%h expected=%h actual=%h",f,x,y,expected,result);end
end
endtask
initial begin
enable=1;funct3=0;a=0;b=0;passed=0;failed=0;
check(3'b000,32'd7,32'd6,32'd42);
check(3'b001,32'hffffffff,32'd2,32'hffffffff);
check(3'b010,32'hffffffff,32'd2,32'hffffffff);
check(3'b011,32'hffffffff,32'hffffffff,32'hfffffffe);
check(3'b100,32'hfffffff9,32'd2,32'hfffffffd);
check(3'b101,32'hfffffff9,32'd2,32'h7ffffffc);
check(3'b110,32'hfffffff9,32'd2,32'hffffffff);
check(3'b111,32'hfffffff9,32'd2,32'd1);
check(3'b100,32'd17,32'd0,32'hffffffff);
check(3'b101,32'd17,32'd0,32'hffffffff);
check(3'b110,32'd17,32'd0,32'd17);
check(3'b111,32'd17,32'd0,32'd17);
check(3'b100,32'h80000000,32'hffffffff,32'h80000000);
check(3'b110,32'h80000000,32'hffffffff,32'd0);
$display("RV32M tests: %0d passed, %0d failed",passed,failed);
if(failed!=0)$fatal(1,"RV32M tests failed");
$finish;
end
endmodule
