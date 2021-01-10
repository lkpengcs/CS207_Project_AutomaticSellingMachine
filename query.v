`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/11/29 16:47:43
// Design Name: 
// Module Name: query
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


module query(input clk,clkout1,clkout2,rst,payperiod,shift1,shift2,shift3,shift4,
input [7:0]left1,left2,left3,left4,
output reg [7:0]DIG,reg[7:0]Y,
output beep);
//payperiod: enter pay state
//shift select four items 1,2,3,4 
reg [31:0]cnt;
reg [2:0]scan_cnt;
reg [2:0]order;//four items 1,2,3,4
reg [7:0] name[3:0];//item name
reg [7:0] left[3:0];//number left
reg [7:0] price[3:0];//item price
//bcd converter
wire [3:0] leftten[3:0];
wire [3:0] leftone[3:0];
wire [3:0] priceten[3:0];
wire [3:0] priceone[3:0];
parameter period = 1000000;
reg [2:0] shift;//if is choosing item 
//used for debounce
wire shift1_out;
wire shift2_out;
wire shift3_out;
wire shift4_out;
wire payperiod_out;
//buzzer
Bpmusic BGM(clk,rst,payperiod,beep);
//instantiate module
bcd_converter leftbcd0(left[0],leftten[0],leftone[0]);
bcd_converter leftbcd1(left[1],leftten[1],leftone[1]);
bcd_converter leftbcd2(left[2],leftten[2],leftone[2]);
bcd_converter leftbcd3(left[3],leftten[3],leftone[3]);
bcd_converter pricebcd0(price[0],priceten[0],priceone[0]);
bcd_converter pricebcd1(price[1],priceten[1],priceone[1]);
bcd_converter pricebcd2(price[2],priceten[2],priceone[2]);
bcd_converter pricebcd3(price[3],priceten[3],priceone[3]);
debounce shift11(clk,rst,shift1,shift1_out);
debounce shift22(clk,rst,shift2,shift2_out);
debounce shift33(clk,rst,shift3,shift3_out);
debounce shift44(clk,rst,shift4,shift4_out);
debounce payperiod0(clk,rst,payperiod,payperiod_out);

reg[7:0] seg [15:0]; //data for decode
initial
    begin
        seg[0] = 8'b11000000;   //  0
        seg[1] = 8'b11111001;   //  1
        seg[2] = 8'b10100100;   //  2
        seg[3] = 8'b10110000;   //  3
        seg[4] = 8'b10011001;   //  4
        seg[5] = 8'b10010010;   //  5
        seg[6] = 8'b10000010;   //  6
        seg[7] = 8'b11111000;   //  7
        seg[8] = 8'b10000000;   //  8
        seg[9] = 8'b10010000;   //  9
        seg[10]= 8'b10001000;   //  A
        seg[11]= 8'b10000011;   //  b
        seg[12]= 8'b11000110;   //  C
        seg[13]= 8'b10100001;   //  d
        seg[14]= 8'b10000110;   //  E
        seg[15]= 8'b10001110;   //  F
        
        price[0]=8'b00000100;//4
        price[1]=8'b00001001;//9
        price[2]=8'b00001101;//13
        price[3]=8'b00010001;//17
        
        name[0]=8'b10001000;//A
        name[1]=8'b10000011;//B
        name[2]=8'b11000110;//C
        name[3]=8'b10100001;//D
        
        left[0]=left1;
        left[1]=left2;
        left[2]=left3;
        left[3]=left4;
    end

//update left number    
always@(left1,left2,left3,left4)
begin
        left[0]=left1;
        left[1]=left2;
        left[2]=left3;
        left[3]=left4;
end

always@(posedge clkout1 or negedge rst)//change order based on clkout1
begin
    if(!rst) 
    begin
        order = 1;
    end
    else 
    begin
        order = order+1;
        if(order == 3'd6) 
        begin
             order =1;
        end
        if( shift != 3'd0)
        begin
        order = shift; 
        end
    end
    
end

always@(posedge clkout2 or negedge rst)//change scan_cnt based on clkout2
begin
    if(!rst) scan_cnt <=0;
    else begin
        scan_cnt <= scan_cnt+1;
        if(scan_cnt==3'd7) scan_cnt <=0;
    end
end

always @(scan_cnt)//select tube
begin
    case( scan_cnt)
        3'b000: DIG = 8'b1111_1110;
        3'b001: DIG = 8'b1111_1101;
        3'b010: DIG = 8'b1111_1011;
        3'b011: DIG = 8'b1111_0111;
        3'b100: DIG = 8'b1111_1111;
        3'b101: DIG = 8'b1101_1111;
        3'b110: DIG = 8'b1111_1111;
        3'b111: DIG = 8'b0111_1111;
        default:DIG = 8'b1111_1111;
    endcase
end

always @(shift1_out or shift2_out or shift3_out or shift4_out)//select item
begin
    case({shift1_out,shift2_out,shift3_out,shift4_out})
    
        4'b1000: shift = 3'd1;
        4'b0100: shift = 3'd2;
        4'b0010: shift = 3'd3;
        4'b0001: shift = 3'd4;
        4'b0000: shift = 3'd0;
        default:
        begin
            shift=3'd0;
        end
        
endcase
end

always @(scan_cnt,order,rst)//decoder to display on 7-seg tube
begin
    if(order==5 || (!rst))begin
        case(scan_cnt)
            0:Y = 8'b11111111;//nothing
            1:Y = 8'b11111111;//nothing
            2:Y = 8'b11111111;//nothing
            3:Y = 8'b11111111;//nothing
            4:Y = 8'b11111111;//nothing
            5:Y = 8'b11111111;//nothing
            6:Y = 8'b11111111;//nothing
            7:Y = 8'b11111111;//nothing
            default:
            begin
                Y=8'b1111_1111;
            end
        endcase
    end 
    else begin
            case(scan_cnt)
                       0:Y = seg[priceone[order-1]];//priceone
                       1:Y = seg[priceten[order-1]];//priceten
                       2:Y = seg[leftone[order-1]];//leftone
                       3:Y = seg[leftten[order-1]];//leftten
                       4:Y = 8'b11111111;//nothing
                       5:Y = name[order-1];//name
                       6:Y = 8'b11111111;//nothing
                       7:Y = seg[order];//order
                       default:
                       begin
                           Y=8'b1111_1111;
                       end
            endcase
    end
end

endmodule
