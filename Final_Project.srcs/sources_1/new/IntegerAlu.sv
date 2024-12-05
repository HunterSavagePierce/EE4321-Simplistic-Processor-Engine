///////////////////////////////////////////////////////////////////////////////
// Project: Execution Engine
// Author: Hunter Savage-Pierce
// Date: November 18th, 2024
// Version: 1.0
///////////////////////////////////////////////////////////////////////////////
// Description:
// Integer ALU File for a Custom Execution Engine
//
// References:
// - Mark W. Welker EE4321 Execution Engine Supplied Code Texas State University
// - ChatGPT 4o
///////////////////////////////////////////////////////////////////////////////

module IntegerAlu(Clk, Databus, address, nRead, nWrite, nReset);
    input logic nRead,nWrite, nReset, Clk;
    input logic [15:0] address;
    inout logic [255:0] Databus;
    
    logic [255:0] Databus_driver; // Internal driver for Databus
    logic [255:0] SRC1_INT;
    logic [255:0] SRC2_INT;
    logic [255:0] RESULT_INT;
    logic drive_enable;
  
    // Tri-state control for the Databus
    assign Databus = drive_enable ? Databus_driver : 'z;
    
    always_ff @(negedge Clk) begin
        if (!nReset) begin
            SRC2_INT = 0;
            SRC1_INT = 0;
            RESULT_INT = 0;
        end else begin
            if(address[15:12] == IntAlu) begin // talking to Instruction IntstrMemEn
                if (~nRead) begin
                    drive_enable <= 1; ; // Drive data onto Databus
                end
                if (~nWrite) begin
                    Databus_driver <= Databus;
                end 
            end else begin
                drive_enable <= 0;
            end
        end
    end
    
    always_ff @(posedge Clk) begin
        if (address[3:0] == ALU_Source1) begin
            SRC1_INT <= Databus_driver;
        end 
        else if (address[3:0] == ALU_Source2) begin
            SRC2_INT <= Databus_driver;
        end
        else if (address[3:0] == ALU_Result) begin
            case (address[11:4])
                IntAdd: begin
                    RESULT_INT <= SRC1_INT + SRC2_INT;
                end
                IntSub: begin
                    RESULT_INT <= SRC1_INT - SRC2_INT;
                end
                IntMult: begin
                    RESULT_INT <= SRC1_INT * SRC2_INT;
                end
                IntDiv: begin
                    RESULT_INT <= SRC1_INT / SRC2_INT;
                end     
            endcase
        end
        else if (address[3:0] == AluStatusOut) begin
            Databus_driver <= RESULT_INT;
        end
    end	
endmodule
