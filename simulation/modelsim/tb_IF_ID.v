`timescale 1ns/1ps

module tb_IF_ID;

    reg clk;
    reg rst;
    reg enable;
    reg [31:0] instruction;

    wire [6:0] opcode;
    wire [4:0] rd;
    wire [4:0] rs1;
    wire [4:0] rs2;
    wire [2:0] funct3;
    wire [6:0] funct7;
    wire [11:0] imm_I;
    wire [11:0] imm_S;
    wire [11:0] imm_B;
    wire [19:0] imm_U;
    wire [19:0] imm_J;

    // Instancia o DUT
    IF_ID dut (
        .instruction(instruction),
        .clk(clk),
        .rst(rst),
        .enable(enable),
        .opcode(opcode),
        .rd(rd),
        .rs1(rs1),
        .rs2(rs2),
        .funct3(funct3),
        .funct7(funct7),
        .imm_I(imm_I),
        .imm_S(imm_S),
        .imm_B(imm_B),
        .imm_U(imm_U),
        .imm_J(imm_J)
    );

    // Clock de 10 ns
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Estímulos
    initial begin
        // Monitorar
        $monitor("T=%0t | instr=%h | opcode=%h rd=%0d rs1=%0d rs2=%0d funct3=%h funct7=%h imm_I=%h imm_S=%h imm_B=%h imm_U=%h imm_J=%h",
                 $time, instruction, opcode, rd, rs1, rs2, funct3, funct7, imm_I, imm_S, imm_B, imm_U, imm_J);

        // Inicialização
        rst = 1;
        enable = 0;
        instruction = 32'b0;
        #12;

        // Libera reset
        rst = 0;

        // Caso 1: ADD x5, x6, x7 -> opcode=0110011 funct3=000 funct7=0000000
        instruction = 32'b0000000_00111_00110_000_00101_0110011; 
        enable = 1;
        #10;

        // Caso 2: ADDI x10, x11, 15 -> opcode=0010011 funct3=000
        instruction = 32'b0000000001111_01011_000_01010_0010011;
        #10;

        // Caso 3: BEQ x1, x2, offset -> opcode=1100011 funct3=000
        instruction = 32'b000000_00010_00001_000_00000_1100011;
        #10;

        // Caso 4: Enable desativado (registrador mantém valor anterior)
        enable = 0;
        instruction = 32'hFFFFFFFF;
        #10;

        // Caso 5: Reset novamente
        rst = 1;
        #10;
        rst = 0;
        #10;

        $finish;
    end

endmodule
