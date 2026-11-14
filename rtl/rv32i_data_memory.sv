module rv32i_data_memory #(
    parameter logic [31:0] BASE_ADDR = 32'h80000000,
    parameter integer MEM_BYTES = 262144
) (
    input logic clk, reset,
    input logic [31:0] address, write_data,
    input logic [3:0] byte_write_enable,
    input logic read_enable,
    output logic [31:0] read_data
);
    logic [7:0] mem [0:MEM_BYTES-1];
    logic [31:0] aligned_address;
    logic [31:0] offset;
    integer lane;

    assign aligned_address = {address[31:2], 2'b00};
    assign offset = aligned_address - BASE_ADDR;

    always_comb begin
        read_data = 32'b0;
        if (read_enable && aligned_address >= BASE_ADDR &&
            (offset + 3) < MEM_BYTES) begin
            read_data = {mem[offset+3], mem[offset+2],
                         mem[offset+1], mem[offset]};
        end
    end

    always_ff @(posedge clk) begin
        if (!reset && aligned_address >= BASE_ADDR &&
            (offset + 3) < MEM_BYTES) begin
            for (lane = 0; lane < 4; lane = lane + 1)
                if (byte_write_enable[lane])
                    mem[offset+lane] <= write_data[lane*8 +: 8];
        end
    end
endmodule
