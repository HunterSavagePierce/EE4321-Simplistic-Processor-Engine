///////////////////////////////////////////////////////////////////////////////
// Project: Simplistic Processing Engine
// Author: Hunter Savage-Pierce
// Date: November 22nd, 2024
// Version: 1.0
///////////////////////////////////////////////////////////////////////////////
// Description:
// Main Memory File for a Simplistic Processing Engine
//
// References:
// - Mark W. Welker EE4321 Simplistic Processing Engine Supplied Code Texas State University
// - ChatGPT 4o
///////////////////////////////////////////////////////////////////////////////

module MainMemory(Clk, Databus, address, nRead,nWrite, nReset);
    input logic nRead,nWrite, nReset, Clk;
    input logic [15:0] address;
    inout logic [255:0] Databus;

    logic [255:0]MainMemory[14]; // this is the physical memory
    
    logic [255:0] Databus_driver; // Internal driver for Databus
    logic drive_enable;
  
    // Tri-state control for the Databus
    assign Databus = drive_enable ? Databus_driver : 'z;

    always_ff @(negedge Clk or negedge nReset)
    begin
        if (~nReset) begin
        MainMemory[0] = 256'h0008_000c_0008_0006_000c_0010_000d_0009_000a_0009_0005_000d_000c_0003_000a_0006;
        MainMemory[1] = 256'h0003_0004_0007_0008_0007_0008_000e_0007_0010_0009_000c_000b_000c_0005_0005_0006;
        MainMemory[2] = 256'h0;
        MainMemory[3] = 256'h0;
        MainMemory[4] = 256'h0;
        MainMemory[5] = 256'h0;
        MainMemory[6] = 256'h0;
        MainMemory[7] = 256'h0;
        MainMemory[8] = 256'h0;
        MainMemory[9] = 256'h0;
        MainMemory[10] = 256'h7;
        MainMemory[11] = 256'hb;
        MainMemory[12] = 256'h0;
        MainMemory[13] = 256'h0;
        
        drive_enable = 0;
        Databus_driver = 0;
	end

    else if(address[15:12] == MainMemEn) // talking to Instruction
    begin
        if (~nRead) begin
            drive_enable = 1;                          // Enable driving Databus
            Databus_driver = MainMemory[address[11:0]]; // Drive data onto Databus
        end else begin
            drive_enable = 0; // Disable driving Databus
        end
        
        if(~nWrite)begin
            MainMemory[address[11:0]] <= Databus_driver;
        end
    end
end // from negedge nRead	


endmodule


