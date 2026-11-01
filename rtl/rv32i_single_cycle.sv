module single_cycle_riscv #(
    parameter logic [31:0] RESET_ADDRESS = 32'h80000000
)(
    input  logic        clk,
    input  logic        reset,
    input  logic        stall,
    input  logic [31:0] instruction,
    input  logic [31:0] mem_out,
    output logic [31:0] rs2_data,
    output logic [31:0] alu_out,
    output logic        mem_write,
    output logic        mem_read,
    output logic [2:0]  fn3,
    output logic [6:0]  opcode,
    output logic [31:0] address,
    output logic [3:0]  mem_byte_enable,
    output logic [31:0] mem_write_data
);

    logic [6:0] funct7;
    logic [4:0] rs1_address;
    logic [4:0] rs2_address;
    logic [4:0] rd_address;
    logic [31:0] rs1_data;
    logic [31:0] immediate;
    logic [31:0] pc_plus_four;
    logic [31:0] next_pc;
    logic [31:0] alu_operand_a;
    logic [31:0] alu_operand_b;
    logic [31:0] alu_result;
    logic [31:0] shifted_memory_data;
    logic [31:0] load_result;
    logic [31:0] writeback_data;
    logic [3:0] alu_operation;
    logic [1:0] writeback_select;
    logic register_write;
    logic memory_read_control;
    logic memory_write_control;
    logic branch;
    logic jump;
    logic jump_register;
    logic use_immediate;
    logic equal_operands;
    logic signed_less;
    logic unsigned_less;
    logic branch_taken;
    logic register_write_enable;
    logic memory_access_valid;

    rv32i_decoder u_decoder (
        .instruction(instruction),
        .opcode(opcode),
        .funct3(fn3),
        .funct7(funct7),
        .rs1(rs1_address),
        .rs2(rs2_address),
        .rd(rd_address)
    );

    rv32i_immediate_unit u_immediate (
        .instruction(instruction),
        .opcode(opcode),
        .immediate(immediate)
    );

    rv32i_control_unit u_control (
        .opcode(opcode),
        .register_write(register_write),
        .memory_read(memory_read_control),
        .memory_write(memory_write_control),
        .branch(branch),
        .jump(jump),
        .jump_register(jump_register),
        .use_immediate(use_immediate),
        .writeback_select(writeback_select)
    );

    rv32i_register_bank u_reg_bank (
        .clk(clk),
        .reset(reset),
        .write_enable(register_write_enable),
        .read_address_a(rs1_address),
        .read_address_b(rs2_address),
        .write_address(rd_address),
        .write_data(writeback_data),
        .read_data_a(rs1_data),
        .read_data_b(rs2_data)
    );

    rv32i_alu_control u_alu_control (
        .opcode(opcode),
        .funct3(fn3),
        .funct7(funct7),
        .operation(alu_operation)
    );

    always_comb begin
        if (opcode == 7'h37)
            alu_operand_a = 32'b0;
        else if (opcode == 7'h17)
            alu_operand_a = address;
        else
            alu_operand_a = rs1_data;

        alu_operand_b = use_immediate ? immediate : rs2_data;
    end

    rv32i_alu u_alu (
        .operation(alu_operation),
        .operand_a(alu_operand_a),
        .operand_b(alu_operand_b),
        .result(alu_result),
        .equal(equal_operands),
        .signed_less(signed_less),
        .unsigned_less(unsigned_less)
    );

    always_comb begin
        branch_taken = 1'b0;

        if (branch) begin
            case (fn3)
                3'b000: branch_taken = equal_operands;
                3'b001: branch_taken = !equal_operands;
                3'b100: branch_taken = signed_less;
                3'b101: branch_taken = !signed_less || equal_operands;
                3'b110: branch_taken = unsigned_less;
                3'b111: branch_taken = !unsigned_less || equal_operands;
                default: branch_taken = 1'b0;
            endcase
        end
    end

    assign pc_plus_four = address + 32'd4;

    always_comb begin
        if (jump_register)
            next_pc = {alu_result[31:1], 1'b0};
        else if (jump || (branch && branch_taken))
            next_pc = address + immediate;
        else
            next_pc = pc_plus_four;
    end

    rv32i_program_counter #(
        .RESET_ADDRESS(RESET_ADDRESS)
    ) u_pc (
        .clk(clk),
        .reset(reset),
        .hold(stall),
        .next_address(next_pc),
        .current_address(address)
    );

    assign shifted_memory_data = mem_out >> {alu_result[1:0], 3'b000};

    always_comb begin
        load_result = 32'b0;

        case (fn3)
            3'b000: load_result = {{24{shifted_memory_data[7]}}, shifted_memory_data[7:0]};
            3'b001: load_result = {{16{shifted_memory_data[15]}}, shifted_memory_data[15:0]};
            3'b010: load_result = mem_out;
            3'b100: load_result = {24'b0, shifted_memory_data[7:0]};
            3'b101: load_result = {16'b0, shifted_memory_data[15:0]};
            default: load_result = 32'b0;
        endcase
    end

    always_comb begin
        memory_access_valid = 1'b1;

        if (memory_read_control) begin
            case (fn3)
                3'b000, 3'b100: memory_access_valid = 1'b1;
                3'b001, 3'b101: memory_access_valid = !alu_result[0];
                3'b010: memory_access_valid = (alu_result[1:0] == 2'b00);
                default: memory_access_valid = 1'b0;
            endcase
        end else if (memory_write_control) begin
            case (fn3)
                3'b000: memory_access_valid = 1'b1;
                3'b001: memory_access_valid = !alu_result[0];
                3'b010: memory_access_valid = (alu_result[1:0] == 2'b00);
                default: memory_access_valid = 1'b0;
            endcase
        end
    end

    always_comb begin
        mem_byte_enable = 4'b0000;
        mem_write_data = rs2_data << {alu_result[1:0], 3'b000};

        if (memory_write_control && !stall && memory_access_valid) begin
            case (fn3)
                3'b000: mem_byte_enable = 4'b0001 << alu_result[1:0];
                3'b001: mem_byte_enable = 4'b0011 << alu_result[1:0];
                3'b010: mem_byte_enable = 4'b1111;
                default: mem_byte_enable = 4'b0000;
            endcase
        end
    end

    assign mem_read = memory_read_control && !stall && memory_access_valid;
    assign mem_write = memory_write_control && !stall && memory_access_valid && (|mem_byte_enable);
    assign register_write_enable = register_write && !stall && !(memory_read_control && !memory_access_valid);
    assign alu_out = alu_result;

    always_comb begin
        case (writeback_select)
            2'b00: writeback_data = alu_result;
            2'b01: writeback_data = load_result;
            2'b10: writeback_data = pc_plus_four;
            default: writeback_data = 32'b0;
        endcase
    end

endmodule
