`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/11/29 10:34:47
// Design Name: 
// Module Name: replenishment
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

module replenishment(
    input clk,clkout1,clkout2,//clock signal
    input rst,//reset
    input chd1,chd2,chd3,chd4,//the aisle chosen for replenishment
    input csw1,//query the quantity sold
    input csw2,//supplemental goods
    input csw3,//query the total price
    input [3:0] key_value,
    output [7:0] DIG,//frequency divider parameters
    output [7:0] Y,//frequency divider parameters
    
    input [7:0] in_S1_sell,in_S2_sell,in_S3_sell,in_S4_sell,//The quantity of each item sold
    input [7:0] in_S1_num,in_S2_num,in_S3_num,in_S4_num,//The quantity of each item
    input [7:0] price_sum,//total sales
    output reg [7:0]  S1_num,S2_num,S3_num,S4_num//The quantity of each item after replenishment
    );
    
    wire hd1,hd2,hd3,hd4,sw1,sw2,sw3;
    debounce us2(clk,rst,chd1,hd1);
    debounce us3(clk,rst,chd2,hd2);
    debounce us4(clk,rst,chd3,hd3);
    debounce us5(clk,rst,chd4,hd4);
    debounce us6(clk,rst,csw1,sw1);
    debounce us7(clk,rst,csw2,sw2);
    debounce us8(clk,rst,csw3,sw3);
    
    parameter price1=5'd4,price2=5'd9,price3=5'd13,price4=5'd17;
    
    reg flag=1'b0;//judge the replenishment status
    
    
         //state machine
         parameter state_1=2'b01,state_2=2'b10,state_3=2'b11;
         reg [1:0]state=2'b00;
    
    initial begin
         flag=1'b0;
         state=2'b00;     
         end
              
     always@(posedge clkout1)
     begin
        if(!rst)
        begin
             S1_num = 8'd0;
             S2_num = 8'd0;
             S3_num = 8'd0;
             S4_num = 8'd0;
             flag=1'b0;
             state=2'b00;
        end
        else
        begin
            if(sw1)
                state=2'b01;
            else if(sw2)
            begin
                state=2'b10;
                S1_num = in_S1_num;
                S2_num = in_S2_num;
                S3_num = in_S3_num;
                S4_num = in_S4_num;
            end
            else if(sw3)
                state=2'b11;
            else
                state=2'b00;
                
            case(state)
            //query the quantity sold
            state_1:
            begin
                
            end
            //supplemental goods
            state_2:
            begin
            if(key_value==4'd14)
            begin
                S1_num = S1_num;
                S2_num = S2_num;
                S3_num = S3_num;
                S4_num = S4_num;
                flag=1'b1;
            end
            
            else
            begin
            flag=1'b0;
                if(hd1&&(S1_num+key_value)<8'd100) S1_num = S1_num+key_value;
                else S1_num = S1_num;
                if(hd2&&(S2_num+key_value)<8'd100) S2_num = S2_num+key_value;
                else S2_num = S2_num;
                if(hd3&&(S3_num+key_value)<8'd100) S3_num = S3_num+key_value;
                else S3_num = S3_num;
                if(hd4&&(S4_num+key_value)<8'd100) S4_num = S4_num+key_value;
                else S4_num = S4_num;            
            end    
            end
            //query the total price
            state_3:
            begin
            
            end
            
            default:
            begin
            S1_num = S1_num;
            S2_num = S2_num;
            S3_num = S3_num;
            S4_num = S4_num;          
            end
            endcase
        end
     end
     
     
     segment_rep used3(clkout2,clkout1,rst,sw1,sw2,sw3,flag,hd1,hd2,hd3,hd4,DIG,Y,
                       S1_num,S2_num,S3_num,S4_num,in_S1_sell,in_S2_sell,in_S3_sell,in_S4_sell,price_sum);
endmodule
