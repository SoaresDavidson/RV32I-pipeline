module ProgramCounter (
  input wire Clk,
  input wire Reset,
  input wire Control,
  input wire Enable,
  input wire [31:0] Target,
  output reg [31:0] pc
);
  
  always @(posedge Clk or Reset) begin
    if (Reset == 1) begin
      pc <= 32'b0;
    end
    else if (Enable ==1) begin
      if (Control == 1) begin
        pc <= pc + Target;
      end
      else begin
        pc <= pc + 4;
      end
    end
  end
endmodule
    
      

