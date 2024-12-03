// Mark W. Welker
// project
// Spring 2023
//
//



module MainMemory(Clk,Dataout, address, nRead,nWrite, nReset);



input logic nRead,nWrite, nReset, Clk;
input logic [15:0] address;

inout logic [255:0] Dataout; // to the CPU 

  logic [255:0]MainMemory[14]; // this is the physical memory
  logic ItsMe; // the address bus is talkig to this module. used to enable tristate buffers.
  logic [255:0] MemToOutput; // this is a temporary data register to be set to go to the output. 

always_ff @(negedge Clk or negedge nReset)
begin
	if (~nReset) begin
	MainMemory[0] = 256'h0009_000c_0008_0007_000c_0010_000d_0009_000B_0009_0006_000d_000d_0005_000e_0006;
	MainMemory[1] = 256'h0007_0005_0011_0009_000c_0008_000e_0007_0010_0009_000c_000b_000c_0007_0009_0006;
	MainMemory[2] = 256'h0;
	MainMemory[3] = 256'h0;
	MainMemory[4] = 256'h0;
	MainMemory[5] = 256'h0;
	MainMemory[6] = 256'h0;
	MainMemory[7] = 256'h0;
	MainMemory[8] = 256'h0;
	MainMemory[9] = 256'h0;
	MainMemory[10] = 256'h9;
	MainMemory[11] = 256'ha;
	MainMemory[12] = 256'h0;
	MainMemory[13] = 256'h0;
	
	
      MemToOutput=0;
	end

  else if(address[15:12] == MainMemEn) // talking to Instruction
		begin
			
			if (~nRead)begin
			ItsMe <= 1; // Only Drive Bus on read
				MemToOutput <= MainMemory[address[11:0]]; // data will remain on dataout until it is changed.
			end
			if(~nWrite)begin
			ItsMe <= 0; // only drive bus on read
		    MainMemory[address[11:0]] <= Dataout;
			end
		end
    else ItsMe = 0;
end 	

assign Dataout = ItsMe ? MemToOutput : 256'bz;
endmodule


