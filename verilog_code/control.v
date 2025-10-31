module control(
    input wire [6:0] opcode,
    // controle MEM
    output	wire mem_rd_out, //le memoria
	output	wire mem_wr_out, //escreve memoria

	// controle WB
	output	wire reg_wr_out, // escreve banco de reg
	output	wire mux_reg_wr_out, //mux do final

    // EX
    output   wire mux_ula_out, // mux da ula (rs2 ou imm)
    output   wire [1:0] ula_op_out, // escolhe operação
    output   wire pc_ula_out, // escolhe pc ou val_A
    // ID
    output wire jump_out,
    output wire branch_out
);
reg mem_rd, mem_wr, reg_wr, mux_reg_wr, mux_ula, branch, pc_ula, jump;
reg [1:0] ula_op;
assign mem_rd_out = mem_rd;
assign mem_wr_out = mem_wr;
assign reg_wr_out = reg_wr;
assign mux_reg_wr_out = mux_reg_wr;
assign mux_ula_out = mux_ula;
assign branch_out = branch;
assign ula_op_out = ula_op;
assign pc_ula_out = pc_ula;
assign jump_out = jump;

always @(*) begin
    case (opcode)
        7'b0110011: begin //tipo R
            branch = 1'b0;
            mem_rd = 1'b0;
            mem_wr = 1'b0;
            ula_op = 2'b10; 
            reg_wr = 1'b1;
            mux_reg_wr = 1'b0; 
            mux_ula = 1'b0;
            pc_ula = 1'b0;
            jump = 1'b0;
        end 
        7'b0010011: begin // tipo I
            branch = 1'b0;
            mem_rd = 1'b0;
            mem_wr = 1'b0;
            ula_op = 2'b10;
            reg_wr = 1'b1;
            mux_reg_wr = 1'b0; 
            mux_ula = 1'b1;
            pc_ula = 1'b0;
            jump = 1'b0;
        end
        7'b0000011: begin // tipo I load
            branch = 1'b0;
            mem_rd = 1'b1;
            mem_wr = 1'b0;
            ula_op = 2'b00;
            reg_wr = 1'b1;
            mux_reg_wr = 1'b0; 
            mux_ula = 1'b1;
            pc_ula = 1'b0;
            jump = 1'b0;
        end
        7'b0100011: begin // tipo S load
            branch = 1'b0;
            mem_rd = 1'b0;
            mem_wr = 1'b1;
            ula_op = 2'b00;
            reg_wr = 1'b0;
            mux_reg_wr = 1'b1; 
            mux_ula = 1'b1;
            pc_ula = 1'b0;
            jump = 1'b0;
        end
        7'b1100011: begin // tipo B load
            branch = 1'b1;
            mem_rd = 1'b0;
            mem_wr = 1'b0;
            ula_op = 2'b00;
            reg_wr = 1'b1;
            mux_reg_wr = 1'b0; 
            mux_ula = 1'b1;
            pc_ula = 1'b0;
            jump = 1'b0;
        end
        7'b0110111, 7'b0010111: begin // tipo U load
            branch = 1'b0;
            mem_rd = 1'b0;
            mem_wr = 1'b0;
            ula_op = 2'b00;
            reg_wr = 1'b1;
            mux_reg_wr = 1'b0;
            mux_ula = 1'b1;
            pc_ula = 1'b1;
            jump = 1'b0;
        end
        7'b1101111, 7'b1100111: begin // tipo J load
            branch = 1'b0;
            mem_rd = 1'b0;
            mem_wr = 1'b0;
            ula_op = 2'b00;
            reg_wr = 1'b1;
            mux_reg_wr = 1'b0; 
            mux_ula = 1'b1;
            pc_ula = 1'b1;
            jump = 1'b1;
        end
		  default: begin
            branch = 1'b0;
            mem_rd = 1'b0;
            mem_wr = 1'b0;
            ula_op = 2'b00;
            reg_wr = 1'b0;
            mux_reg_wr = 1'b0; 
            mux_ula = 1'b0;
            pc_ula = 1'b0;
            jump = 1'b0;
			end
    endcase
    end
endmodule