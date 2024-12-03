///////////////////////////////////////////////////////////////////////////////
// Project: Execution Engine
// Author: Hunter Savage-Pierce
// Date: November 18th, 2024
// Version: 1.0
///////////////////////////////////////////////////////////////////////////////
// Description:
// Test Bench File for a Custom Execution Engine
//
// References:
// - Mark W. Welker EE4321 Execution Engine Supplied Code Texas State University
// - ChatGPT 4o
///////////////////////////////////////////////////////////////////////////////


module TestMatrix  (Clk,nReset);

	output logic Clk, nReset; // we are driving these signals from here. 

	initial begin
		Clk = 0;
		nReset = 1;
        #5 nReset = 0;
        #5 nReset = 1;
	end
	
	always  #5 Clk = ~Clk;

	
endmodule
