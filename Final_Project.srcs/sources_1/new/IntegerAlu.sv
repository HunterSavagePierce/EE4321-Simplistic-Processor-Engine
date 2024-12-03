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
    logic drive_enable;
  
    // Tri-state control for the Databus
    assign Databus = drive_enable ? Databus_driver : 'z;
    
    always_ff @(negedge Clk) begin
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
    
endmodule
