`default_nettype none
module RV32i(
    input wire clk,
    input wire rst,
    input wire enable,    
    //so para testes
    output wire [31:0] pc_out,
    output wire [31:0] out_instruction
);
  //program counter
  wire [31:0] pc;
  wire PCWrite;
  //instruction memory
  wire [31:0] instruction;
  //IF/ID
  wire IFIDWrite;
  wire [6:0] opcode; 
  wire [4:0] IFID_rd, IFID_rs1, IFID_rs2; //registadores de destino e fonte
  wire [2:0] funct3; 
  wire [6:0] funct7;
  wire [11:0] imm_I, imm_S, imm_B; //imediatos tipo I, S e B
  wire [19:0] imm_U, imm_J; //imediatos tipo U e J
  //sinais de controle
  wire mem_rd, mem_wr, reg_wr, mux_reg_wr, mux_ula, branch;
  wire [1:0]ula_op;
  //foward unit
  reg [31:0] forwarding_A, forwarding_B;
  //ID/EX
  wire IDEXmem_rd, IDEXmem_wr, IDEXreg_wr, IDEXmux_reg_wr, IDEXmux_ula;
  wire [1:0]IDEXula;
  wire [31:0] IDEXimm;
  wire [4:0] IDEXrs1, IDEXrs2, IDEXrd;
  wire [6:0] IDEXfunct7;
  wire [2:0] IDEXfunct3;
  wire [31:0] IDEXval_A, IDEXval_B;
  //Banco de registradores
  wire [31:0]read_A;
  wire [31:0]read_B;
  wire [31:0]ULA_C;
  //branch decider
  wire sinal_jump;
  // imm gen
  reg [31:0] imm_gen_output;
  //forward unit
  wire [1:0]forwardA;
  wire [1:0]forwardB;
  // hazard unit
  wire Jump;
  wire Bolha;
  wire Flush;
  //ULA
  wire z;
  //EX/MEM
  wire EXMEMmem_rd,EXMEMmem_wr, EXMEMreg_wr, EXMEMmux_reg_wr;
  wire [31:0] EXMEMula_res, EXMEMval_B;
  wire [4:0] EXMEMrd;
  //MEM/WB
  wire [4:0] MEMWBrd;
  wire MEMWBreg_wr, MEMWBmem_rd, MEMWBmem_wr, MEMWBmux_reg_wr;
  wire [31:0] MEMWBula_res, MEMWBmem_data;
  //main memory
  wire [31:0]MEMWBdata;
  //mux final
  assign pc_out = pc;
  assign out_instruction = instruction;

  PC dut_pc(
    .Clk(clk),
    .Reset(rst),
    .Control(sinal_jump),
    .Enable(enable),
    .PCWrite(PCWrite),
    .Target(imm_gen_output),
    .pc(pc)
  );

  instruction_memory im(
    .clk(clk),
    .addr(pc),
    .instruction(instruction),
    .jump_addr(imm_gen_output), 
    .we(1'b0), 
    .re(1'b1)
  );


  IF_ID IF_ID(
    .instruction(instruction),
    .clk(clk),
    .rst(rst),
    .Flush(Flush),
    .enable(enable),
    .IFIDWrite(IFIDWrite),
    .opcode(opcode),
    .rd(IFID_rd),
    .rs1(IFID_rs1),
    .rs2(IFID_rs2),
    .funct3(funct3),
    .funct7(funct7),
    .imm_I(imm_I),
    .imm_S(imm_S),
    .imm_B(imm_B),
    .imm_U(imm_U),
    .imm_J(imm_J)
  );

  control ctrl(
    .opcode(opcode),
    .mem_rd(mem_rd),
    .mem_wr(mem_wr),
    .reg_wr(reg_wr),
    .mux_reg_wr(mux_reg_wr),
    .mux_ula(mux_ula),
    .ula_op(ula_op),
    .branch(branch)
  );

  hazard_detection_unit hdu (
    .IDEX_MemRead(IDEXmem_rd),
    .IDEX_RegisterRt(IDEXrd),
    .IFID_Register1(IFID_rs1),
    .IFID_Register2(IFID_rs2),
    .Jump(sinal_jump), 
    .PCWrite(PCWrite),
    .IFIDWrite(IFIDWrite),
    .Bolha(Bolha),
    .Flush(Flush)
  );

  // imm gen
  always @(*) begin
    case (opcode)
      7'b0110011: imm_gen_output = {32{1'b0}}; // tipo R
      7'b0010011, 7'b0000011: imm_gen_output = {{20{imm_I[11]}}, imm_I}; //tipo I
      7'b0100011: imm_gen_output = {{20{imm_S[11]}}, imm_S}; //tipo S
      7'b1100011: imm_gen_output = {{19{imm_B[11]}}, imm_B, 1'b0}; //tipo B
      7'b1101111: imm_gen_output = {{12{imm_J[19]}}, imm_J}; //tipo J
      7'b0010111, 7'b0110111: imm_gen_output = {imm_U, 12'b0}; //tipo U
      default: imm_gen_output = 32'b0;
    endcase
  end
  //mudar para C receber do pipeline de MEMWB
  register_bank reg_bank (
    .clk(clk),
    .rst(rst),
    .rs1(IFID_rs1),
    .rs2(IFID_rs2),
    .rd(MEMWBrd),
    .RegWrite(MEMWBmem_wr),
    .C(MEMWBmux_reg_wr ? MEMWBmem_data : MEMWBula_res),
    .A(read_A),
    .B(read_B)
  );
  
  BranchDecider branch_decider(
    .opcode(opcode),
    .funct3(funct3),
    .rs1(read_A),
    .rs2(read_B),
    .imm(imm_B),
    .Branch(sinal_jump)
  );

  ID_EX ID_EX (
    .ula_in(~Bolha ? ula_op : 2'b0), // se for bolha, zera o sinal de controle
    .mux_ula_in(~Bolha ? mux_ula : 1'b0),
    .mem_rd_in(~Bolha ? mem_rd : 1'b0),
    .mem_wr_in(~Bolha ? mem_wr : 1'b0),
    .reg_wr_in(~Bolha ? reg_wr : 1'b0),
    .mux_reg_wr_in(~Bolha ? mux_reg_wr : 1'b0),
    .imm_in(imm_gen_output),
    .rs1_in(IFID_rs1),
    .rs2_in(IFID_rs2),
    .rd_in(IFID_rd),
    .funct7_in(funct7),
    .funct3_in(funct3),
    .val_A_in(read_A),
    .val_B_in(read_B),
    .clk(clk),
    .rst(rst),
    .enable(enable),
    .imm_out(IDEXimm),
    .rs1_out(IDEXrs1),
    .rs2_out(IDEXrs2),
    .rd_out(IDEXrd),
    .funct7_out(IDEXfunct7),
    .funct3_out(IDEXfunct3),
    .val_A_out(IDEXval_A),
    .val_B_out(IDEXval_B),
    .ula_out(IDEXula),
    .mux_ula_out(IDEXmux_ula),
    .mem_rd_out(IDEXmem_rd),
    .mem_wr_out(IDEXmem_wr),
    .reg_wr_out(IDEXreg_wr),
    .mux_reg_wr_out(IDEXmux_reg_wr)
  );
  //forward unit
  forward_unit fwd (
    .IDEXrs1(IDEXrs1),
    .IDEXrs2(IDEXrs2),
    .EXMEMrd(EXMEMrd),
    .MEMWBrd(MEMWBrd),
    .EXMEM_RegWrite(EXMEMreg_wr),
    .MEMWB_RegWrite(MEMWBreg_wr),
    .forwardA(forwardA),
    .forwardB(forwardB)
  );

  always @(*) begin
    case (forwardA)
        2'b00: forwarding_A = IDEXval_A; // Normal
        2'b10: forwarding_A = EXMEMula_res; // MEM/WB sei la não implementei isso ainda
        2'b01: forwarding_A = MEMWBmem_data; // EX/MEM
        default: forwarding_A = IDEXval_A;
    endcase
    case (forwardB)
        2'b00: begin 
            case (IDEXmux_ula)
              1'b0: forwarding_B = IDEXimm;
              1'b1: forwarding_B = IDEXval_B;
            endcase // Normal
          end
        2'b10: forwarding_B = EXMEMula_res; // MEM/WB sei la não implementei isso ainda
        2'b01: forwarding_B = MEMWBmem_data; // EX/MEM
        default: forwarding_B = IDEXval_B;
    endcase
  end

  ULA ULA ( 
    .A (forwarding_A),
    .B (forwarding_B),
		.C (ULA_C),
		.z (z),
		.sel (IDEXula)
	);

  EX_MEM EX_MEM(
    .mem_rd_in(IDEXmem_rd),
    .mem_wr_in(IDEXmem_wr),
    .reg_wr_in(IDEXreg_wr),
    .mux_reg_wr_in(IDEXmux_reg_wr),
    .ula_res_in(ULA_C),
    .val_B_in(IDEXval_B),
    .rd_in(IDEXrd),
    .clk(clk),
    .rst(rst),
    .enable(enable),
    .mem_rd_out(EXMEMmem_rd),
    .mem_wr_out(EXMEMmem_wr),
    .reg_wr_out(EXMEMreg_wr),
    .mux_reg_wr_out(EXMEMmux_reg_wr),
    .ula_res_out(EXMEMula_res),
    .val_B_out(EXMEMval_B),
    .rd_out(EXMEMrd)

  );
  //main memory
  main_memory m_m(
    .clk(clk),
    .memRead(EXMEMmem_rd),
    .memWrite(EXMEMmem_wr),
    .addr(EXMEMula_res),
    .writeData(EXMEMval_B),
    .data(MEMWBdata)
  );

  MEM_WB MEM_WB(
    .mem_rd_in(EXMEMmem_rd),
    .reg_wr_in(EXMEMreg_wr),
    .mux_reg_wr_in(EXMEMmux_reg_wr),
    .rd_in(EXMEMrd),
    .ula_res_in(EXMEMula_res),
    .mem_res_in(MEMWBdata), 
    .clk(clk),
    .rst(rst),
    .enable(enable),
    .mem_rd_out(MEMWBmem_rd),
    .reg_wr_out(MEMWBreg_wr),
    .mux_reg_wr_out(MEMWBmux_reg_wr),
    .ula_res_out(MEMWBula_res),
    .mem_res_out(MEMWBmem_data),
    .rd_out(MEMWBrd)
  );

  //falta a memoria :/

	always @(posedge clk) begin
    //IF/ID

    //ID/EX



    //EX/MEM

    //MEM/WB
  end
endmodule

