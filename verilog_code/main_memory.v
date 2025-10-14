module main_memory(
    input   wire clk,

    input   wire memRead,
    input   wire memWrite,

    input   wire [31:0] addr,
    input   wire [31:0] writeData,

    output  reg [31:0] data

);
    reg [31:0] memory [1023:0];
    always @(*) begin
        case (memRead)
            1'b0: data = 32'b0;
            1'b1: data = memory[addr];
        endcase
    end
    always @(posedge clk) begin
        if (memWrite) memory[addr] = writeData;
    end


endmodule