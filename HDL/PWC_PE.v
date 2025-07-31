`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/08/01 00:54:24
// Design Name: 
// Module Name: PWC_PE
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

// 1x1 Convolution For 32 Channels
// The Tile Size is 8 * 4

module PWC_PE#(
    parameter DWIDTH = 8,
    parameter P_CH = 32
)(
    input clk,
    input reset_n,
    
    input [DWIDTH * P_CH - 1 : 0] Feature_Input,    // Need Capture
    input Feature_Input_Valid,
    
    input [DWIDTH * P_CH - 1 : 0] Weights_Input,    // Need No Capture
    
    output [DWIDTH*4-1:0] Convolutioned_Output      // Convolutioned Output
    );
endmodule
