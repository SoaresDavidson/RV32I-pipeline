module main_memory(
    input   wire clk,

    input   wire memRead,
    input   wire memWrite,

    input   wire [2:0]  funct3,
    input   wire [31:0] addr,
    input   wire [31:0] writeData,

    output  reg [31:0] data

);
    reg [7:0] memory [4095:0];
    reg [7:0] byte;
    reg [15:0] half;
    reg [31:0] word;

    always @(*) begin
        byte = memory[addr];
        half = {memory[addr + 1], memory[addr]};
        word = {memory[addr + 3], memory[addr + 2], memory[addr + 1], memory[addr]};
        case (memRead)
            1'b0: data = 32'b0;
            1'b1: begin
                case (funct3)
                    3'b000: data = {24'b0, byte}; //lb
                    3'b001: data = {16'b0, half}; //lh
                    3'b010: data = word; //lw
                    3'b100: data = {{24{byte[7]}}, byte}; //lbu
                    3'b101: data = {{16{half[15]}}, half}; //lhu
                    default: data = 32'b0;
                endcase
            end
        endcase
    end
    always @(posedge clk) begin
        if (memWrite) begin 
            case (funct3)
                3'b000: memory[addr][7:0] = writeData[7:0]; //sb
                3'b001: begin // sh
                    memory[addr] = writeData[7:0];
                    memory[addr + 1] = writeData[15:8];
                end
                3'b010: begin // sw
                    memory[addr] = writeData[7:0];
                    memory[addr + 1] = writeData[15:8];
                    memory[addr + 2] = writeData[23:16];
                    memory[addr + 3] = writeData[31:24];
                end
                default: ;
            endcase
        end
    end


endmodule