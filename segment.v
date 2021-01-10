`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/11/30 09:05:25
// Design Name: 
// Module Name: segment
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


module segment
(
input clk,clkout1,clkout2,rst,//clock and reset
input [7:0]num1,num2,num3,num4,//number to be bought
input [7:0] paid_money,//the money customer has paid
input [7:0] change,//the money we need to return
input [2:0] state,//paying state
input not_enough,//whether number of items we have < number of items to be bought, 1 for true
input [7:0]left_time,//count down time
input money_enough,//whether there is enough money, 1 for true
input done,//whether the payment is successful, 1 for true
input [7:0]require_money,//money needed
output reg [7:0] segment_led, //seven segment tube
output reg [7:0] seg_en,//enable signal for seven segment tube
output reg [6:0] led_en//used for showing paying state
);



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
    end

//used for convert binary to decimal    
wire [3:0] paid_money1,paid_money2,change1,change2,left_time1,left_time2,require_money1,require_money2;

bcd_converter uuu1(paid_money,paid_money1,paid_money2);
bcd_converter uuu2(change,change1,change2);
bcd_converter uuu3(left_time,left_time1,left_time2);
bcd_converter uuu4(require_money,require_money1,require_money2);

//seven paying state
parameter [2:0]state_st=3'b001,state_select=3'b010,state_check=3'b011,state_time=3'b100,state_pay=3'b101,state_change=3'b110,state_return=3'b111;

//select tube
reg [3:0]select_cnt=0;
always @ (posedge clkout2)
begin
    if(!rst)
    begin
        select_cnt=1'b0;
    end
    else if(select_cnt==4'd9)
    begin
        select_cnt=1'b0;
    end
    else
    begin
        select_cnt=select_cnt+1'b1;
    end
end

//FSM
always @ (posedge clkout2)
begin
    if(rst)
    begin
    case(state)
    state_st:
    begin
        led_en=7'b0000000;
        seg_en=8'b1111_1111;
    end
    state_select://each number to be bought
    begin
        led_en=7'b0000010;
        case(select_cnt)
            4'd1:
            begin
                seg_en=8'b0111_1111;
                segment_led=8'b1010_1011;//n
            end
            4'd2:
            begin
                seg_en=8'b1011_1111;
                segment_led=8'b1110_0011;//u
            end
            4'd3:
            begin
                seg_en=8'b1101_1111;
                segment_led=8'b1010_1011;//n
            end
            4'd4:
            begin
                seg_en=8'b1110_1111;
                segment_led=seg[num1];
            end
            4'd5:
            begin
                seg_en=8'b1111_0111;
                segment_led=seg[num2];
            end
            4'd6:
            begin
                seg_en=8'b1111_1011;
                segment_led=seg[num3];
            end
            4'd7:
            begin
                seg_en=8'b1111_1101;
                segment_led=seg[num4];
            end                                    
            default:
            seg_en=8'b1111_1111;
        endcase            
    end
    state_check://
    begin
    led_en=7'b0000100;
    if(not_enough)//lack items, output FAIL
                    begin
                    case(select_cnt)
                    4'd1:
                    begin
                        seg_en=8'b0111_1111;
                        segment_led=8'b10001110;//F
                    end
                    4'd2:
                    begin
                        seg_en=8'b1011_1111;
                        segment_led=8'b10001000;//A
                    end
                    4'd3:
                    begin
                        seg_en=8'b1101_1111;
                        segment_led=8'b1111_1001;//I
                    end
                    4'd4:
                    begin
                        seg_en=8'b1110_1111;
                        segment_led=8'b1100_0111;//L
                    end
                    default:
                        seg_en=8'b1111_1111;
                    endcase  
                    end
    else
    begin
        seg_en=8'b1111_1111;
        segment_led=8'b1111_1111;
    end      
    end
    state_time:
    begin
        led_en=7'b0001000; 
        case(select_cnt)//output left_time, paid_money, require_money
                4'd1:
                begin
                    seg_en=8'b0111_1111;
                    segment_led=seg[left_time1];
                end
                4'd2:
                begin
                    seg_en=8'b1011_1111;
                    segment_led=seg[left_time2];
                end
                4'd3:
                begin
                    seg_en=8'b1110_1111;
                    segment_led=seg[paid_money1];
                end
                4'd4:
                begin
                    seg_en=8'b1111_0111;
                    segment_led=seg[paid_money2];
                end
                4'd5:
                begin
                    seg_en=8'b1111_1101;
                    segment_led=seg[require_money1];
                end
                4'd6:
                begin
                    seg_en=8'b1111_1110;
                    segment_led=seg[require_money2];
                end
                default:
                    seg_en=8'b1111_1111;
                endcase       
    end
    state_pay:
    begin
        led_en=7'b0010000;
        seg_en=8'b1111_1111;
    end
    state_change://output rE change
    begin
        led_en=7'b0100000;
        case(select_cnt)
                4'd1:
                begin
                    seg_en=8'b0111_1111;
                    segment_led=8'b1010_1111;//r
                end
                4'd2:
                begin
                    seg_en=8'b1011_1111;
                    segment_led=8'b1000_0110;//E
                end
                4'd3:
                begin
                    seg_en=8'b1101_1111;
                    segment_led=seg[change1];
                end
                4'd4:
                begin
                    seg_en=8'b1110_1111;
                    segment_led=seg[change2];
                end
                default:
                    seg_en=8'b1111_1111;
                endcase
    end
    state_return://output rE change done
    begin
        led_en=7'b1000000;
        case(select_cnt)
                        4'd1:
                        begin
                            seg_en=8'b0111_1111;
                            segment_led=8'b1010_1111;//r
                        end
                        4'd2:
                        begin
                            seg_en=8'b1011_1111;
                            segment_led=8'b1000_0110;//E
                        end
                        4'd3:
                        begin
                            seg_en=8'b1101_1111;
                            segment_led=seg[change1];
                        end
                        4'd4:
                        begin
                            seg_en=8'b1110_1111;
                            segment_led=seg[change2];
                        end
                               4'd5:
                               begin
                                   seg_en=8'b1111_0111;
                                   segment_led=8'b10100001;//d
                               end
                               4'd6:
                               begin
                                   seg_en=8'b1111_1011;
                                   segment_led=8'b1010_0011;//o
                               end
                               4'd7:
                               begin
                                   seg_en=8'b1111_1101;
                                   segment_led=8'b1010_1011;//n
                               end
                               4'd8:
                               begin
                                   seg_en=8'b1111_1110;
                                   segment_led=8'b1000_0110;//E
                               end
                        default:
                            seg_en=8'b1111_1111;
                        endcase
    end
    default:
        led_en=6'b000000;
    endcase
    end
    else
    begin
        led_en=6'b000000;
    end
end

endmodule
