
`timescale 1ns/1ps

module tb_MEM_WB;

    // Entradas
    reg clk;
    reg rst;
    reg enable;
    reg reg_wr_in;
    reg mux_reg_wr_in;
    reg [31:0] ula_res_in;
    reg [31:0] mem_res_in;

    // Saídas
    wire reg_wr_out;
    wire mux_reg_wr_out;
    wire [31:0] ula_res_out;
    wire [31:0] mem_res_out;

    // Instância do DUT (Device Under Test)
    MEM_WB uut (
        .clk(clk),
        .rst(rst),
        .enable(enable),
        .reg_wr_in(reg_wr_in),
        .mux_reg_wr_in(mux_reg_wr_in),
        .ula_res_in(ula_res_in),
        .mem_res_in(mem_res_in),
        .reg_wr_out(reg_wr_out),
        .mux_reg_wr_out(mux_reg_wr_out),
        .ula_res_out(ula_res_out),
        .mem_res_out(mem_res_out)
    );

    // Geração do clock
    always #5 clk = ~clk;

    // Estímulos
    initial begin
        $display("=== Testbench MEM_WB iniciado ===");
        $monitor("t=%0t | reg_wr=%b mux_reg_wr=%b ula_res=0x%h mem_res=0x%h",
                 $time, reg_wr_out, mux_reg_wr_out, ula_res_out, mem_res_out);

        // Inicialização
        clk = 0;
        rst = 1;
        enable = 0;
        reg_wr_in = 0;
        mux_reg_wr_in = 0;
        ula_res_in = 32'b0;
        mem_res_in = 32'b0;

        // Reset ativo
        #12;
        rst = 0;

        // Teste 1: escrita habilitada
        enable = 1;
        reg_wr_in = 1;
        mux_reg_wr_in = 0;
        ula_res_in = 32'hAAAA_BBBB;
        mem_res_in = 32'h1234_5678;
        #10;

        // Teste 2: novos valores
        reg_wr_in = 0;
        mux_reg_wr_in = 1;
        ula_res_in = 32'hFFFF_0000;
        mem_res_in = 32'h8765_4321;
        #10;

        // Teste 3: desabilita escrita (saídas devem se manter)
        enable = 0;
        reg_wr_in = 1;
        mux_reg_wr_in = 1;
        ula_res_in = 32'hDEAD_BEEF;
        mem_res_in = 32'hCAFE_F00D;
        #10;

        // Teste 4: aplica reset novamente
        rst = 1;
        #10;
        rst = 0;

        $display("=== Testbench finalizado ===");
        $stop;
    end

endmodule
