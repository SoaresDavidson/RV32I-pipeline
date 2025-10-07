module control(
    input wire [6:0] opcode,
    // controle MEM
    output	wire mem_rd, //le memoria
	output	wire mem_wr, //escreve memoria

	// controle WB
	output	wire reg_wr, // escreve banco de reg
	output	wire mux_reg_wr, //mux do final

    // EX
    output   wire mux_ula, // mux da ula (rs2 ou imm)
    output   wire [1:0] ula_op, // escolhe operação

    output wire branch
);
case opcode 
    7'b0110011: begin //tipo R
        branch = 1'b0;
        mem_rd = 1'b0;
        mem_wr = 1'b0;
        ula_op = 2'b10; 
        reg_wr = 1'b1;
        mux_reg_wr = 1'b1; 
        mux_ula = 1'b0;
    end 
    7'b0010011: begin // tipo I
        branch = 1'b0;
        mem_rd = 1'b0;
        mem_wr = 1'b0;
        ula_op = ;
        reg_wr = 1'b1;
        mux_reg_wr = 1'b1; 
        mux_ula = 1'b1;
    end
    7'b0000011: begin // tipo I load
        branch = 1'b0;
        mem_rd = 1'b1;
        mem_wr = 1'b0;
        ula_op = ;
        reg_wr = 1'b1;
        mux_reg_wr = 1'b1; 
        mux_ula = 1'b1;
    end
    7'b0100011: begin // tipo S load
        branch = 1'b0;
        mem_rd = 1'b1;
        mem_wr = 1'b1;
        ula_op = 1'b00;
        reg_wr = 1'b0;
        mux_reg_wr = 1'b0; 
        mux_ula = 1'b1;
    end
    7'b1100011: begin // tipo B load
        branch = 1'b1;
        mem_rd = 1'b0;
        mem_wr = 1'b0;
        ula_op = 2'b01;
        reg_wr = 1'b1;
        mux_reg_wr = 1'b1; 
        mux_ula = 1'b1;
    end
    7'b0110111, 7'b0010111: begin // tipo U load
        branch = 1'b0;
        mem_rd = 1'b0;
        mem_wr = 1'b0;
        ula_op = 2'b;
        reg_wr = 1'b1;
        mux_reg_wr = 1'b1; 
        mux_ula = 1'b1;
    end
    7'b1101111: begin // tipo J load
        branch = 1'b1;
        mem_rd = 1'b0;
        mem_wr = 1'b0;
        ula_op = 2'b;
        reg_wr = 1'b1;
        mux_reg_wr = 1'b0; 
        mux_ula = 1'b1;
    end
endcase

endmodule