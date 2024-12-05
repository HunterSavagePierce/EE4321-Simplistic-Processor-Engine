///////////////////////////////////////////////////////////////////////////////
// Project: Execution Engine
// Author: Hunter Savage-Pierce
// Date: November 18th, 2024
// Version: 1.0
///////////////////////////////////////////////////////////////////////////////
// Description:
// Matrix ALU File for a Custom Execution Engine
//
// References:
// - Mark W. Welker EE4321 Execution Engine Supplied Code Texas State University
// - ChatGPT 4o
///////////////////////////////////////////////////////////////////////////////

module MatrixAlu(Clk, Databus, address, nRead, nWrite, nReset);
    input logic nRead,nWrite, nReset, Clk;
    input logic [15:0] address;
    inout logic [255:0] Databus;
    
    logic [255:0] Databus_driver; // Internal driver for Databus
    logic [15:0] SRC1_MATRIX [4][4];
    logic [15:0] SRC2_MATRIX [4][4];
    logic [15:0] RESULT_MATRIX [4][4];
    logic drive_enable;
  
    // Tri-state control for the Databus
    assign Databus = drive_enable ? Databus_driver : 'z;

    always_ff @(negedge Clk or negedge nReset) begin
        if (!nReset) begin
            for (int i = 0; i < 4; i++) begin
                for (int j = 0; j < 4; j++) begin
                    SRC1_MATRIX[i][j] = 16'd0; // Set each element to 0
                end
            end
            for (int i = 0; i < 4; i++) begin
                for (int j = 0; j < 4; j++) begin
                    SRC2_MATRIX[i][j] = 16'd0; // Set each element to 0
                end
            end
            for (int i = 0; i < 4; i++) begin
                for (int j = 0; j < 4; j++) begin
                    RESULT_MATRIX[i][j] = 16'd0; // Set each element to 0
                end
            end
        end else begin
            if(address[15:12] == AluEn) begin // talking to Instruction IntstrMemEn
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
            SRC1_MATRIX[0][0] <= Databus_driver[15:0];
            SRC1_MATRIX[0][1] <= Databus_driver[31:16];
            SRC1_MATRIX[0][2] <= Databus_driver[47:32];
            SRC1_MATRIX[0][3] <= Databus_driver[63:48];
            
            SRC1_MATRIX[1][0] <= Databus_driver[79:64];
            SRC1_MATRIX[1][1] <= Databus_driver[95:80];
            SRC1_MATRIX[1][2] <= Databus_driver[111:96];
            SRC1_MATRIX[1][3] <= Databus_driver[127:112];
            
            SRC1_MATRIX[2][0] <= Databus_driver[143:128];
            SRC1_MATRIX[2][1] <= Databus_driver[159:144];
            SRC1_MATRIX[2][2] <= Databus_driver[175:160];
            SRC1_MATRIX[2][3] <= Databus_driver[191:176];
            
            SRC1_MATRIX[3][0] <= Databus_driver[207:192];
            SRC1_MATRIX[3][1] <= Databus_driver[223:208];
            SRC1_MATRIX[3][2] <= Databus_driver[239:224];
            SRC1_MATRIX[3][3] <= Databus_driver[255:240];
        end 
        else if (address[3:0] == ALU_Source2) begin
            SRC2_MATRIX[0][0] <= Databus_driver[15:0];
            SRC2_MATRIX[0][1] <= Databus_driver[31:16];
            SRC2_MATRIX[0][2] <= Databus_driver[47:32];
            SRC2_MATRIX[0][3] <= Databus_driver[63:48];
            
            SRC2_MATRIX[1][0] <= Databus_driver[79:64];
            SRC2_MATRIX[1][1] <= Databus_driver[95:80];
            SRC2_MATRIX[1][2] <= Databus_driver[111:96];
            SRC2_MATRIX[1][3] <= Databus_driver[127:112];
            
            SRC2_MATRIX[2][0] <= Databus_driver[143:128];
            SRC2_MATRIX[2][1] <= Databus_driver[159:144];
            SRC2_MATRIX[2][2] <= Databus_driver[175:160];
            SRC2_MATRIX[2][3] <= Databus_driver[191:176];
            
            SRC2_MATRIX[3][0] <= Databus_driver[207:192];
            SRC2_MATRIX[3][1] <= Databus_driver[223:208];
            SRC2_MATRIX[3][2] <= Databus_driver[239:224];
            SRC2_MATRIX[3][3] <= Databus_driver[255:240];
        end
        else if (address[3:0] == ALU_Result) begin    
            //Only used for immediate
            case (address[11:4])
                MMult1: begin
                    // 4x4 Matrix Multiplication using nested for loops
                    integer i, j, k; // Loop counters
                    for (i = 0; i < 4; i = i + 1) begin
                        for (j = 0; j < 4; j = j + 1) begin
                            for (k = 0; k < 4; k = k + 1) begin
                                RESULT_MATRIX[i][j] = RESULT_MATRIX[i][j] + 
                                                      (SRC1_MATRIX[i][k] * SRC2_MATRIX[k][j]);
                            end
                        end
                    end     
                end
                MMult2: begin
                    // 4x2 * 2x4 matrix multiplication
                    integer i, j, k; // Loop counters
                    for (i = 0; i < 4; i = i + 1) begin
                        for (j = 0; j < 4; j = j + 1) begin
                            RESULT_MATRIX[i][j] = 0; // Initialize the result element to zero
                            for (k = 0; k < 2; k = k + 1) begin
                                RESULT_MATRIX[i][j] = RESULT_MATRIX[i][j] + 
                                                      (SRC1_MATRIX[i][k] * SRC2_MATRIX[k][j]);
                            end
                        end
                    end 
                end
                MMult3: begin
                    // 2x4 * 4x2 matrix multiplication
                    integer i, j, k; // Loop counters
                    for (i = 0; i < 2; i = i + 1) begin
                        for (j = 0; j < 2; j = j + 1) begin
                            RESULT_MATRIX[i][j] = 0; // Initialize the result element to zero
                            for (k = 0; k < 4; k = k + 1) begin
                                RESULT_MATRIX[i][j] = RESULT_MATRIX[i][j] + 
                                                      (SRC1_MATRIX[i][k] * SRC2_MATRIX[k][j]);
                            end
                        end
                    end
                end
                Madd: begin
                    integer i, j; // Loop counters
                    for (int i = 0; i < 4; i++) begin
                        for (int j = 0; j < 4; j++) begin
                            RESULT_MATRIX[i][j] <= SRC1_MATRIX[i][j] + SRC2_MATRIX[i][j];
                        end
                    end 
                end
                Msub: begin
                    integer i, j; // Loop counters
                    for (int i = 0; i < 4; i++) begin
                        for (int j = 0; j < 4; j++) begin
                            RESULT_MATRIX[i][j] <= SRC1_MATRIX[i][j] - SRC2_MATRIX[i][j];
                        end
                    end 
                end
                Mtranspose: begin
                    integer i, j; // Loop counters
                    for (i = 0; i < 4; i = i + 1) begin
                        for (j = 0; j < 4; j = j + 1) begin
                            RESULT_MATRIX[j][i] <= SRC1_MATRIX[i][j];
                        end
                    end
                end
                MScale: begin
                    integer i, j; // Loop counters
                    for (i = 0; i < 4; i = i + 1) begin
                        for (j = 0; j < 4; j = j + 1) begin
                            RESULT_MATRIX[i][j] <= SRC1_MATRIX[i][j] * Databus_driver;
                        end
                    end
                end
                MScaleImm: begin
                    integer i, j; // Loop counters
                    for (i = 0; i < 4; i = i + 1) begin
                        for (j = 0; j < 4; j = j + 1) begin
                            RESULT_MATRIX[i][j] = RESULT_MATRIX[i][j] * SRC1_MATRIX[i][j];
                        end
                    end
                end
            endcase
        end
        else if (address[3:0] == AluStatusOut) begin
            Databus_driver[15:0] <= RESULT_MATRIX[0][0];
            Databus_driver[31:16] <= RESULT_MATRIX[0][1];
            Databus_driver[47:32] <= RESULT_MATRIX[0][2];
            Databus_driver[63:48] <= RESULT_MATRIX[0][3];
            
            Databus_driver[79:64] <= RESULT_MATRIX[1][0];
            Databus_driver[95:80] <= RESULT_MATRIX[1][1];
            Databus_driver[111:96] <= RESULT_MATRIX[1][2];
            Databus_driver[127:112] <= RESULT_MATRIX[1][3];
            
            Databus_driver[143:128] <= RESULT_MATRIX[2][0];
            Databus_driver[159:144] <= RESULT_MATRIX[2][1];
            Databus_driver[175:160] <= RESULT_MATRIX[2][2];
            Databus_driver[191:176] <= RESULT_MATRIX[2][3];
            
            Databus_driver[207:192] <= RESULT_MATRIX[3][0];
            Databus_driver[223:208] <= RESULT_MATRIX[3][1];
            Databus_driver[239:224] <= RESULT_MATRIX[3][2];
            Databus_driver[255:240] <= RESULT_MATRIX[3][3];
        end
        
    end	
//parameter AluStatusIn = 0;
//parameter AluStatusOut = 1;
//parameter ALU_Source1 = 2;
//parameter ALU_Source2 = 3;
//parameter ALU_Result = 4;
//parameter Overflow_err = 5;
endmodule
