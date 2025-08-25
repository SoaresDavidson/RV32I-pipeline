module ULA (input [31:0]A,
           input [31:0]B,
			  input [1:0]sel, 
			  output reg [31:0]C,
			  output reg z
);

//soma, and, or, transparencia
	always @(*) begin
		case (sel)
		  4'b00: C <= A + B;
		  4'b01: C <= A & B;
		  4'b10: C <= A | B;
		  4'b11: C <= A;
			default: C <= A;
		endcase	
		if (C == 0) begin
			z = 1;
		end else begin
			z = 0;
		end
	end
endmodule