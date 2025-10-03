`timescale 1ns/1ps

module R232i_tb;

    // --- Sinais de Estímulo (controlam o DUT) ---
    reg clk;
    reg reset;
    reg [4:0] rs1;
    reg [4:0] rs2;
    reg [4:0] rd;
    reg       RegWrite;
    reg [1:0] sel;

    input [4:0]IDEXrs1;
    input [4:0]IDEXrs2;
    input [4:0]MEMWBrd;
    input [4:0]EXMEMrd;
    input EXMEM_RegWrite;
    input MEMWB_RegWrite;
    // --- Sinais de Observação (vêm do DUT) ---
    wire [31:0] out_read_A;
    wire [31:0] out_read_B;
    wire [31:0] out_ULA_C;
    
    // --- Instanciação do Módulo sob Teste (DUT) ---
    R232i dut (
        .clk(clk), .reset(reset), .rs1(rs1), .rs2(rs2), .rd(rd),
        .RegWrite(RegWrite), .sel(sel),
        .out_read_A(out_read_A), .out_read_B(out_read_B), .out_ULA_C(out_ULA_C),
        .IDEXrs1(IDEXrs1), .IDEXrs2(IDEXrs2), .MEMWBrd(MEMWBrd), .EXMEMrd(EXMEMrd),
        .EXMEM_RegWrite(EXMEM_RegWrite), .MEMWB_RegWrite(MEMWB_RegWrite)
    );
    
    // --- Geração de Clock ---
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // Clock com período de 10ns
    end
    
    // --- Sequência de Teste Principal ---
    initial begin
    
        $monitor("Time=%0t | rst=%b | rs1=%d rs2=%d rd=%d | sel=%b RW=%b | readA=%d readB=%d ULA_C=%d | FA = %b FB = %b",
                 $time, reset, rs1, rs2, rd, sel, RegWrite, out_read_A, out_read_B, out_ULA_C, forwardA, forwardB);
        
        
        // // --- Início dos Testes ---
        // // 1. Reset do Sistema
        // reset = 1;
        // rs1 = 0; rs2 = 0; rd = 0; RegWrite = 0; sel = 0;
        // #20; // Mantém o reset por 20ns
        // reset = 0;
        // #1; // Espera um pouco após liberar o reset
        
        // // 2. Simular a escrita de um valor inicial em x1.
        // // Vamos fazer x1 = 0 + 100.
        // // Assumindo que x0 é sempre 0.
        // $display("\n--- TESTE 1: Escrevendo 100 no registrador x1 ---");
        // rs1 = 5'd0;       // Ler de x0 (que deve ser 0)
        // rs2 = 5'd0;       // Não usado, mas vamos ler de x0
        // rd  = 5'd1;       // Escrever em x1
        // sel = 2'b00;      // Assumindo que sel=00 é SOMA
        //                   // Para simular um "load immediate 100", precisaríamos de um MUX
        //                   // na entrada B da ULA. Vamos simular isso escrevendo x1 = x0 + x0
        //                   // e assumindo que a ULA pode ser forçada a produzir 100.
        //                   // Para este teste, vamos assumir que o resultado de C pode ser
        //                   // forçado para teste, ou que o banco já tem valores.
        //                   // Ação mais realista: testar uma operação R-type.
        
        // // CORREÇÃO PARA TESTE REALISTA: Vamos testar x3 = x1 + x2
        // // Primeiro, precisamos colocar valores em x1 e x2.
        // // Para isso, assumimos que a ULA pode passar um valor (ex: `sel`=pass B)
        // // e que podemos introduzir um valor. Como não podemos,
        // // vamos testar a lógica do que acontece se os registradores já tiverem valores.
        // // O testbench não pode popular os regs internos, então vamos verificar a leitura de x0
        
        // $display("\n--- TESTE 1: Verificando a leitura de x0 ---");
        // rs1 = 5'd0;
        // rs2 = 5'd0;
        // RegWrite = 0; // Apenas lendo
        // sel = 2'b00; // SOMA
        // #10;
        // // VERIFICAÇÃO: out_read_A e out_read_B devem ser 0. out_ULA_C deve ser 0.
        
        // $display("\n--- TESTE 2: Simular 'addi x1, x0, 123' ---");
        // // Em um processador real, um MUX escolheria um valor imediato. Como não o temos,
        // // vamos simular o resultado da ULA e escrevê-lo.
        // // O testador deve focar no que o MÓDULO PODE FAZER.
        // // O que ele faz é: ler, operar, escrever.
        
        // // Vamos testar a escrita em um registrador.
        // // Assumindo que x5 e x6 são 10 e 20 (pré-carregados na simulação)
        // // Isso não é possível, então vamos testar a escrita do resultado de x0 + x0.
        // $display("\n--- TESTE 2: Escrevendo x0+x0 em x3 ---");
        // rs1 = 5'd0;
        // rs2 = 5'd0;
        // rd  = 5'd3;  // Destino é x3
        // sel = 2'b00; // Operação de SOMA
        // RegWrite = 1; // HABILITA A ESCRITA!
        // #10; // No final deste ciclo, 0+0=0 é calculado. Na borda de subida, é escrito em x3.
        
        // RegWrite = 0; // Desabilita a escrita para o próximo ciclo
        
        // // 3. Verificar se o valor foi escrito
        // $display("\n--- TESTE 3: Verificando a escrita em x3 ---");
        // rs1 = 5'd3; // Agora vamos LER de x3
        // rs2 = 5'd0;
        // #10;
        // // VERIFICAÇÃO: Agora, out_read_A (vindo de x3) deve ser 0, o valor que escrevemos.
        
        // // 4. Encerrar simulação
        // #50;

    end

endmodule