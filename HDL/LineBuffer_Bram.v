`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/08/01 01:31:44
// Design Name: 
// Module Name: LineBuffer_Bram
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

// Max Width = 224, Max Height = 224
module LineBuffer_Bram#(
    parameter DWIDTH = 8,
    parameter P_CH = 32,
    parameter MEM_SIZE = 512,
    parameter AWIDTH = 10
)(
    input clk,
    
    input [AWIDTH-1:0] Addr0,
    input [DWIDTH * P_CH - 1 : 0] D0,
    output reg [DWIDTH * P_CH - 1 : 0] Q0,
    input ce0,
    input we0
    );
    
    (*ram_style = "block"*) reg [DWIDTH * P_CH - 1 : 0] ram [0:MEM_SIZE-1];
    
    always@(posedge clk) begin
        if(ce0) begin
            if(we0) begin
                ram[Addr0] <= D0;
            end else begin
                Q0 <= ram[Addr0];
            end
        end
    end
    
endmodule
