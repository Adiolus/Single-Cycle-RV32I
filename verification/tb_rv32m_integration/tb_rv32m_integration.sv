
module tb_rv32m_integration;

logic [31:0] pc, rs1_data, rs2_data, immediate;
logic [6:0] opcode, funct7;
logic [2:0] funct3;
logic branch, jump, jump_register, use_immediate;
logic [31:0] alu_result, redirect_target;
logic branch_taken, redirect;
integer passed, failed;

rv32i_ex_stage dut(
    .pc(pc),
    .rs1_data(rs1_data),
    .rs2_data(rs2_data),
    .immediate(immediate),
    .opcode(opcode),
    .funct3(funct3),
    .funct7(funct7),
    .branch(branch),
    .jump(jump),
    .jump_register(jump_register),
    .use_immediate(use_immediate),
    .alu_result(alu_result),
    .branch_taken(branch_taken),
    .redirect(redirect),
    .redirect_target(redirect_target)
);

task automatic check(input string name, input logic [31:0] expected);
begin
    #1;
    if (alu_result === expected) begin
        passed = passed + 1;
        $display("PASS: %s | Result = %h", name, alu_result);
    end else begin
        failed = failed + 1;
        $display("FAIL: %s | Expected = %h, Got = %h",
                 name, expected, alu_result);
    end
end
endtask

initial begin
    passed = 0;
    failed = 0;
    pc = 32'h00001000;
    immediate = 0;
    branch = 0;
    jump = 0;
    jump_register = 0;
    use_immediate = 0;

    opcode = 7'h33;
    funct7 = 7'b0000001;
    rs1_data = 7;
    rs2_data = 6;
    funct3 = 3'b000;
    check("EX MUL", 32'd42);

    rs1_data = -7;
    rs2_data = 2;
    funct3 = 3'b100;
    check("EX DIV", 32'hfffffffd);

    funct3 = 3'b110;
    check("EX REM", 32'hffffffff);

    rs1_data = 32'hfffffff9;
    rs2_data = 2;
    funct3 = 3'b101;
    check("EX DIVU", 32'h7ffffffc);

    opcode = 7'h33;
    funct7 = 7'b0000000;
    funct3 = 3'b000;
    rs1_data = 7;
    rs2_data = 6;
    check("EX RV32I ADD", 32'd13);

    $display("--------------------------------");
    $display("EX INTEGRATION: %0d passed, %0d failed",
             passed, failed);
    $display("--------------------------------");

    if (failed != 0)
        $fatal(1, "Integration test failed");

    $finish;
end

endmodule
