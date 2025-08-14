`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/08/01 01:33:22
// Design Name: 
// Module Name: DWC_PE
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

// 3x3 Feature and 3x3 Weights's Convolution

module DWC_PE#(
    parameter DWIDTH = 8,
    parameter K_SIZE = 3
)(
    input clk,
    input reset_n,
    
    input [DWIDTH * K_SIZE * K_SIZE - 1 : 0] Weight_Inputs, // {MSB Pixel 0, Pixel 1, Pixel 2, ... Pixel 8 LSB}
    input Weight_Inputs_Valid,
    
    input [DWIDTH * K_SIZE * K_SIZE - 1 : 0] Feature_Inputs,// {MSB Pixel 0, Pixel 1, Pixel 2, ... Pixel 8 LSB}
    input Feature_Inputs_Valid,
    
    output reg signed [19:0] Convolutioned_Output,
    output reg Output_Valid
    );
    
    reg [DWIDTH * K_SIZE * K_SIZE - 1 : 0] Weight_Station;
    
    always@(posedge clk or negedge reset_n) begin
        if(!reset_n) begin
            Weight_Station <= {(DWIDTH * K_SIZE * K_SIZE){1'b0}};
        end else begin
            if(Weight_Inputs_Valid) begin
                Weight_Station <= Weight_Inputs;
            end
        end
    end
    
    wire signed [DWIDTH - 1:0] Weights [0:(K_SIZE * K_SIZE - 1)];
    wire signed [DWIDTH - 1 :0] Inputs [0:(K_SIZE * K_SIZE - 1)];
    wire signed [DWIDTH * 2 - 1 :0] Muls [0:(K_SIZE * K_SIZE - 1)];
    
    genvar i;
    generate
        for (i=0;i<K_SIZE * K_SIZE;i=i+1) begin
            assign Weights[i] =  Weight_Station[((K_SIZE * K_SIZE - i)*DWIDTH-1)-:DWIDTH];
        end
        
        for (i=0;i<K_SIZE * K_SIZE;i=i+1) begin
            assign Inputs[i] =  Feature_Inputs[((K_SIZE * K_SIZE - i)*DWIDTH-1)-:DWIDTH];
        end
        
        for (i=0;i<K_SIZE * K_SIZE;i=i+1) begin
            assign Muls[i] =  Weights[i] * Inputs[i];
        end
    endgenerate
    
    wire signed [19:0] sum1 = $signed(Muls[0]) + $signed(Muls[1]);
    wire signed [19:0] sum2 = $signed(Muls[2]) + $signed(Muls[3]);
    wire signed [19:0] sum3 = $signed(Muls[4]) + $signed(Muls[5]);
    wire signed [19:0] sum4 = $signed(Muls[6]) + $signed(Muls[7]);
    wire signed [19:0] sum5 = sum1 + sum2;
    wire signed [19:0] sum6 = sum3 + sum4;
    wire signed [19:0] sum7 = sum5 + sum6 + $signed(Muls[8]);
    
    always@(posedge clk or negedge reset_n) begin
        if(!reset_n) begin
            Convolutioned_Output <= {20{1'b0}};
        end else begin
            if(Feature_Inputs_Valid) begin
                Convolutioned_Output <= sum7;
            end else begin
            end
        end
    end
    
    always@(posedge clk or negedge reset_n) begin
        if(!reset_n) begin
            Output_Valid <= 1'b0;
        end else begin
            if(Feature_Inputs_Valid) begin
                Output_Valid <= 1'b1;
            end else begin
                Output_Valid <= 1'b0;
            end
        end
    end
    
    wire [63:0] Spikes;
    reg [63:0] Input_Feature_Serial;
    reg [1:0] Input_Bit_Counter;
    reg [3:0] Quant_Feature;
    wire Conv_Valid;
    
    always@(posedge clk or negedge reset_n) begin
        if(!reset_n) begin
            Input_Bit_Counter <= 2'd0;
        end else begin
            if(Conv_Valid)
                Input_Bit_Counter <= Input_Bit_Counter + 2'd1;
        end
    end
    
    
endmodule
