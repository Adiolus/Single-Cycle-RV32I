module rv32i_mem_stage (
    input logic [31:0] address, store_data,
    input logic [2:0] funct3,
    input logic mem_read, mem_write,
    input logic [31:0] memory_read_data,
    output logic [31:0] memory_address, memory_write_data,
    output logic [3:0] byte_write_enable,
    output logic memory_read_enable,
    output logic [31:0] load_data,
    output logic access_valid
);
    logic [7:0] selected_byte;
    logic [15:0] selected_half;

    always_comb begin
        memory_address = {address[31:2], 2'b00};
        memory_read_enable = mem_read;
        memory_write_data = 32'b0;
        byte_write_enable = 4'b0000;
        selected_byte = 8'b0;
        selected_half = 16'b0;
        load_data = 32'b0;
        access_valid = 1'b1;

        case (address[1:0])
            2'b00: selected_byte = memory_read_data[7:0];
            2'b01: selected_byte = memory_read_data[15:8];
            2'b10: selected_byte = memory_read_data[23:16];
            2'b11: selected_byte = memory_read_data[31:24];
        endcase

        if (address[1:0] == 2'b00)
            selected_half = memory_read_data[15:0];
        else if (address[1:0] == 2'b10)
            selected_half = memory_read_data[31:16];

        if (mem_read) begin
            case (funct3)
                3'b000: load_data = {{24{selected_byte[7]}}, selected_byte};
                3'b001: begin
                    if (!address[0])
                        load_data = {{16{selected_half[15]}}, selected_half};
                    else begin load_data = 0; access_valid = 0; end
                end
                3'b010: begin
                    if (address[1:0] == 0) load_data = memory_read_data;
                    else begin load_data = 0; access_valid = 0; end
                end
                3'b100: load_data = {24'b0, selected_byte};
                3'b101: begin
                    if (!address[0]) load_data = {16'b0, selected_half};
                    else begin load_data = 0; access_valid = 0; end
                end
                default: begin load_data = 0; access_valid = 0; end
            endcase
        end

        if (mem_write) begin
            case (funct3)
                3'b000: begin
                    memory_write_data = {4{store_data[7:0]}};
                    byte_write_enable = 4'b0001 << address[1:0];
                end
                3'b001: begin
                    if (!address[0]) begin
                        memory_write_data = {2{store_data[15:0]}};
                        byte_write_enable = address[1] ? 4'b1100 : 4'b0011;
                    end else access_valid = 0;
                end
                3'b010: begin
                    if (address[1:0] == 0) begin
                        memory_write_data = store_data;
                        byte_write_enable = 4'b1111;
                    end else access_valid = 0;
                end
                default: access_valid = 0;
            endcase
        end
    end
endmodule
