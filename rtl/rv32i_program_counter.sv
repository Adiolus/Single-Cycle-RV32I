module rv32i_program_counter #(
    parameter logic [31:0] RESET_ADDRESS = 32'h80000000
)(
    input  logic        clk,
    input  logic        reset,
    input  logic        hold,
    input  logic [31:0] next_address,
    output logic [31:0] current_address
);

    always_ff @(posedge clk or posedge reset) begin
        if (reset)
            current_address <= RESET_ADDRESS;
        else if (!hold)
            current_address <= next_address;
    end

endmodule
