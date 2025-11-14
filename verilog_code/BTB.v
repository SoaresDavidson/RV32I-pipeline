module BranchTargetBuffer(
    input wire clk,
    input wire rst,
    input wire [31:0] pc,
    input wire [31:0] IFID_pc,
    input wire [31:0] target_address,
    input wire branch_taken,
    output reg [31:0] predicted_address,
    output reg predicted
);

reg [66:0] buffer[0:255]; //buffer[pc_less] gives target address
wire [7:0] pc_less;
assign pc_less = pc[7:0];
wire [7:0] IFID_pc_less;
assign IFID_pc_less = IFID_pc[7:0];

//pc[32],target[32],state[2], valid[1]

always @(posedge clk or posedge rst) begin
    if (rst) begin :BTB_RESET
        integer i;
        for (i = 0; i < 256; i = i + 1) begin
            buffer[i] <= 67'b0;
        end
    end else if (branch_taken && buffer[IFID_pc_less][0] == 1'b0) begin
            buffer[IFID_pc_less] <= {IFID_pc, target_address, 2'b00, 1'b1};
        end
        else if (buffer[IFID_pc_less][0] == 1'b1) begin
            if (branch_taken) begin
                // Update the full entry with new PC, target address, reset state, and set valid
                buffer[IFID_pc_less] <= {IFID_pc, target_address, 2'b00, 1'b1};
            end else begin
                case (buffer[IFID_pc_less][2:1])
                    2'b00: buffer[IFID_pc_less][2:1] <= 2'b01;
                    2'b01: buffer[IFID_pc_less][2:1] <= 2'b11;
                    2'b11: buffer[IFID_pc_less][2:1] <= 2'b10;
                    2'b10: buffer[IFID_pc_less][2:1] <= 2'b10;
                endcase
            end
        end
    end

// Lógica combinacional: leitura e predição (assíncrono)
always @(*) begin
    // Verifica se deve prever o branch
    if (buffer[pc_less][0] == 1'b1 && 
        (buffer[pc_less][2:1] == 2'b00 || buffer[pc_less][2:1] == 2'b01) &&
        pc == buffer[pc_less][66:35]) begin
        predicted = 1'b1;
        predicted_address = buffer[pc_less][34:3];
    end else begin
        predicted = 1'b0;
        predicted_address = 32'b0;
    end
end

endmodule   