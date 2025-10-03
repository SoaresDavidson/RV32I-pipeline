module register_bank(
    input clk,
    input rst,
    input [4:0]rs1,
    input [4:0]rs2,
    input [4:0]rd,
    input RegWrite,
    input [31:0]C,
    output wire [31:0]A,
    output wire [31:0]B
);
    reg [31:0] registers [0:31];
    assign A = registers[rs1];
    assign B = registers[rs2];

    integer i;
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            // Inicializa todos os registradores com 0
            for (i = 0; i < 32; i = i + 1) begin
                registers[i] <= 32'b0;
            end
        end else if (RegWrite && (C != 5'b0)) begin
            registers[rd] <= C; // Escreve no registrador C se RegWrite estiver ativo e C não for o registrador zero
        end
    end

endmodule