module forward_unit(
    input  [4:0] IDEXrs1,
    input  [4:0] IDEXrs2,
    input  [4:0] EXMEMrd,
    input        EXMEM_RegWrite,
    input  [4:0] MEMWBrd,
    input        MEMWB_RegWrite,
    output reg [1:0] forwardA,
    output reg [1:0] forwardB
);


    always @(*) begin
        if (EXMEM_RegWrite && (EXMEMrd != 5'b0) && (EXMEMrd == IDEXrs1)) begin
            forwardA = 2'b10; 
        end
        else if (MEMWB_RegWrite && (MEMWBrd != 5'b0) && (MEMWBrd == IDEXrs1)) begin
            forwardA = 2'b01;
        end

        else begin
            forwardA = 2'b00; 
        end

        if (EXMEM_RegWrite && (EXMEMrd != 5'b0) && (EXMEMrd == IDEXrs2)) begin
            forwardB = 2'b10;
        end
        else if (MEMWB_RegWrite && (MEMWBrd != 5'b0) && (MEMWBrd == IDEXrs2)) begin
            forwardB = 2'b01; 
        end
        else begin
            forwardB = 2'b00; 
        end
    end

endmodule