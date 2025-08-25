module tb_ULA;
  
  reg [31:0]A;
  reg [31:0]B;
  wire [31:0]C;
  wire z;
  reg [1:0]sel;
  integer i;

  ULA dut ( .A (A),
            .B (B),
				.C (C),
				.z (z),
				.sel (sel)
	);
	
	initial begin
      $monitor ("[%0t] A=%32b B=%32b C=%32b sel=%2b, z=%1b", $time, A, B, C, sel, z);
		A <= 4'b1010;
		B <= 4'b0001;
		sel <= 2'b00;
		
		for (i = 0; i < 4; i=i+1) begin
		  #10 sel <= i;
		end
	end
endmodule
		