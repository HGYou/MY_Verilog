`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/08/01 00:55:12
// Design Name: 
// Module Name: ReLU
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


module ReLU#(
    parameter DWIDTH = 32
)(
    
    input wire signed [DWIDTH-1:0] ConvedOutput,
    output wire signed [DWIDTH-1:0] ReLUedOutput
    );
    
    assign ReLUedOutput = (ConvedOutput[DWIDTH-1] == 1'b1)? {DWIDTH{1'b0}} : ConvedOutput;
    
endmodule
