module instruction_memory(
    input clk,
    input [31:0] addr,
    input [31:0] jump_addr, // endereço de pulo
    input we, //write enable
    input re, //read enable
    output reg [31:0] instruction
);
    reg [31:0] memory [1023:0]; // memoria de instruções

    always @(*) begin
        if (we) begin //escrita
            memory[addr] = jump_addr;
        end
        else if (re) begin //leitura
            instruction = memory[addr >> 2];
        end
    end
endmodule