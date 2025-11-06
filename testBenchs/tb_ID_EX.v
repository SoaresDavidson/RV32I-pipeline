`timescale 1ns/1ps

module tb_ID_EX;

    reg clk;
    reg rst;
    reg enable;

    // sinais de entrada
    reg ula_in;
    reg mux_res_ula_in;
    reg mem_rd_in;
    reg mem_wr_in;
    reg reg_wr_in;
    reg mux_reg_wr_in;
    reg [31:0] imm_in;
    reg [4:0] rs1_in;
    reg [4:0] rs2_in;
    reg [4:0] rd_in;
    reg [6:0] funct7_in;
    reg [2:0] funct3_in;
    reg [31:0] val_A_in;
    reg [31:0] val_B_in;

    // sinais de saída
    wire ula_out;
    wire mux_res_ula_out;
    wire mem_rd_out;
    wire mem_wr_out;
    wire reg_wr_out;
    wire mux_reg_wr_out;
    wire [31:0] imm_out;
    wire [4:0] rs1_out;
    wire [4:0] rs2_out;
    wire [4:0] rd_out;
    wire [6:0] funct7_out;
    wire [2:0] funct3_out;
    wire [31:0] val_A_out;
    wire [31:0] val_B_out;

    // instancia DUT
    ID_EX dut (
        .ula_in(ula_in),
        .mux_res_ula_in(mux_res_ula_in),
        .mem_rd_in(mem_rd_in),
        .mem_wr_in(mem_wr_in),
        .reg_wr_in(reg_wr_in),
        .mux_reg_wr_in(mux_reg_wr_in),
        .imm_in(imm_in),
        .rs1_in(rs1_in),
        .rs2_in(rs2_in),
        .rd_in(rd_in),
        .funct7_in(funct7_in),
        .funct3_in(funct3_in),
        .val_A_in(val_A_in),
        .val_B_in(val_B_in),
        .clk(clk),
        .rst(rst),
        .enable(enable),
        .imm_out(imm_out),
        .rs1_out(rs1_out),
        .rs2_out(rs2_out),
        .rd_out(rd_out),
        .funct7_out(funct7_out),
        .funct3_out(funct3_out),
        .val_A_out(val_A_out),
        .val_B_out(val_B_out),
        .ula_out(ula_out),
        .mux_res_ula_out(mux_res_ula_out),
        .mem_rd_out(mem_rd_out),
        .mem_wr_out(mem_wr_out),
        .reg_wr_out(reg_wr_out),
        .mux_reg_wr_out(mux_reg_wr_out)
    );

    // clock de 10ns
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // estimulos
    initial begin
        $monitor("T=%0t | imm=%h rs1=%0d rs2=%0d rd=%0d funct7=%h funct3=%h valA=%h valB=%h | ula=%b muxRes=%b memRd=%b memWr=%b regWr=%b muxReg=%b",
                 $time, imm_out, rs1_out, rs2_out, rd_out, funct7_out, funct3_out, val_A_out, val_B_out,
                 ula_out, mux_res_ula_out, mem_rd_out, mem_wr_out, reg_wr_out, mux_reg_wr_out);

        // inicializacao
        rst = 1;
        enable = 0;
        {ula_in,mux_res_ula_in,mem_rd_in,mem_wr_in,reg_wr_in,mux_reg_wr_in} = 6'b0;
        imm_in = 32'h0;
        rs1_in = 5'b0;
        rs2_in = 5'b0;
        rd_in = 5'b0;
        funct7_in = 7'b0;
        funct3_in = 3'b0;
        val_A_in = 32'h0;
        val_B_in = 32'h0;

        #12 rst = 0;

        // Caso 1: enable=1, carrega valores
        enable = 1;
        imm_in = 32'hAAAA_BBBB;
        rs1_in = 5'd10;
        rs2_in = 5'd11;
        rd_in  = 5'd12;
        funct7_in = 7'h1F;
        funct3_in = 3'h3;
        val_A_in  = 32'h1111_1111;
        val_B_in  = 32'h2222_2222;
        ula_in = 1;
        mux_res_ula_in = 0;
        mem_rd_in = 1;
        mem_wr_in = 0;
        reg_wr_in = 1;
        mux_reg_wr_in = 1;
        #10;

        // Caso 2: enable=0, deve manter valores
        enable = 0;
        imm_in = 32'hDEAD_BEEF;
        rs1_in = 5'd1;
        rs2_in = 5'd2;
        rd_in  = 5'd3;
        #10;

        // Caso 3: reset limpa tudo
        rst = 1; #10;
        rst = 0; #10;

        $finish;
    end

endmodule

