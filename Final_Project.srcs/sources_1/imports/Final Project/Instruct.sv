// Mark W. welker
// Instruction memory. 
// holds the instructions that the processor will execute.
//
// the address lines are generic and each module must handle thier own decode. 
// The address bus is large enough that each module can contain a local address decode. This will save on multiple enmables. 
// bit 11-0 are for adressing inside each unit.
// nWrite = 0 means databus is being written into the part on the falling edge of write
// nRead = 0 means it is expected to drive the databus while this signal is low and the address is correct until the nRead goes high independent of addressd bus.





module InstructionMemory(Clk,Dataout, address, nRead,nReset);
// NOTE the lack of datain and write. This is because this is a ROM model

input logic nRead, nReset, Clk;
input logic [15:0] address;

inout logic [31:0] Dataout; // 1 - 32 it instructions at a time.

  logic [31:0]InstructMemory[13]; // this is the physical memory
  logic ItsMe; // the address bus is talkig to this module. used to enable tristate buffers.
  logic [31:0] InstToOutput; // this is a temporary data register to be set to go to the output. 
// This memory is designed to be driven into a data multiplexor. 

  always_ff @(negedge Clk or negedge nReset)
begin
  if (!nReset)
    InstToOutput = 0;
  else begin
  if(address[15:12] == InstrMemEn) // talking to Instruction IntstrMemEn
		begin
		    ItsMe = 1;
			if(~nRead)begin
				InstToOutput <= InstructMemory[address[11:0]]; // data will reamin on dataout until it is changed.
			end
		end
	else ItsMe = 0; 
	end
end // from negedge nRead	

always @(negedge nReset)
begin
//	set in the default instructions 
//
	InstructMemory[0] = Instruct1;  	
	InstructMemory[1] = Instruct2;  	
  	InstructMemory[2] = Instruct3;
	InstructMemory[3] = Instruct4;	
	InstructMemory[4] = Instruct5;
	InstructMemory[5] = Instruct6;
	InstructMemory[6] = Instruct7;
	InstructMemory[7] = Instruct8;
	InstructMemory[8] = Instruct9;
	InstructMemory[9] = Instruct10;
	InstructMemory[10] = Instruct11;
	InstructMemory[11] = Instruct12;
	InstructMemory[12] = Instruct13;
end 

assign Dataout = ItsMe ? InstToOutput : 32'bz;



endmodule