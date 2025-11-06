module hazard_detection_unit (
    input wire       IDEX_RegWrite,
    input wire       EXMEM_MemRead,
    input wire       IDEX_MemRead,
    input wire       branch,
    input wire       jalr,
    input wire [4:0] EXMEM_RegisterRd,
    input wire [4:0] IDEX_RegisterRd,
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

        // Hazard (caso de instrução seguida de B ou JALR dependente)
        if (IDEX_RegWrite &&
            (IDEX_RegisterRd != 5'b00000) &&
            (B || Jalr) &&
            ((IDEX_RegisterRd == IFID_Register1) || (IDEX_RegisterRd == IFID_Register2))) begin

            PCWrite   = 1'b0;
            IFIDWrite = 1'b0;
            Bolha     = 1'b1;
        end

        // Hazard (caso do load seguido de instrucao B ou JAlR)
        if (EXMEM_MemRead &&
            (EXMEM_RegisterRd != 5'b00000) &&
            (B || Jalr) &&
            ((EXMEM_RegisterRd == IFID_Register1) || (EXMEM_RegisterRd == IFID_Register2))) begin

            PCWrite   = 1'b0;
            IFIDWrite = 1'b0;
            Bolha     = 1'b1;
        end

        // Hazard (caso de Load seguido de qualquer instrucao dependente)
        else if(IDEX_MemRead &&
        (IDEX_RegisterRd != 5'b0) &&
        ((IDEX_RegisterRd == IFID_Register1) || (IDEX_RegisterRd == IFID_Register2))) begin

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
