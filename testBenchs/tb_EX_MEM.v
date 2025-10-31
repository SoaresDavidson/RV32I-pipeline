`timescale 1ns/1ps

module tb_EX_MEM;

    // Entradas
    reg clk;
    reg rst;
    reg enable;
    reg mem_rd_in;
    reg mem_wr_in;
    reg reg_wr_in;
    reg mux_reg_wr_in;
    reg [31:0] ula_res_in;
    reg [31:0] val_B_in;
    reg [4:0] rd_in;

    // Saídas
    wire mem_rd_out;
    wire mem_wr_out;
    wire reg_wr_out;
    wire mux_reg_wr_out;
    wire [31:0] ula_res_out;
    wire [31:0] val_B_out;
    wire [4:0] rd_out;

    // Instância do DUT (Device Under Test)
    EX_MEM uut (
        .clk(clk),
        .rst(rst),
        .enable(enable),
        .mem_rd_in(mem_rd_in),
        .mem_wr_in(mem_wr_in),
        .reg_wr_in(reg_wr_in),
        .mux_reg_wr_in(mux_reg_wr_in),
        .ula_res_in(ula_res_in),
        .val_B_in(val_B_in),
        .rd_in(rd_in),
        .mem_rd_out(mem_rd_out),
        .mem_wr_out(mem_wr_out),
        .reg_wr_out(reg_wr_out),
        .mux_reg_wr_out(mux_reg_wr_out),
        .ula_res_out(ula_res_out),
        .val_B_out(val_B_out),
        .rd_out(rd_out)
    );

    // Geração do clock
    always #5 clk = ~clk;

    // Estímulos
    initial begin
        $display("=== Testbench EX_MEM iniciado ===");
        
        // Inicialização
        clk = 0;
        rst = 1;
        enable = 0;
        mem_rd_in = 0;
        mem_wr_in = 0;
        reg_wr_in = 0;
        mux_reg_wr_in = 0;
        ula_res_in = 0;
        val_B_in = 0;
        rd_in = 0;

        // Reset ativo
        #10;
        rst = 0;

        // Teste 1: habilita escrita
        enable = 1;
        ula_res_in = 32'hAAAA_BBBB;
        val_B_in = 32'h1234_5678;
        rd_in = 5'd10;
        mem_rd_in = 1;
        mem_wr_in = 0;
        reg_wr_in = 1;
        mux_reg_wr_in = 0;
        #10;

        // Teste 2: altera valores
        ula_res_in = 32'hFFFF_0000;
        val_B_in = 32'h8765_4321;
        rd_in = 5'd5;
        mem_rd_in = 0;
        mem_wr_in = 1;
        reg_wr_in = 0;
        mux_reg_wr_in = 1;
        #10;

        // Teste 3: desabilita escrita (valores devem permanecer)
        enable = 0;
        ula_res_in = 32'hDEAD_BEEF;
        val_B_in = 32'hCAFE_F00D;
        rd_in = 5'd31;
        mem_rd_in = 1;
        mem_wr_in = 1;
        reg_wr_in = 1;
        mux_reg_wr_in = 1;
        #10;

        // Teste 4: aplica reset novamente
        rst = 1;
        #10;
        rst = 0;

        $display("=== Testbench finalizado ===");
        $stop;
    end

endmodule

