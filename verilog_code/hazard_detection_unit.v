module hazard_detection_unit (
    input wire       IDEX_MemRead,
    input wire [4:0] IDEX_RegisterRt,
  
    input wire [4:0] IFID_Register1,
    input wire [4:0] IFID_Register2,
    input wire       Jump, 
    output reg       PCWrite,
    output reg       IFIDWrite,
    output reg       Bolha,
    output reg       Flush
);


    always @(*) begin
        // tudo normal
        PCWrite   = 1'b1;
        IFIDWrite = 1'b1;
        Bolha     = 1'b0;
        Flush     = 1'b0;

        // Hazard (caso do load)
        if (IDEX_MemRead &&
            (IDEX_RegisterRt != 5'b00000) &&
            ((IDEX_RegisterRt == IFID_Register1) || (IDEX_RegisterRt == IFID_Register2))) begin

            PCWrite   = 1'b0;
            IFIDWrite = 1'b0;
            Bolha     = 1'b1;
        end

        // Hazard (caso de ocorrer salto)
        else if (Jump) begin
            // O salto foi decidido, limpa a próxima instrução
            Flush = 1'b1;
        end
    end

endmodule