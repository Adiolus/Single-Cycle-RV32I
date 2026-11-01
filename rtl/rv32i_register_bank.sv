module rv32i_register_bank (
    input  logic        clk,
    input  logic        reset,
    input  logic        write_enable,
    input  logic [4:0]  read_address_a,
    input  logic [4:0]  read_address_b,
    input  logic [4:0]  write_address,
    input  logic [31:0] write_data,
    output logic [31:0] read_data_a,
    output logic [31:0] read_data_b
);

    logic [31:0] registers [0:31];
    integer index;

    always_comb begin
        read_data_a = (read_address_a == 5'd0) ? 32'b0 : registers[read_address_a];
        read_data_b = (read_address_b == 5'd0) ? 32'b0 : registers[read_address_b];
    end

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            for (index = 0; index < 32; index = index + 1)
                registers[index] <= 32'b0;
        end else if (write_enable && (write_address != 5'd0)) begin
            registers[write_address] <= write_data;
        end
    end

endmodule
