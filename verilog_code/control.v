module control(
    input wire [6:0] opcode,
    // controle MEM
    output	wire mem_rd, //le memoria
	output	wire mem_wr, //escreve memoria

	// controle WB
	output	wire reg_wr, // escreve banco de reg
	output	wire mux_reg_wr, //mux do final

    // EX
    output   wire jalReg,
	 output   wire jump,
	 output   wire mux_ula, // mux da ula (rs2 ou imm)
    output   wire [1:0] ula_op, // escolhe operação

    output wire branch
);
reg mem_rd_, mem_wr_, reg_wr_, mux_reg_wr_, mux_ula_, branch_, jalReg_, jump_;
reg [1:0] ula_op_;
assign mem_rd = mem_rd_;
assign mem_wr = mem_wr_;
assign reg_wr = reg_wr_;
assign mux_reg_wr = mux_reg_wr_;
assign mux_ula = mux_ula_;
assign branch = branch_;
assign ula_op = ula_op_;
assign jalReg = jalReg_;
assign jump = jump_;

always @(*) begin
    case (opcode)
        7'b0110011: begin //tipo R
            branch_ = 1'b0;
            mem_rd_ = 1'b0;
            mem_wr_ = 1'b0;
            ula_op_ = 2'b01; 
            reg_wr_ = 1'b1;
            mux_reg_wr_ = 1'b0; 
            mux_ula_ = 1'b0;
				jalReg_ = 1'b0;
				jump = 1'b0;
        end 
        7'b0010011: begin // tipo I
            branch_ = 1'b0;
            mem_rd_ = 1'b0;
            mem_wr_ = 1'b0;
            ula_op_ = 2'b00;
            reg_wr_ = 1'b1;
            mux_reg_wr_ = 1'b0; 
            mux_ula_ = 1'b1;
				jalReg_ = 1'b0;
				jump = 1'b0;
        end
        7'b0000011: begin // tipo I load
            branch_ = 1'b0;
            mem_rd_ = 1'b1;
            mem_wr_ = 1'b0;
            ula_op_ = 2'b00;
            reg_wr_ = 1'b1;
            mux_reg_wr_ = 1'b0; 
            mux_ula_ = 1'b1;
				jalReg_ = 1'b0;
				jump = 1'b0;
        end
		  7'b1100111: begin // tipo I jalReg
				branch_ = 1'b1;
            mem_rd_ = 1'b0;
            mem_wr_ = 1'b0;
            ula_op_ = 2'b00;
            reg_wr_ = 1'b0;
            mux_reg_wr_ = 1'b0; 
            mux_ula_ = 1'b0;
				jalReg_ = 1'b0;
				jump = 1'b0;
		  end
        7'b0100011: begin // tipo S load
            branch_ = 1'b0;
            mem_rd_ = 1'b1;
            mem_wr_ = 1'b1;
            ula_op_ = 2'b00;
            reg_wr_ = 1'b0;
            mux_reg_wr_ = 1'b1; 
            mux_ula_ = 1'b1;
				jalReg_ = 1'b0;
				jump = 1'b0;
        end
        7'b1100011: begin // tipo B load
            branch_ = 1'b1;
            mem_rd_ = 1'b0;
            mem_wr_ = 1'b0;
            ula_op_ = 2'b01;
            reg_wr_ = 1'b1;
            mux_reg_wr_ = 1'b0; 
            mux_ula_ = 1'b1;
				jalReg_ = 1'b0;
				jump = 1'b0;
        end
        7'b0110111, 7'b0010111: begin // tipo U load
            branch_ = 1'b0;
            mem_rd_ = 1'b0;
            mem_wr_ = 1'b0;
            ula_op_ = 2'b00;
            reg_wr_ = 1'b1;
            mux_reg_wr_ = 1'b0; 
            mux_ula_ = 1'b1;
				jalReg_ = 1'b0;
				jump = 1'b0;
        end
        7'b1101111: begin // tipo J load
            branch_ = 1'b1;
            mem_rd_ = 1'b0;
            mem_wr_ = 1'b0;
            ula_op_ = 2'b00;
            reg_wr_ = 1'b1;
            mux_reg_wr_ = 1'b1; 
            mux_ula_ = 1'b1;
				jalReg_ = 1'b0;
				jump = 1'b1;
        end
		  default: begin
				branch_ = 1'b0;
            mem_rd_ = 1'b0;
            mem_wr_ = 1'b0;
            ula_op_ = 2'b00;
            reg_wr_ = 1'b0;
            mux_reg_wr_ = 1'b0; 
            mux_ula_ = 1'b0;
			end
    endcase
    end
endmodule