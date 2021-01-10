`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/12/23 02:45:35
// Design Name: 
// Module Name: bcd_converter_3bit
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


module bcd_converter_3bit(
input [7:0] binary,
output reg[3:0] hundreds,tens,ones
    );
    
    integer i;
    always@(binary)
    begin
        hundreds=4'd0;
        tens=4'd0;
        ones=4'd0;
        for(i=7;i>=0;i=i-1)
        begin
            if(hundreds>=5)
            hundreds=hundreds+3;        
            if(tens>=5)
                tens=tens+3;
            if(ones>=5)
                ones=ones+3;
            hundreds=hundreds<<1;
            hundreds[0]=tens[3];                
            tens=tens<<1;
            tens[0]=ones[3];
            ones=ones<<1;
            ones[0]=binary[i];
        end
    end
endmodule