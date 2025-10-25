module ULA (
		input [31:0]A,
		input [31:0]B,
		input [3:0]ula_op, 
		output reg [31:0]C,
		output reg z
);

//soma, and, or, transparencia
	always @(*) begin
		case (ula_op)
		  4'b0000: C <= A + B;
		  4'b0001: C <= A - B;
		  4'b0010: C <= A ^ B;
		  4'b0011: C <= A | B;
		  4'b0100: C <= A & B;
		  4'b0101: C <= A << B;
		  4'b0110: C <= A >> B;
		  4'b0111: C <= $signed(A) >>> B;
		  4'b1000: C <= ( $signed(A) < $signed(B) ) ? 32'b1 : 32'b0;
		  4'b1001: C <= ( A < B ) ? 32'b1 : 32'b0;
			default: C <= A;
		endcase	
		if (C == 0) begin
			z = 1;
		end else begin
			z = 0;
		end
	end
endmodule