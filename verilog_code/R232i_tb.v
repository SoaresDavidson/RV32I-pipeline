`timescale 1ns/1ps

module R232i_tb;

    // --- Sinais de Estímulo (controlam o DUT) ---
    reg clk;
    reg reset;
    reg [4:0] rs1, rs2, rd;
    reg       RegWrite;
    reg [1:0] sel;
    reg [4:0] IDEXrs1, IDEXrs2;
    reg [4:0] MEMWBrd, EXMEMrd;
    reg       EXMEM_RegWrite, MEMWB_RegWrite;

    // --- Sinais de Observação (vêm do DUT) ---
    wire [31:0] out_read_A, out_read_B, out_ULA_C;

    // --- Instanciação do DUT ---
    // (Assumindo que R232i.v, ULA.v, register_bank.v e forward_unit.v estão na mesma pasta)
    R232i dut (
        .clk(clk), .reset(reset), .rs1(rs1), .rs2(rs2), .rd(rd),
        .RegWrite(RegWrite), .sel(sel), .IDEXrs1(IDEXrs1), .IDEXrs2(IDEXrs2),
        .MEMWBrd(MEMWBrd), .EXMEMrd(EXMEMrd), .EXMEM_RegWrite(EXMEM_RegWrite),
        .MEMWB_RegWrite(MEMWB_RegWrite), .out_read_A(out_read_A),
        .out_read_B(out_read_B), .out_ULA_C(out_ULA_C)
    );

    // Geração de Clock
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Sequência de Teste Principal
    initial begin
        $dumpfile("waves.vcd");
        $dumpvars(0, R232i_tb);
        $monitor("Time=%0t | rst=%b | fwdA=%b fwdB=%b | rs1=%d rs2=%d | readA=%d readB=%d | ULA_C=%d",
                 $time, reset, dut.forwardA, dut.forwardB, rs1, rs2, out_read_A, out_read_B, out_ULA_C);
        $monitor("Time=%0t | MEMWB_regWrt=%b | fwdA=%b fwdB=%b | rs1=%d rs2=%d | readA=%d readB=%d | ULA_C=%d",
                 $time, reset, dut.forwardA, dut.forwardB, rs1, rs2, out_read_A, out_read_B, out_ULA_C);

        // --- Início dos Testes ---
        // 1. Reset
        reset = 1;
        #20;
        reset = 0;

        // 2. Setup: Forçar valores iniciais nos registradores para teste
        // Isso é necessário porque o datapath é um ciclo fechado.
        // Em uma simulação real, isso seria feito com instruções "load immediate".
        $display("\n--- SETUP: Forçando valores em x1 e x2 ---");
        force dut.reg_bank.registers[1] = 32'd100; // Força x1 = 100
        force dut.reg_bank.registers[2] = 32'd50;  // Força x2 = 50
        #10;
        release dut.reg_bank.registers[1]; // Libera os sinais
        release dut.reg_bank.registers[2];

        // 3. Teste Normal: add x3, x1, x2 (sem hazard)
        $display("\n--- TESTE 1: Operação Normal (add x3, x1, x2) ---");
        rs1=1; rs2=2; rd=3; RegWrite=1; sel=2'b00; // ADD
        IDEXrs1=1; IDEXrs2=2; // A instrução atual está no estágio ID
        EXMEMrd=9; MEMWBrd=8; // Nenhuma instrução recente escrevendo em x1 ou x2
        EXMEM_RegWrite=1; MEMWB_RegWrite=1;
        #10;
        // VERIFICAÇÃO: fwdA=00, fwdB=00. ULA_C deve ser 150. x3 será 150 no próximo ciclo.

        // 4. Teste de Hazard EX/MEM:
        // Anterior: add x3, x1, x2  (agora no estágio EX/MEM, resultado é 150)
        // Atual:    add x4, x3, x1  (precisa do resultado de x3)
        $display("\n--- TESTE 2: Hazard de EX/MEM (add x4, x3, x1) ---");
        rs1=3; rs2=1; rd=4; RegWrite=1; sel=2'b00; // ADD
        IDEXrs1=3; IDEXrs2=1;   // A instrução atual precisa de x3
        EXMEMrd=3; EXMEM_RegWrite=1; // A instrução anterior escreveu em x3! HAZARD!
        MEMWBrd=9; MEMWB_RegWrite=1;
        #10;
        // VERIFICAÇÃO: fwdA deve ser '10'. A ULA deve usar 150 (de ULA_C), não o valor antigo de x3.
        // O resultado deve ser 150 + 100 = 250. x4 será 250 no próximo ciclo.

        // 5. Teste de Hazard MEM/WB:
        // Há 2 ciclos: add x3, x1, x2 (agora no estágio MEM/WB)
        // Anterior:     add x4, x3, x1 (agora no estágio EX/MEM)
        // Atual:        add x5, x3, x2 (precisa de x3 de 2 ciclos atrás)
        $display("\n--- TESTE 3: Hazard de MEM/WB (add x5, x3, x2) ---");
        rs1=3; rs2=2; rd=5; RegWrite=1; sel=2'b00; // ADD
        IDEXrs1=3; IDEXrs2=2;    // A instrução atual precisa de x3
        EXMEMrd=4; EXMEM_RegWrite=1; // A instrução anterior escreveu em x4 (sem conflito)
        MEMWBrd=3; MEMWB_RegWrite=1; // A instrução de 2 ciclos atrás escreveu em x3! HAZARD!
        #10;
        // VERIFICAÇÃO: fwdA deve ser '01'. A ULA deve usar 150.
        // O resultado deve ser 150 + 50 = 200.

        // 6. Encerrar
        #50;
        $finish;
    end
endmodule