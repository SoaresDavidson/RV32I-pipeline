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
        .mem_data_out(32'b0), // Memória de dados não implementada neste teste
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
        $readmemb("program.bin", dut.im.memory);
        // $monitor("Time=%0t | PC=%h | Instruction=%0b", $time, pc_out, out_instruction);
        // 5. Inicia o processador
        rst = 1;
        enable = 0;
        #20;
        rst = 0;
        enable = 1; // Habilita o processador

        // 6. Deixa a simulação rodar o programa por um tempo
        #100;
        $display("\n--- Simulação Finalizada ---");
        $finish;
    end

    always @(pc_out) begin
        $display("Time=%0t | PC=%d | Instruction=%32b", $time, pc_out, out_instruction);
        $display("IFID --> Opcode: %7b | rs1: %0d | rs2: %0d | rd: %0d | funct3: %0b | funct7: %0b | imm_gen: %0b", 
        dut.IF_ID.opcode, dut.IF_ID.rs1, dut.IF_ID.rs2, dut.IF_ID.rd, dut.IF_ID.funct3, dut.IF_ID.funct7, dut.imm_gen_output);        
        $display("IDEX --> rs1: %0d | rs2: %0d | rd: %0d | imm: %0d | funct7: %0b | mem_rd: %0b | mem_wr: %0b | reg_wr: %0b | mux_reg_wr: %0b | mux_ula: %0b | ula_op: %0b",
        dut.ID_EX.rs1_out, dut.ID_EX.rs2_out, dut.ID_EX.rd_out, dut.ID_EX.imm_out, dut.ID_EX.funct7_out, dut.ID_EX.mem_rd_out, dut.ID_EX.mem_wr_out, dut.ID_EX.reg_wr_out, dut.ID_EX.mux_reg_wr_out, dut.ID_EX.mux_ula_out, dut.ID_EX.ula_out);
        $display("EXMEM --> rd: %0d | ula_res: %0d | val_B: %0d | mem_rd: %0b | mem_wr: %0b | reg_wr: %0b | mux_reg_wr: %0b",
        dut.EX_MEM.rd_out, dut.EX_MEM.ula_res_out, dut.EX_MEM.val_B_out, dut.EX_MEM.mem_rd_out, dut.EX_MEM.mem_wr_out, dut.EX_MEM.reg_wr_out, dut.EX_MEM.mux_reg_wr_out);
        $display("MEMWB --> ");
        // $display("EXMEM --> rd: %0d | ula_res: %0d
        $display("===================================================================================================\n");
    end

endmodule