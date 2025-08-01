`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/08/01 01:31:30
// Design Name: 
// Module Name: LineBuffer
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

// Height, Width 필요

module LineBuffer#(
    parameter DWIDTH = 8,
    parameter P_CH = 32,
    parameter MEM_SIZE = 512,
    parameter AWIDTH = 10
)(
    input clk,
    input reset_n,
    
    input [DWIDTH * P_CH - 1 :0] Feature_Inputs,
    input Feature_Inputs_Valid,
    
    input [7:0] Feature_Width,                          // Max Feature Width is 224 (For MobileNet V1)
    input Feature_Width_Valid,

    input [7:0] Feature_Height,                          // Max Feature Width is 224 (For MobileNet V1)
    input Feature_Height_Valid,
    
    output [3 * (DWIDTH * P_CH) - 1 : 0] Line3_Outputs,
    output reg Line3_Outputs_Valid
    );
    // For Capture Regs
    localparam S_IDLE = 3'b000;                         // Idle -> Capture Width & Height -> Write Start -> Write & Read -> Read -> Done
    localparam S_WRITE_FIRST = 3'b001;                  // Write 3 Lines For 3x3 DWC First.
    localparam S_WRITE_AND_READ = 3'b010;               // Read 3 Lines And Write 1 Lines.
    localparam S_READ = 3'b011;                         // Read Last 3 Lines.
    localparam S_DONE = 3'b100;                         // Done.
    
    // Regs For FSM
    reg [2:0] n_state;
    reg [2:0] c_state;
    
    reg [3:0] Buffer_Ring_Write_Counter;
    
    reg [AWIDTH-1:0] LineBuffer_Write_Addr_Counter;
    reg [AWIDTH-1:0] LineBuffer_Read_Addr_Counter;
    
    reg [7:0] Feature_Width_Capture;
    reg [7:0] Feature_Height_Capture;
    
    wire WE0 = Buffer_Ring_Write_Counter[0] & (c_state == S_WRITE_FIRST || c_state == S_WRITE_AND_READ);
    wire CE0 = WE0 | (!Buffer_Ring_Write_Counter[0] && (c_state == S_WRITE_AND_READ || c_state == S_READ));
    
    wire WE1 = Buffer_Ring_Write_Counter[1] & (c_state == S_WRITE_FIRST || c_state == S_WRITE_AND_READ);
    wire CE1 = WE1 | (!Buffer_Ring_Write_Counter[1] && (c_state == S_WRITE_AND_READ || c_state == S_READ));
    
    wire WE2 = Buffer_Ring_Write_Counter[2] & (c_state == S_WRITE_FIRST || c_state == S_WRITE_AND_READ);
    wire CE2 = WE2 | (!Buffer_Ring_Write_Counter[2] && (c_state == S_WRITE_AND_READ || c_state == S_READ));
    
    wire WE3 = Buffer_Ring_Write_Counter[3] & (c_state == S_WRITE_FIRST || c_state == S_WRITE_AND_READ);
    wire CE3 = WE3 | (!Buffer_Ring_Write_Counter[3] && (c_state == S_WRITE_AND_READ || c_state == S_READ));
    
    wire All_Write_Done;
    wire Line_Write_Done = (LineBuffer_Write_Addr_Counter + 1 >= Feature_Width_Capture);
    wire Line_Read_Done = (LineBuffer_Read_Addr_Counter + 1 >= Feature_Width_Capture);
    
    /////////////////////////////////////////////////////////////////////////////////// Always For FSM
    always@(posedge clk or negedge reset_n) begin
        if(!reset_n) begin
            c_state <= S_IDLE;
        end else begin
            c_state <= n_state;
        end
    end
    
    always@(*) begin
       n_state = c_state;
       case(c_state)
            S_IDLE:
                if(Feature_Width_Valid & Feature_Height_Valid) begin
                    n_state = S_WRITE_FIRST;
                end
            S_WRITE_FIRST:
                if(Line_Write_Done & WE2) begin         // Just Write 3 Lines For First 3 Line Outputs.
                    n_state = S_WRITE_AND_READ;
                end else begin
                    n_state = S_WRITE_FIRST;
                end
            S_WRITE_AND_READ:
                if(All_Write_Done & Line_Read_Done) begin
                    n_state = S_READ;
                end else begin
                    n_state = S_WRITE_AND_READ;
                end
            S_READ:
                if(Line_Read_Done) begin                // 마지막 Read가 끝나면 전부 Read한 것임.
                    n_state = S_DONE;
                end else begin
                    n_state = S_READ;
                end
            S_DONE:
                n_state = S_IDLE;
       endcase 
    end
    /////////////////////////////////////////////////////////////////////////////////// Always For FSM
    
    
    /////////////////////////////////////////////////////////////////////////////////// Always For Capture Datas
    always@(posedge clk or negedge reset_n) begin
        if(!reset_n) begin
            Feature_Width_Capture <= 8'd0;
        end else begin
            if(Feature_Width_Valid) begin
                Feature_Width_Capture <= Feature_Width;
            end else if(c_state == S_DONE) begin
                Feature_Width_Capture <= 8'd0;
            end
        end
    end
    
    always@(posedge clk or negedge reset_n) begin
        if(!reset_n) begin
            Feature_Height_Capture <= 8'd0;
        end else begin
            if(Feature_Height_Valid) begin
                Feature_Height_Capture <= Feature_Height;
            end else if(c_state == S_DONE) begin
                Feature_Height_Capture <= 8'd0;
            end
        end
    end
    /////////////////////////////////////////////////////////////////////////////////// Always For Capture Datas
    
    /////////////////////////////////////////////////////////////////////////////////// Always For LineBuffer Write & Read 
    always@(posedge clk or negedge reset_n) begin
        if(!reset_n) begin
            Buffer_Ring_Write_Counter <= 4'b0001;       // LSB Buffer0, Buffer1, Buffer2, Buffer3 MSB
        end else begin
            if(Line_Write_Done) begin
                if(Buffer_Ring_Write_Counter == 4'b1000) begin
                    Buffer_Ring_Write_Counter <= 4'b0001;
                end else begin
                    Buffer_Ring_Write_Counter <= (Buffer_Ring_Write_Counter) << 1;
                end
            end else if(c_state == S_DONE) begin
                Buffer_Ring_Write_Counter <= 4'b0001;
            end
        end
    end
    
    always@(posedge clk or negedge reset_n) begin
        if(!reset_n) begin
            LineBuffer_Write_Addr_Counter <= {AWIDTH{1'b0}};
        end else begin
            if(c_state == S_WRITE_FIRST || c_state == S_WRITE_AND_READ) begin
                if(Line_Write_Done) begin
                    LineBuffer_Write_Addr_Counter <= {AWIDTH{1'b0}};
                end else begin
                    LineBuffer_Write_Addr_Counter <= LineBuffer_Write_Addr_Counter + 10'd1;
                end
            end else begin
                LineBuffer_Write_Addr_Counter <= {AWIDTH{1'b0}};
            end
        end
    end
    
    always@(posedge clk or negedge reset_n) begin
        if(!reset_n) begin
            LineBuffer_Read_Addr_Counter <= {AWIDTH{1'b0}};
        end else begin
            if(c_state == S_WRITE_AND_READ || c_state == S_READ) begin
                if(Line_Read_Done) begin
                    LineBuffer_Read_Addr_Counter <= {AWIDTH{1'b0}};
                end else begin
                    LineBuffer_Read_Addr_Counter <= LineBuffer_Read_Addr_Counter + 10'd1;
                end
            end else begin
                LineBuffer_Read_Addr_Counter <= {AWIDTH{1'b0}};
            end
        end
    end
    
    /////////////////////////////////////////////////////////////////////////////////// Always For LineBuffer Write & Read 
    
    
    
    /////////////////////////////////////////////////////////////////////////////////// Always For Output Signals
    
    always@(posedge clk or negedge reset_n) begin
        if(!reset_n) begin
            Line3_Outputs_Valid <= 1'b0;
        end else begin
            if(c_state == S_READ || c_state == S_WRITE_AND_READ) begin
                Line3_Outputs_Valid <= 1'b1;
            end else begin
                Line3_Outputs_Valid <= 1'b0;
            end
        end
    end
    
    /////////////////////////////////////////////////////////////////////////////////// Always For Output Signals 
    
endmodule
