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
        $readmemb("testBenchs/binarios/Testes/testes.bin", dut.im.instruction_memory);
        // $readmemb("testbenchs/binarios/Exemplos/program.bin", dut.im.instruction_memory);
        // $readmemb("testbenchs/binarios/Exemplos/flush.bin", dut.im.instruction_memory);

        $readmemb("testbenchs/binarios/memoria.bin", dut.m_m.memory);
        // assign dut.reg_bank.registers[1] = 32'd10;
        //assign dut.reg_bank.registers[2] = 32'd20;

        // assign dut.m_m.memory[0] = 8'b1000;
        // assign dut.m_m.memory[1] = 8'b1;
        // assign dut.m_m.memory[2] = 8'b0;
        // assign dut.m_m.memory[3] = 8'b1;

        // assign dut.m_m.memory[16] = 8'b1; 
        // assign dut.m_m.memory[17] = 8'b1; 
        // assign dut.m_m.memory[18] = 8'b1; 
        // assign dut.m_m.memory[19] = 8'b1; 

        // $monitor("Time=%0t | PC=%h | Instruction=%0b", $time, pc_out, out_instruction);
        // 5. Inicia o processador
        rst = 1;
        enable = 0;
        #20;
        rst = 0;
        enable = 1; // Habilita o processador
        #300;
        $finish;
    
    end

    // Use a borda de descida do clock para garantir que todos os valores
// do ciclo já foram calculados e registrados.
reg [7:0] tipo;
always @(negedge clk) begin
    // Não imprima nada durante o reset ou se o processador estiver desabilitado
    case (dut.IF_ID.opcode) 
        7'b0110011: tipo = "R";
        7'b0010011, 7'b0000011, 7'b1100111: tipo = "I";
        7'b0100011: tipo = "S";
        7'b1100011: tipo = "B";
        7'b1101111: tipo = "J";
        7'b0010111, 7'b0110111: tipo = "U";
        7'b1111111: begin
            $display("\n--- Simulação Finalizada ---");
            $finish; // Sinal fictício para terminar a simulação
        end
        default: tipo = "?";
    endcase
    if (rst == 0 && enable == 1) begin

        // --- CABEÇALHO DO CICLO ---
        // Adiciona um cabeçalho claro para cada ciclo de clock
        $display("\n//--------------------[ CICLO @ %0t ]--------------------//", $time);

        // --- ESTÁGIO IF ---
        $display("PC: %8h   |   Instruction: %32b", pc_out, out_instruction);
        
        // --- ESTÁGIO ID ---
        $display("-----------------------------------------------------------------");
        $display("  [IF/ID] Opcode: %7b | tipo: %c | rd: %2d, rs1: %2d, rs2: %2d", dut.IF_ID.opcode, tipo, dut.IF_ID.rd, dut.IF_ID.rs1, dut.IF_ID.rs2);
        $display("       Funct3: %3b  | Funct7: %7b | Salto?: %b", dut.IF_ID.funct3, dut.IF_ID.funct7, dut.branch_decider.Branch);
        $display("       Imm Gen: %8h", dut.imm_gen_output);
        $display("       RegBank Read -> rs1_value: %10d | rs2_value: %10d", dut.reg_bank.A, dut.reg_bank.B);

        // --- ESTÁGIO EX ---
        $display("-----------------------------------------------------------------");
        // Mostra os valores que SAEM do registrador ID/EX
        $display("  [ID/EX] Control -> RegWr: %b, MemRd: %b, MemWr: %b, MuxReg: %b, MuxULA: %b, ULAOp: %2b, PcULA: %b",
                 dut.ID_EX.reg_wr_out, dut.ID_EX.mem_rd_out, dut.ID_EX.mem_wr_out, dut.ID_EX.mux_reg_wr_out, dut.ID_EX.mux_ula_out, dut.ID_EX.ula_out, dut.ID_EX.pc_ula_out);
        $display("       Data    -> rs1_value: %10d | rs2_value: %10d | rd: %2d | imm: %h | pc: %h",
                 dut.ID_EX.val_A_out, dut.ID_EX.val_B_out, dut.ID_EX.rd_out, dut.ID_EX.imm_out, dut.ID_EX.pc_out);
        $display("       Forward -> Fwd_1: %2b, Fwd_2: %2b", dut.fwd.forwardA, dut.fwd.forwardB);
        $display("       ULA -> A: %10d | B: %10d | C: %10d", dut.ULA.A, dut.ULA.B, dut.ULA.C);

        // --- ESTÁGIO MEM ---
        $display("-----------------------------------------------------------------");
        $display("  [EX/MEM] Control -> RegWr: %b, MemRd: %b, MemWr: %b, MuxReg: %b",
                  dut.EX_MEM.reg_wr_out, dut.EX_MEM.mem_rd_out, dut.EX_MEM.mem_wr_out, dut.EX_MEM.mux_reg_wr_out);
        $display("        Data    -> ULA_Res: %10d | val_B: %10d | rd: %2d",
                  dut.EX_MEM.ula_res_out, dut.EX_MEM.val_B_out, dut.EX_MEM.rd_out);
        
        // --- ESTÁGIO WB ---
        $display("-----------------------------------------------------------------");
        $display("  [MEM/WB] Control -> RegWr: %b, MuxReg: %b", dut.MEM_WB.reg_wr_out, dut.MEM_WB.mux_reg_wr_out);
        $display("       Data    -> ULA_Res: %10d | Mem_Data: %10d | rd: %2d",
                 dut.MEM_WB.ula_res_out, dut.MEM_WB.mem_res_out, dut.MEM_WB.rd_out);
        
        $display("-----------------------------------------------------------------");
        // $display("%d %d %d %d %d", dut.m_m.memory[0], dut.m_m.memory[1], dut.m_m.memory[2], dut.m_m.memory[3], dut.m_m.funct3);
        $display("reg0: %0d reg1: %0d reg2: %0d reg3: %0d reg4: %0d reg5: %0d reg6: %0d, reg7: %0d, reg8: %0d", dut.reg_bank.registers[0], dut.reg_bank.registers[1], dut.reg_bank.registers[2], dut.reg_bank.registers[3], dut.reg_bank.registers[4], dut.reg_bank.registers[5], dut.reg_bank.registers[6], dut.reg_bank.registers[7], dut.reg_bank.registers[8]);
        $display("mem0: %0d mem1: %0d mem2: %0d mem3: %0d mem4: %0d mem5: %0d mem6: %0d, mem7: %0d, mem8: %0d", dut.m_m.memory[0], dut.m_m.memory[1], dut.m_m.memory[2], dut.m_m.memory[3], dut.m_m.memory[4], dut.m_m.memory[5], dut.m_m.memory[6], dut.m_m.memory[7], dut.m_m.memory[8]);

    end
end


endmodule