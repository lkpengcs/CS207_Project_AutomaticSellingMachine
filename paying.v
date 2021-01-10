`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/11/29 20:14:43
// Design Name: 
// Module Name: paying
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


module paying (
input clk,clkout1,clkout2,clkout3,rst,//clock and reset
input [3:0] key_value,//key value from matrix keyboard
input inmoney1,inmoney2,inmoney3,inmoney4,//four kinds of money
input ins1,ins2,ins3,ins4,//select four items
input [7:0] nownum1,nownum2,nownum3,nownum4,//the number of items before the deal
output reg [7:0] newnum1,newnum2,newnum3,newnum4,//the number of items after the deal
output [7:0] segment_led, //seven segment tube
output [7:0] seg_en,//enable signal for seven segment tube
output [6:0] led_en,//used for showing paying state
output reg [7:0] require_money,//total amount of money to be paid
output reg [7:0] sellnum1,sellnum2,sellnum3,sellnum4,//number of items sold each time
output reg flag//whether the payment is successful
    );
    //seven paying state
    parameter [2:0]state_st=3'b001,state_select=3'b010,state_check=3'b011,state_time=3'b100,state_pay=3'b101,state_change=3'b110,state_return=3'b111;
    //price for four items
    parameter item1=5'd4, item2=5'd9, item3=5'd13, item4=5'd17;
    //used to count number to be bought each time
    reg [7:0]num1=8'd0,num2=8'd0,num3=8'd0,num4=8'd0;
    
    reg [7:0] paid_money;//the money customer has paid
    reg [7:0] change;//the money we need to return
    reg [2:0] state;//paying state
    reg not_enough;//whether number of items we have < number of items to be bought, 1 for true
    reg [7:0]left_time=8'd30;//count down time
    reg money_enough;//whether there is enough money, 1 for true
    reg done;//whether the payment is successful, 1 for true
    
    reg timecount=1'b0;//start counting time from 30s to 0s
    reg left_flag=1'b1;//whether number of items we have > number of items to be bought, 1 for true
    reg ifmoney1,ifmoney2,ifmoney3,ifmoney4;//if i-st kind of money is used(i=1,2,3,4)
    reg pay_confirm,return_button;//confirm payment and return to state_st
    reg num_confirm;//confirm number selection
    
    always@(posedge clk)
    begin
        case(key_value)
        4'd13://D in the keyboard--num_confirm
        begin
            num_confirm=1'b1;
            pay_confirm=1'b0;
            return_button=1'b0; 
        end
        4'd14://# in the keyboard--pay_confirm
        begin
            pay_confirm=1'b1;
            num_confirm=1'b0;
            return_button=1'b0;
        end   
        4'd15://* in the keyboard--return_button
        begin
            return_button=1'b1;
            pay_confirm=1'b0;
            num_confirm=1'b0;
        end
        default:
        begin
            pay_confirm=1'b0;
            return_button=1'b0;
            num_confirm=1'b0;
        end
        endcase
    end
    
    wire money1,money2,money3,money4;
    wire s1,s2,s3,s4;//used for debounce
    
    //initialization
    initial
        begin
            paid_money=8'd0;
            change=8'd0;
            not_enough=1'b0;
            money_enough=1'b1;
            done=1'b0;
            left_time=8'd30;
            left_flag=1'b1;
            num1=8'd0;
            num2=8'd0;
            num3=8'd0;
            num4=8'd0;
            flag=1'b0;
            require_money=8'd0;
            sellnum1=8'd0;
            sellnum2=8'd0;
            sellnum3=8'd0;
            sellnum4=8'd0;
            state=state_st;
        end
    
    //debounce
    debounce uu1(clk,rst,inmoney1,money1);
    debounce uu2(clk,rst,inmoney2,money2);
    debounce uu3(clk,rst,inmoney3,money3);
    debounce uu4(clk,rst,inmoney4,money4);
    
    debounce u_select1(clk,rst,ins1,s1);
    debounce u_select2(clk,rst,ins2,s2);
    debounce u_select3(clk,rst,ins3,s3);
    debounce u_select4(clk,rst,ins4,s4);
    

    //count number to be bought
    always@(posedge clkout1)
        begin
            if((!num_confirm)&&(state==state_select))
            begin
                if(s1)
                num1=num1+8'd1;
                else
                num1=num1;
                if(s2)
                num2=num2+8'd1;
                else
                num2=num2;
                if(s3)
                num3=num3+8'd1;
                else
                num3=num3;
                if(s4)
                num4=num4+8'd1;
                else
                num4=num4;
            end
            else
            begin
                num1=8'd0;
                num2=8'd0;
                num3=8'd0;
                num4=8'd0;
            end
        end
    
    //count down time 
    always@(posedge clkout1)
    begin
        if(timecount)
        begin
            left_time=left_time-1'b1;
        end
        else
        begin
            left_time=8'd30;
        end
    end
    
    //count paid_money
    always @ (posedge clkout1)
    begin
        if(timecount)
        begin
            if(money1)
            begin
                ifmoney1=1'b1;
            end
            else
            begin
                ifmoney1=1'b0;
            end               
            if(money2)
            begin
                ifmoney2=1'b1;
            end
            else
            begin
                ifmoney2=1'b0;
            end
            if(money3)
            begin
                ifmoney3=1'b1;
            end
            else
            begin
                ifmoney3=1'b0;
            end
            if(money4)
            begin
                ifmoney4=1'b1;
            end
            else
            begin
                ifmoney4=1'b0;
            end
            paid_money=paid_money+ifmoney1*(4'd1)+ifmoney2*(4'd2)+ifmoney3*(4'd5)+ifmoney4*(4'd10);
        end
        else
        begin
            paid_money=8'd0;
        end
    end
    
    //FSM
    always @(posedge clkout2)
    begin
    if(!rst)
    begin
        state=state_st;    
    end   
    else
    begin     
        case(state)
            state_st://initialization
            begin
                change=8'd0;
                timecount=1'b0;
                money_enough=1'b1;
                done=1'b0;
                newnum1=nownum1;
                newnum2=nownum2;
                newnum3=nownum3;
                newnum4=nownum4;
                flag=1'b0;
                require_money=8'd0;
                sellnum1=8'd0;
                sellnum2=8'd0;
                sellnum3=8'd0;
                sellnum4=8'd0;                
                if(left_flag)//enter state_select
                begin
                    state=state_select;
                end
                else
                begin//reset
                    left_flag=1'b1;
                    not_enough=1'b0;
                    state=state_st;
                end
            end
            
            state_select:
            begin
                if((nownum1>=num1)&&(nownum2>=num2)&&(nownum3>=num3)&&(nownum4>=num4))//have enough number of items
                begin
                    require_money=num1*item1+num2*item2+num3*item3+num4*item4;//calculate money needed
                    newnum1=nownum1-num1;//update number after deal
                    newnum2=nownum2-num2;
                    newnum3=nownum3-num3;
                    newnum4=nownum4-num4;
                    sellnum1=nownum1-newnum1;//update number sold
                    sellnum2=nownum2-newnum2;
                    sellnum3=nownum3-newnum3;
                    sellnum4=nownum4-newnum4; 
                end
                else
                begin
                    left_flag=1'b0;//not enough
                end
                
                if(num_confirm)//enter check state
                begin
                    state=state_check;
                end
                else
                begin
                    state=state_select;
                end
            end
            
            state_check:
            begin
                if(left_flag)//enough then count down time
                begin
                    state=state_time;
                end
                else//return to state_st
                begin
                    not_enough=1'b1;
                    if(!return_button)
                        state=state_check;
                    else
                    begin
                        not_enough=1'b0;
                        left_flag=1'b1;
                        state=state_st;
                    end
                end
            end
            
            state_time:
            begin
                timecount=1'b1;
                if((pay_confirm)||(left_time==8'd0))//confirm payment or no time left, enter state_pay
                begin
                    timecount=1'b0;
                    state=state_pay;
                end
                else
                begin
                    state=state_time;
                end
            end
            
            state_pay:
            begin
                if(paid_money>require_money-1'b1)//successful
                begin
                    timecount=1'b0;
                    change=paid_money-require_money;
                    flag=1'b1;  
                    done=1'b1;                 
                    state=state_return;
                end
                else//failed
                begin
                    timecount=1'b0;
                    change=paid_money;
                    state=state_change;
                end
            end
            
            state_change://return paid money
            begin
                money_enough=1'b0;
                if(pay_confirm||(left_time<8'd1))
                begin
                state=state_change;
                end
                if(return_button)
                begin
                state=state_st;
                end
                else
                begin
                    state=state_change;
                end
            end
            
            state_return://return change
            begin
                flag=1'b0;
                if(pay_confirm)
                begin
                state=state_return;
                end
                else
                begin
                state=state_st;
                end
            end
        endcase
        end
    end
    
    //instantiate module
    segment u0(clk,clkout1,clkout2,rst,
    num1,num2,num3,num4,
    paid_money,change,state,not_enough,left_time,money_enough,done,require_money,segment_led,seg_en,led_en);
endmodule
