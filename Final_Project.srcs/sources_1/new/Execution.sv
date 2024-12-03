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
    parameter MainMemEn = 0;
    parameter RegisterEn = 1;
    parameter InstrMemEn = 2;
    parameter AluEn = 3;
    parameter ExecuteEn = 4;
    parameter IntAlu = 5;
    
    input logic Clk, nReset;
    output logic nRead, nWrite;
    output logic [15:0] address;
    inout logic [255:0] Databus;
    
    logic [15:0] ProgCount;  
    logic [255:0] Databus_driver; // Internal driver for Databus
    logic drive_enable;
    
    logic [255:0]InternalReg[3]; // this is the physical memory
    
    logic [7:0] opcode, dest, src1, src2;
    logic [255:0] src1Data, src2Data, result;
  
    // Tri-state control for the Databus
    assign Databus = drive_enable ? Databus_driver : 'z;
    
    typedef enum logic [2:0] {
        RESET, FETCH_INSTRUCTION, DECODE_INSTRUCTION, FETCH_SRC1, FETCH_SRC2, EXECUTE, WRITE_BACK
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
            //FETCH_SRC1: next_state = FETCH;
            //FETCH_SRC2: next_state = FETCH;
            //EXECUTE: next_state = FETCH;
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
        end
        else begin
            state <= next_state;
        end
    end
    
endmodule
