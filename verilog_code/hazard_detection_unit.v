module hazard_detection_unit (
    input wire       IDEX_MemRead,
    input wire [4:0] IDEX_RegisterRt,
  
    input wire [4:0] IFID_RegisterRs,
    input wire [4:0] IFID_RegisterRt,

    output reg       PCWrite,
    output reg       IFIDWrite,
    output reg       Bolha
);


    always @(*) begin
        if (IDEX_MemRead && 
           (IDEX_RegisterRt!= 5'b00000) &&
           ((IDEX_RegisterRt == IFID_RegisterRs) || (IDEX_RegisterRt == IFID_RegisterRt))) 
        begin
           
            PCWrite   = 1'b0; 
            IFIDWrite = 1'b0; 
            Bolha     = 1'b1; 
        end 
        else begin
            
            PCWrite   = 1'b1;
            IFIDWrite = 1'b1;  
            Bolha     = 1'b0; 
        end
    end

endmodule