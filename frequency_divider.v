`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/12/3 09:00:30
// Design Name: 
// Module Name: frequency_divider
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


module frequency_divider #(parameter period=100000000)
(
input clk,rst,
output reg clkout
    );

reg[31:0] cnt=0;
always @ (posedge clk or negedge rst)
begin
    if(rst == 0)
    begin
            cnt<=0;
            clkout<=0;
    end
    else
    begin
        if(cnt == (period >> 1) - 1)//when cnt==half of period, flip clkout
        begin
            clkout<=~clkout;
            cnt<=0;
        end
        else
            cnt<=cnt+1;
    end
end
endmodule