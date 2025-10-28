`timescale 1ns/1ps

module tb_RV32i;

    // --- Sinais de Estímulo ---
    reg clk;
    reg rst;
    reg enable;

    wire [31:0] pc_out;
    wire [31:0] out_instruction;


    RV32i dut (
        .clk(clk),
        .rst(rst),
        .enable(enable),
        .pc_out(pc_out),
        .out_instruction(out_instruction)
    );
    
    
    // --- Clock e Reset ---
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    // --- Sequência de Teste Principal ---
    initial begin
        // 4. Carrega o programa na memória ANTES de começar a simulação.
        $readmemb("binarios/tiposBasicos/load.bin", dut.im.instruction_memory);		  
        $readmemb("binarios/exemplos/program.bin", dut.m_m.memory);
        assign dut.reg_bank.registers[{31'b0, 1'b1}] = 0;
        assign dut.reg_bank.registers[{30'b0, 2'b10}] = 20;

        assign dut.m_m.memory[0] = 8'b1000;
        assign dut.m_m.memory[1] = 8'b1;
        assign dut.m_m.memory[2] = 8'b0;
        assign dut.m_m.memory[3] = 8'b1;

        assign dut.m_m.memory[16] = 8'b1; 
        assign dut.m_m.memory[17] = 8'b1; 
        assign dut.m_m.memory[18] = 8'b1; 
        assign dut.m_m.memory[19] = 8'b1; 

        // $monitor("Time=%0t | PC=%h | Instruction=%0b", $time, pc_out, out_instruction);
        // 5. Inicia o processador
        rst = 1;
        enable = 0;
        #20;
        rst = 0;
        enable = 1; // Habilita o processador

        // 6. Deixa a simulação rodar o programa por um tempo
        #70;
        $display("\n--- Simulação Finalizada ---");
        $finish;
    end

    // Use a borda de descida do clock para garantir que todos os valores
// do ciclo já foram calculados e registrados.
always @(negedge clk) begin
    // Não imprima nada durante o reset ou se o processador estiver desabilitado
    if (rst == 0 && enable == 1) begin

        // --- CABEÇALHO DO CICLO ---
        // Adiciona um cabeçalho claro para cada ciclo de clock
        $display("\n//--------------------[ CICLO @ %0t ]--------------------//", $time);

        // --- ESTÁGIO IF ---
        $display("PC: %8h   |   Instruction: %8h", pc_out, out_instruction);
        
        // --- ESTÁGIO ID ---
        $display("-----------------------------------------------------------------");
        $display("  [ID] Opcode: %7b | rd: %2d, rs1: %2d, rs2: %2d", dut.IF_ID.opcode, dut.IF_ID.rd, dut.IF_ID.rs1, dut.IF_ID.rs2);
        $display("       Funct3: %3b  | Funct7: %7b | Branch: %b", dut.IF_ID.funct3, dut.IF_ID.funct7, dut.branch_decider.Branch);
        $display("       Imm Gen: %8h", dut.imm_gen_output);
        $display("       RegBank Read -> A: %10d | B: %10d", dut.reg_bank.A, dut.reg_bank.B);

        // --- ESTÁGIO EX ---
        $display("-----------------------------------------------------------------");
        // Mostra os valores que SAEM do registrador ID/EX
        $display("  [EX] Control -> RegWr: %b, MemRd: %b, MemWr: %b, MuxReg: %b, MuxULA: %b, ULAOp: %2b, PcULA: %b",
                 dut.ID_EX.reg_wr_out, dut.ID_EX.mem_rd_out, dut.ID_EX.mem_wr_out, dut.ID_EX.mux_reg_wr_out, dut.ID_EX.mux_ula_out, dut.ID_EX.ula_out, dut.ID_EX.pc_ula_out);
        $display("       Data    -> val_A: %10d | val_B: %10d | rd: %2d | imm: %h | pc: %h",
                 dut.ID_EX.val_A_out, dut.ID_EX.val_B_out, dut.ID_EX.rd_out, dut.ID_EX.imm_out, dut.ID_EX.pc_out);
        $display("       Forward -> Fwd_A: %2b, Fwd_B: %2b", dut.fwd.forwardA, dut.fwd.forwardB);
        $display("       ULA Out -> C: %10d", dut.ULA.C);

        // --- ESTÁGIO MEM ---
        $display("-----------------------------------------------------------------");
        $display("  [MEM] Control -> RegWr: %b, MemRd: %b, MemWr: %b, MuxReg: %b",
                  dut.EX_MEM.reg_wr_out, dut.EX_MEM.mem_rd_out, dut.EX_MEM.mem_wr_out, dut.EX_MEM.mux_reg_wr_out);
        $display("        Data    -> ULA_Res: %10d | val_B: %10d | rd: %2d",
                  dut.EX_MEM.ula_res_out, dut.EX_MEM.val_B_out, dut.EX_MEM.rd_out);
        
        // --- ESTÁGIO WB ---
        $display("-----------------------------------------------------------------");
        $display("  [WB] Control -> RegWr: %b, MuxReg: %b", dut.MEM_WB.reg_wr_out, dut.MEM_WB.mux_reg_wr_out);
        $display("       Data    -> ULA_Res: %10d | Mem_Data: %10d | rd: %2d",
                 dut.MEM_WB.ula_res_out, dut.MEM_WB.mem_res_out, dut.MEM_WB.rd_out);
        
        $display("-----------------------------------------------------------------");
        $display("%d %d %d %d %d", dut.m_m.memory[0], dut.m_m.memory[1], dut.m_m.memory[2], dut.m_m.memory[3], dut.m_m.funct3);
    end
end


endmodule