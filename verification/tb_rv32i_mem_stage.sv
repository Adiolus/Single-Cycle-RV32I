module tb_rv32i_mem_stage;
    logic [31:0] address, store_data, memory_read_data;
    logic [2:0] funct3;
    logic mem_read, mem_write;
    logic [31:0] memory_address, memory_write_data, load_data;
    logic [3:0] byte_write_enable;
    logic memory_read_enable, access_valid;
    integer passed, failed;

    rv32i_mem_stage dut(.*);

    task automatic check(input string label, input logic [31:0] expected);
        begin
            #1;
            if (load_data === expected && access_valid) begin
                passed++;
                $display("PASS: %s = %08h", label, load_data);
            end else begin
                failed++;
                $display("FAIL: %s expected=%08h got=%08h valid=%b",
                         label, expected, load_data, access_valid);
            end
        end
    endtask

    initial begin
        passed = 0; failed = 0;
        address = 32'h1000;
        store_data = 0;
        memory_read_data = 32'h80ff7f01;
        mem_read = 1; mem_write = 0;

        funct3 = 3'b000; address = 32'h1000;
        check("LB byte 0", 32'h00000001);
        funct3 = 3'b000; address = 32'h1003;
        check("LB signed byte 3", 32'hffffff80);
        funct3 = 3'b100; address = 32'h1003;
        check("LBU byte 3", 32'h00000080);
        funct3 = 3'b001; address = 32'h1000;
        check("LH lower half", 32'h00007f01);
        funct3 = 3'b101; address = 32'h1002;
        check("LHU upper half", 32'h000080ff);
        funct3 = 3'b010; address = 32'h1000;
        check("LW", 32'h80ff7f01);

        mem_read = 0; mem_write = 1;
        funct3 = 3'b000; address = 32'h1002; store_data = 32'h123456aa;
        #1;
        if (byte_write_enable == 4'b0100 &&
            memory_write_data == 32'haaaaaaaa) begin
            passed++; $display("PASS: SB lane and replicated data");
        end else begin failed++; $display("FAIL: SB lane/data"); end

        funct3 = 3'b001; address = 32'h1002; store_data = 32'h1234abcd;
        #1;
        if (byte_write_enable == 4'b1100 &&
            memory_write_data == 32'habcdabcd) begin
            passed++; $display("PASS: SH upper halfword");
        end else begin failed++; $display("FAIL: SH lane/data"); end

        funct3 = 3'b010; address = 32'h1000; store_data = 32'hdeadbeef;
        #1;
        if (byte_write_enable == 4'b1111 &&
            memory_write_data == 32'hdeadbeef) begin
            passed++; $display("PASS: SW");
        end else begin failed++; $display("FAIL: SW"); end

        $display("MEM STAGE TESTS: %0d passed, %0d failed", passed, failed);
        if (failed != 0) $fatal(1, "MEM stage tests failed");
        $finish;
    end
endmodule
