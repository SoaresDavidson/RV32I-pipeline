`timescale 1ns / 1ps

module hazard_detection_unit_tb;

    // Entradas para o DUT
    reg       IDEX_MemRead;
    reg [4:0] IDEX_RegisterRt;
    reg [4:0] IFID_RegisterR1;
    reg [4:0] IFID_RegisterR2;

    // Saídas do DUT
    wire      PCWrite;
    wire      IFIDWrite;
    wire      Bolha;

    // Instanciação do Design Under Test (DUT)
    hazard_detection_unit dut (
       .IDEX_MemRead(IDEX_MemRead),
       .IDEX_RegisterRt(IDEX_RegisterRt),
       .IFID_RegisterR1(IFID_RegisterR1),
       .IFID_RegisterR2(IFID_RegisterR2),
       .PCWrite(PCWrite),
       .IFIDWrite(IFIDWrite),
      .Bolha(Bolha)
    );

    // Bloco de estímulo
    initial begin
        $display("Iniciando simulação do Hazard Detection Unit Testbench...");
        
        // Inicialização
        IDEX_MemRead  = 0;
        IDEX_RegisterRt = 5'd0;
        IFID_RegisterR1 = 5'd0;
        IFID_RegisterR2 = 5'd0;
        #10;

        // --- Caso de Teste 1: Sem Hazard (ADD -> SUB) ---
        $display("Caso 1: Sem Hazard");
        IDEX_MemRead  = 0; // ADD está em EX
        IDEX_RegisterRt = 5'd3;
        IFID_RegisterR1 = 5'd4; // SUB está em ID
        IFID_RegisterR2 = 5'd5;
        #10;

        // --- Caso de Teste 2: RAW ULA-ULA (ADD R3 -> SUB R4, R3) ---
        $display("Caso 2: RAW ULA-ULA (resolvido por forwarding)");
        IDEX_MemRead  = 0; // ADD está em EX
        IDEX_RegisterRt = 5'd3;
        IFID_RegisterR1 = 5'd3; // SUB está em ID, depende de R3
        IFID_RegisterR2 = 5'd5;
        #10;

        // --- Caso de Teste 3: Load-Use Hazard (LW R3 -> ADD R4, R3) ---
        $display("Caso 3: Load-Use Hazard (dependência em rs)");
        IDEX_MemRead  = 1; // LW está em EX
        IDEX_RegisterRt = 5'd3;
        IFID_RegisterR1 = 5'd3; // ADD está em ID, depende de R3
        IFID_RegisterR2 = 5'd5;
        #10;

        // --- Caso de Teste 4: Load-Use Hazard (LW R3 -> ADD R4, R5, R3) ---
        $display("Caso 4: Load-Use Hazard (dependência em rt)");
        IDEX_MemRead  = 1; // LW está em EX
        IDEX_RegisterRt = 5'd3;
        IFID_RegisterR1 = 5'd5; // ADD está em ID
        IFID_RegisterR2 = 5'd3; // Depende de R3
        #10;

        // --- Caso de Teste 5: Pós-Stall ---
        $display("Caso 5: Ciclo Pós-Stall (bolha em EX)");
        // A bolha (NOP) inserida está agora no estágio EX.
        IDEX_MemRead  = 0; // NOP não é um load
        IDEX_RegisterRt = 5'd0; // NOP não tem destino
        // A instrução ADD ainda está em ID
        IFID_RegisterR1 = 5'd3; 
        IFID_RegisterR2 = 5'd5;
        #10;

        // --- Caso de Teste 6: Caso de Borda (Load para r0) ---
        $display("Caso 6: Load para r0 (não deve causar stall)");
        IDEX_MemRead  = 1; // LW R0 está em EX
        IDEX_RegisterRt = 5'd0; // Destino é r0
        IFID_RegisterR1 = 5'd0; // ADD R4, R0 está em ID
        IFID_RegisterR2 = 5'd5;
        #10;

        $display("Simulação concluída.");
        $finish;
    end

endmodule