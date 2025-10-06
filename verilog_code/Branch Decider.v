module BranchDecider (
  input wire [6:0] opcode,
  input wire [2:0] funct3,
  input wire [31:0] rs1,
  input wire [31:0] rs2,
  input wire [11:0] imm,
  output reg Branch,
  output reg [11:0] Deviation
);
  always @(*) begin
    if (opcode == 7b'1100011) begin
      
      if (funct3 == 3'b0) begin
        if (rs1 == rs2) begin
          Deviation <= imm;
          Branch <= 1'b1;
        end
        if (rs1 != rs2) begin
          Branch <= 1'b0;
        end
      end
      
      if (funct3 == 3'b001) begin
        if (rs1 != rs2) begin
          Deviation <= imm;
          Branch <= 1'b1;
        end
        if (rs1 == rs2) begin
          Branch <= 1'b0;
        end
      end
      
      if (funct3 == 3'b100) begin
        if (rs1 < rs2) begin
          Deviation <= imm;
          Branch <= 1'b1;
        end
        if (rs1 >= rs2) begin
          Branch <= 1'b0;
        end
      end
      
      if (funct3 == 3'b101) begin
        if (rs1 >= rs2) begin
          Deviation <= imm;
          Branch <= 1'b1;
        end
        if (rs1 < rs2) begin
          Branch <= 1'b0;
        end
      end
    end
  end
endmodule