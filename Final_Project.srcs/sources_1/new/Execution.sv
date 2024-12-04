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

parameter MainMemEn = 0;
parameter RegisterEn = 1;
parameter InstrMemEn = 2;
parameter AluEn = 3;
parameter ExecuteEn = 4;
parameter IntAlu = 5;

// Alu Register setup // same register sequence for both ALU's 
parameter AluStatusIn = 0;
parameter AluStatusOut = 1;
parameter ALU_Source1 = 2;
parameter ALU_Source2 = 3;
parameter ALU_Result = 4;
parameter Overflow_err = 5;

//////////////////////////////
//Moved stop to third instruction for this example
/////////////////////////////////////////////////
// instruction: OPcode :: dest :: src1 :: src2 Each section is 8 bits.
//Stop::FFh::00::00::00
//MMult1::00h::Reg/mem::Reg/mem::Reg/mem
//MMult2::01h::Reg/mem::Reg/mem::Reg/mem
//MMult3::02h::Reg/mem::Reg/mem::Reg/mem
//Madd::03h::Reg/mem::Reg/mem::Reg/mem
//Msub::04h::Reg/mem::Reg/mem::Reg/mem
//Mtranspose::05h::Reg/mem::Reg/mem::Reg/mem
//MScale::06h::Reg/mem::Reg/mem::Reg/mem
//MScaleImm::07h:Reg/mem::Reg/mem::Immediate
//IntAdd::10h::Reg/mem::Reg/mem::Reg/mem
//IntSub::11h::Reg/mem::Reg/mem::Reg/mem
//IntMult::12h::Reg/mem::Reg/mem::Reg/mem
//IntDiv::13h::Reg/mem::Reg/mem::Reg/mem

parameter MMult1 = 8'h 00;
parameter MMult2 = 8'h 01;
parameter MMult3 = 8'h 02;
parameter Madd = 8'h 03;
parameter Msub = 8'h 04;
parameter Mtranspose = 8'h 05;
parameter MScale = 8'h 06;
parameter MScaleImm = 8'h 07;
parameter IntAdd = 8'h 10;
parameter IntSub = 8'h 11;
parameter IntMult = 8'h 12;
parameter IntDiv = 8'h 13;

// add the data at location 0 to the data at location 1 and place result in location 2
parameter Instruct1 = 32'h 03_02_00_01; // add first matrix to second matrix store in memory
parameter Instruct2 = 32'h 06_03_00_0a; // scale matrix 1 by whats in location A store in memory
parameter Instruct3 = 32'h 10_10_0a_0b; // add 16 bit numbers in location a to b store in temp register
parameter Instruct4 = 32'h 04_04_03_00; //Subtract the first matrix from the result in step 2 and store the result somewhere else in memory. 
parameter Instruct5 = 32'h 05_05_02_00;//Transpose the result from step 1 store in memory
parameter Instruct6 = 32'h 07_11_03_08;//ScaleImm the result in step 2 by the result from step 3 store in a matrix register
parameter Instruct7 = 32'h 00_06_04_05; //Multiply the result from step 4 by the result in step 5, store in memory. 4x4 * 4x4
parameter Instruct8 = 32'h 01_07_11_05; //Multiply the result from step 6 by the result in step 5, store in memory. 4x2 * 2x4
parameter Instruct9 = 32'h 02_08_05_04; //Multiply the result from step 5 by the result in step 4, store in memory. 2x4 * 4x2

parameter Instruct10 = 32'h 12_0a_01_00;//Multiply the integer value in memory location 0 to location 1. Store it in memory location 0x0A
parameter Instruct11 = 32'h 11_12_0a_01;//Subtract the integer value in memory location 01 from memory location 0x0A and store it in a register
parameter Instruct12 = 32'h 13_0b_07_08;//Divide the result from step 8 by the result in step 9  and store it in location 0x0B
parameter Instruct13 = 32'h FF_00_00_00; // stop

module Execution(Clk, Databus, address, nRead, nWrite, nReset);
    input logic Clk, nReset;
    output logic nRead, nWrite;
    output logic [15:0] address;
    inout logic [255:0] Databus;
    
    logic [15:0] ProgCount;  
    logic [255:0] Databus_driver; // Internal driver for Databus
    logic drive_enable;
    
    logic [255:0]InternalReg[4]; // this is the physical memory
    
    logic [7:0] opcode, dest, src1, src2;
    logic [255:0] src1Data, src2Data, result;
  
    // Tri-state control for the Databus
    assign Databus = drive_enable ? Databus_driver : 'z;
    
    typedef enum logic [3:0] {
        RESET, FETCH_INSTRUCTION, DECODE_INSTRUCTION, FETCH_SRC1, 
        FETCH_SRC2, FETCH_DEST, EXECUTE_ALU, EXECUTE_MATRIX, WRITE_BACK
    } state_t;

    state_t state, next_state;

    always_comb begin
        case (state)
            RESET: begin
                next_state = FETCH_INSTRUCTION;
                ProgCount = 0;
                address = 0;
                nRead = 1;
                nWrite = 1;
            end
            FETCH_INSTRUCTION: begin
                next_state = DECODE_INSTRUCTION;
                address[15:12] = InstrMemEn;
                address[11:0] = ProgCount;
                nRead = 0;
                nWrite = 1;
            end
            DECODE_INSTRUCTION: begin
                next_state = FETCH_SRC1;
                address[15:12] = ExecuteEn;
                address[11:0] = 0;
                nRead = 1;
                nWrite = 0;
                
                opcode = Databus_driver[31:24];
                dest = Databus_driver[23:16];
                src1 = Databus_driver[15:8];
                src2 = Databus_driver[7:0];
            end
            FETCH_SRC1: begin
                if (src1[7]) begin
                    // Fetch from InternalReg (register indicated by lower 3 bits of src1)
                    src1Data = InternalReg[src1[3:0]];
                end else begin
                    // Fetch from MainMemory (address indicated by src1)
                    address[15:12] = MainMemEn;
                    address[11:0] = src1[7:0];
                    nRead = 0;
                    nWrite = 1;
                    src1Data = Databus; // Data fetched from the databus
                end
                if (opcode == MScaleImm) begin
                    if (!opcode[4]) begin
                    next_state = EXECUTE_MATRIX;
                    end else begin
                        next_state = EXECUTE_ALU;
                    end
                end else begin
                    next_state = FETCH_SRC2;
                end
            end
            FETCH_SRC2: begin
                if (src2[7]) begin
                    // Fetch from InternalReg (register indicated by lower 3 bits of src1)
                    src2Data = InternalReg[src2[3:0]];
                end else begin
                    // Fetch from MainMemory (address indicated by src2)
                    address[15:12] = MainMemEn;
                    address[11:0] = src2[7:0];
                    nRead = 0;
                    nWrite = 1;
                    src2Data = Databus; // Data fetched from the databus
                end
                if (!opcode[4]) begin
                    next_state = EXECUTE_MATRIX;
                end else begin
                    next_state = EXECUTE_ALU;
                end
            end
            //FETCH_DEST: If opcode is ALU then next_state = EXECUTE_MATRIX
            // Else its matrix then next_state = EXECUTE_ALU
            //EXECUTE_MATRIX:
            //EXECTUE_ALU: 
            //WRITE_BACK: next_state = FETCH;
            default: next_state = RESET;
        endcase
    end
    
    always_ff @(negedge Clk) begin
        if(address[15:12] == ExecuteEn) begin // talking to Instruction IntstrMemEn
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
    
    always_ff @(posedge Clk or negedge nReset) begin
        if (!nReset) begin
            state <= RESET;
            Databus_driver <= 0;
            drive_enable <= 0;
            opcode <= 0;
            dest <= 0;
            src1 <= 0;
            src2 <= 0;
        end
        else begin
            state <= next_state;
        end
    end
    
endmodule
