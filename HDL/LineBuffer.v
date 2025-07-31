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
    
    output [3 * (DWIDTH * P_CH) - 1 : 0] Line3_Outputs,
    output Line3_Outputs_Valid
    );
endmodule
