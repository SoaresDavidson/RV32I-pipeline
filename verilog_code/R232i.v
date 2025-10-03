module R232i(
    input clk,
    input reset,
    input wire [4:0]rs1,
    input wire [4:0]rs2,
    input wire [4:0]rd,
    input wire RegWrite,
    input wire [1:0]sel,
    input [4:0]IDEXrs1,
    input [4:0]IDEXrs2,
    input [4:0]MEMWBrd,
    input [4:0]EXMEMrd,
    input EXMEM_RegWrite,
    input MEMWB_RegWrite,

    output wire [31:0] out_read_A,
    output wire [31:0] out_read_B,
    output wire [31:0] out_ULA_C
);
  //Banco de registradores
  wire [31:0]read_A;
  wire [31:0]read_B;
  wire [31:0]ULA_C;

  register_bank reg_bank (
    .clk(clk),
    .rst(reset),
    .rs1(rs1),
    .rs2(rs2),
    .rd(rd),
    .RegWrite(RegWrite),
    .C(ULA_C),
    .A(read_A),
    .B(read_B)
  );
  //todos esse sinais vão vir dos registradores de pipeline so estou com eles aqui 
  //para teste
  
  wire z;
  
  ULA ULA ( 
    .A (read_A),
    .B (read_B),
		.C (ULA_C),
		.z (z),
		.sel (sel)
	);
  assign out_read_A = read_A;
  assign out_read_B = read_B;
  assign out_ULA_C = ULA_C;

  wire [1:0]forwardA;
  wire [1:0]forwardB;

  forward_unit fwd (
    .IDEXrs1(IDEXrs1),
    .IDEXrs2(IDEXrs2),
    .EXMEMrd(EXMEMrd),
    .MEMWBrd(MEMWBrd),
    .EXMEM_RegWrite(EXMEM_RegWrite),
    .MEMWB_RegWrite(MEMWB_RegWrite),
    .forwardA(forwardA),
    .forwardB(forwardB)
  );

  reg [31:0]ULArs1;
  reg [31:0]ULArs2;
	always @(posedge clk) begin
    //IF/ID

    //ID/EX
    case (forwardA)
      2'b00: ULArs1 <= read_A ; // Normal
      2'b01: ULArs1 <= 32'h00000000 ; // EX/MEM
      2'b10: ULArs1 <= ULA_C; // MEM/WB sei la não implementei isso ainda
      default: ULArs1 <= read_A;
    endcase
    case (forwardB)
      2'b00: ULArs2 <= read_B; // Normal
      2'b01: ULArs2 <= 32'h00000000; // EX/MEM
      2'b10: ULArs2 <= ULA_C; // MEM/WB sei la não implementei isso ainda
      default: ULArs2 <= read_B;
    endcase


    //EX/MEM

    //MEM/WB
  end
endmodule
