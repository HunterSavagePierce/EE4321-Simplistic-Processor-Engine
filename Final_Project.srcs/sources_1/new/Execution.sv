///////////////////////////////////////////////////////////////////////////////
// Project: Simplistic Processing Engine
// Author: Hunter Savage-Pierce
// Date: November 22nd, 2024
// Version: 1.0
///////////////////////////////////////////////////////////////////////////////
// Description:
// Execution Engine File for a Simplistic Processing Engine
//
// References:
// - Mark W. Welker EE4321 Simplistic Processing Engine Supplied Code Texas State University
// - ChatGPT 4o
///////////////////////////////////////////////////////////////////////////////

module Execution(Clk, Databus, address, nRead, nWrite, nReset);
    input logic nRead,nWrite, nReset, Clk;
    input logic [15:0] address;
    inout logic [255:0] Databus;
    
    logic [255:0] Databus_driver; // Internal driver for Databus
    logic drive_enable;
  
    // Tri-state control for the Databus
    assign Databus = drive_enable ? Databus_driver : 'z;
    
endmodule
