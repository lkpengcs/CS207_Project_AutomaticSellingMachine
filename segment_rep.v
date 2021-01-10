`timescale 1ns / 1ps

module segment_rep(
   input clk,//clock
   input clkout,//frequency clock
   input rst,//reset
   input sw1,//query the quantity sold
   input sw2,//supplemental goods
   input sw3,//query the total price
   input flag,//judge the replenishment status
   input hd1,hd2,hd3,hd4,//the aisle chosen for replenishment
   output reg [7:0] DIG,//enable signal for seven segment tube
   output reg [7:0] Y,//seven segment tube
   input [7:0]s1,s2,s3,s4,//current number
   input [7:0]sl1,sl2,sl3,sl4,//total sold number 
   input [7:0]price_sum//total sales
    );

      reg [3:0] scan_cnt;
      reg [7:0] seg[15:0];//data for decode
      reg [2:0] count;
      //bcd converter
      wire tens,ones;
      wire [3:0] tenss[12:0];
      wire [3:0] oness[12:0];
      wire [3:0] hundreds;
      bcd_converter usd5(8'd99-s1,tenss[0],oness[0]);
      bcd_converter usd6(8'd99-s2,tenss[1],oness[1]);
      bcd_converter usd7(8'd99-s3,tenss[2],oness[2]);
      bcd_converter usd8(8'd99-s4,tenss[3],oness[3]);
      bcd_converter usd9(sl1,tenss[4],oness[4]);
      bcd_converter usd10(sl2,tenss[5],oness[5]);
      bcd_converter usd11(sl3,tenss[6],oness[6]);
      bcd_converter usd12(sl4,tenss[7],oness[7]);
      bcd_converter_3bit usd13(price_sum,hundreds,tenss[8],oness[8]);
      bcd_converter usd14(s1,tenss[9],oness[9]);
      bcd_converter usd15(s2,tenss[10],oness[10]);
      bcd_converter usd16(s3,tenss[11],oness[11]);
      bcd_converter usd17(s4,tenss[12],oness[12]);
      
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
      
    // To stabilize the display of the seven-segment digital tube     
    always@(posedge clk,negedge rst)
        begin
            if(!rst)
            scan_cnt <= -1;
        else begin
            scan_cnt <= scan_cnt +1'b1;
            if(scan_cnt == 4'd7) scan_cnt <= 4'd0;
            end
        end  
     //scrolling display   
    always@(posedge clkout ,negedge rst)       
        begin
            if(!rst)
            begin
            count <= 0;
            end
        else 
        begin
           count <= count +1'b1;
           if(count == 3'd4) 
           begin
           count <= 3'd0;
           end
        end
        end 
       
    always@(scan_cnt,count,sw1,sw2,sw3,flag,hd1,hd2,hd3,hd4,s1,s2,s3,s4)
        begin
        //Scroll to show the number of units sold
        if(sw1) 
        case(count)
            1:  case(scan_cnt)
                4'd0: begin DIG = 8'b01111111; Y=seg[1]; end
                4'd1: begin DIG = 8'b11111111; end
                4'd2: begin DIG = 8'b11011111; Y=seg[10]; end
                4'd3: begin DIG = 8'b11111111; end
                4'd4: begin DIG = 8'b11111111; end
                4'd5: begin DIG = 8'b11111011; Y=seg[tenss[4]]; end
                4'd6: begin DIG = 8'b11111101; Y=seg[oness[4]]; end
                4'd7: begin DIG = 8'b11111111; end
                default:
                begin
                DIG=8'b1111_1111;
                Y=8'b1111_1111;
                end
                endcase             
            2:  case(scan_cnt)
                4'd0: begin DIG = 8'b01111111; Y=seg[2]; end
                4'd1: begin DIG = 8'b11111111; end
                4'd2: begin DIG = 8'b11011111; Y=seg[11]; end
                4'd3: begin DIG = 8'b11111111; end
                4'd4: begin DIG = 8'b11111111; end
                4'd5: begin DIG = 8'b11111011; Y=seg[tenss[5]]; end
                4'd6: begin DIG = 8'b11111101; Y=seg[oness[5]]; end
                4'd7: begin DIG = 8'b11111111; end
                                default:
                begin
                DIG=8'b1111_1111;
                Y=8'b1111_1111;
                end
                endcase 
            3:  case(scan_cnt) 
                4'd0: begin DIG = 8'b01111111; Y=seg[3]; end
                4'd1: begin DIG = 8'b11111111; end
                4'd2: begin DIG = 8'b11011111; Y=seg[12]; end
                4'd3: begin DIG = 8'b11111111; end
                4'd4: begin DIG = 8'b11111111; end
                4'd5: begin DIG = 8'b11111011; Y=seg[tenss[6]]; end
                4'd6: begin DIG = 8'b11111101; Y=seg[oness[6]]; end
                4'd7: begin DIG = 8'b11111111; end
                                default:
                begin
                DIG=8'b1111_1111;
                Y=8'b1111_1111;
                end
                endcase
            4:  case(scan_cnt) 
                4'd0: begin DIG = 8'b01111111; Y=seg[4]; end
                4'd1: begin DIG = 8'b11111111; end
                4'd2: begin DIG = 8'b11011111; Y=seg[13]; end
                4'd3: begin DIG = 8'b11111111; end
                4'd4: begin DIG = 8'b11111111; end
                4'd5: begin DIG = 8'b11111011; Y=seg[tenss[7]]; end
                4'd6: begin DIG = 8'b11111101; Y=seg[oness[7]]; end
                4'd7: begin DIG = 8'b11111111; end
                                default:
                begin
                DIG=8'b1111_1111;
                Y=8'b1111_1111;
                end
                endcase 
        default:
                begin
                    DIG=8'b1111_1111;
                    Y=8'b1111_1111;
                end               
        endcase
        //Replenishment quantity display
        if(sw2)
            if(~hd1&&~hd2&&~hd3&&~hd4)
            begin
            //Replenishment prompt
            case(scan_cnt)
                4'd0: begin DIG = 8'b11111111; end
                4'd1: begin DIG = 8'b10111111; Y=seg[11]; end
                4'd2: begin DIG = 8'b11011111; Y=8'b11100011; end
                4'd3: begin DIG = 8'b11111111; end
                4'd4: begin DIG = 8'b11110111; Y=8'b10001011;end
                4'd5: begin DIG = 8'b11111011; Y=8'b11100011; end
                4'd6: begin DIG = 8'b11111101; Y=8'b10100011; end
                4'd7: begin DIG = 8'b11111111; end
                                default:
                begin
                DIG=8'b1111_1111;
                Y=8'b1111_1111;
                end
            endcase 
            end            
            if(hd1&&flag)
            begin
            case(scan_cnt)
                4'd0: begin DIG = 8'b01111111; Y=seg[13]; end
                4'd1: begin DIG = 8'b10111111; Y=8'b10100011; end
                4'd2: begin DIG = 8'b11011111; Y=8'b10101011; end
                4'd3: begin DIG = 8'b11101111; Y=seg[14]; end
                4'd4: begin DIG = 8'b11111111; end
                4'd5: begin DIG = 8'b11111011; Y=seg[10]; end
                4'd6: begin DIG = 8'b11111101; Y=seg[tenss[9]]; end
                4'd7: begin DIG = 8'b11111110; Y=seg[oness[9]]; end
                                default:
                begin
                DIG=8'b1111_1111;
                Y=8'b1111_1111;
                end
            endcase 
            end
            else if(hd1&&(!flag))
            begin
            case(scan_cnt)
                4'd0: begin DIG = 8'b01111111; Y=seg[1];end
                4'd1: begin DIG = 8'b11111111; end
                4'd2: begin DIG = 8'b11011111; Y=seg[11];end
                4'd3: begin DIG = 8'b11101111; Y=seg[11];end
                4'd4: begin DIG = 8'b11111111; end
                4'd5: begin DIG = 8'b11111011; Y=seg[10]; end
                4'd6: begin DIG = 8'b11111101; Y=seg[tenss[0]]; end
                4'd7: begin DIG = 8'b11111110; Y=seg[oness[0]]; end
                                default:
                begin
                DIG=8'b1111_1111;
                Y=8'b1111_1111;
                end
            endcase 
            end 
            else if(hd2&&flag)
            begin
            case(scan_cnt)
                4'd0: begin DIG = 8'b01111111; Y=seg[13]; end
                4'd1: begin DIG = 8'b10111111; Y=8'b10100011; end
                4'd2: begin DIG = 8'b11011111; Y=8'b10101011; end
                4'd3: begin DIG = 8'b11101111; Y=seg[14]; end
                4'd4: begin DIG = 8'b11111111; end
                4'd5: begin DIG = 8'b11111011; Y=seg[11]; end
                4'd6: begin DIG = 8'b11111101; Y=seg[tenss[10]]; end
                4'd7: begin DIG = 8'b11111110; Y=seg[oness[10]]; end
                                default:
                begin
                DIG=8'b1111_1111;
                Y=8'b1111_1111;
                end
            endcase 
            end
            else if(hd2&&(!flag))
            begin
            case(scan_cnt)
                4'd0: begin DIG = 8'b01111111; Y=seg[2]; end
                4'd1: begin DIG = 8'b11111111; end
                4'd2: begin DIG = 8'b11011111; Y=seg[11]; end
                4'd3: begin DIG = 8'b11101111; Y=seg[11]; end
                4'd4: begin DIG = 8'b11111111; end
                4'd5: begin DIG = 8'b11111011; Y=seg[11]; end
                4'd6: begin DIG = 8'b11111101; Y=seg[tenss[1]]; end
                4'd7: begin DIG = 8'b11111110; Y=seg[oness[1]]; end
                                default:
                begin
                DIG=8'b1111_1111;
                Y=8'b1111_1111;
                end
            endcase 
            end 
            else if(hd3&&flag)
            begin
            case(scan_cnt)
                4'd0: begin DIG = 8'b01111111; Y=seg[13]; end
                4'd1: begin DIG = 8'b10111111; Y=8'b10100011; end
                4'd2: begin DIG = 8'b11011111; Y=8'b10101011; end
                4'd3: begin DIG = 8'b11101111; Y=seg[14]; end
                4'd4: begin DIG = 8'b11111111; end
                4'd5: begin DIG = 8'b11111011; Y=seg[12]; end
                4'd6: begin DIG = 8'b11111101; Y=seg[tenss[11]]; end
                4'd7: begin DIG = 8'b11111110; Y=seg[oness[11]]; end
                                default:
                begin
                DIG=8'b1111_1111;
                Y=8'b1111_1111;
                end
            endcase 
            end
            else if(hd3&&(!flag))
            begin
            case(scan_cnt)
                4'd0: begin DIG = 8'b01111111; Y=seg[3]; end
                4'd1: begin DIG = 8'b11111111; end
                4'd2: begin DIG = 8'b11011111; Y=seg[11]; end
                4'd3: begin DIG = 8'b11101111; Y=seg[11]; end
                4'd4: begin DIG = 8'b11111111; end
                4'd5: begin DIG = 8'b11111011; Y=seg[12]; end
                4'd6: begin DIG = 8'b11111101; Y=seg[tenss[2]]; end
                4'd7: begin DIG = 8'b11111110; Y=seg[oness[2]]; end
                                default:
                begin
                DIG=8'b1111_1111;
                Y=8'b1111_1111;
                end
            endcase 
            end 
            else if(hd4&&flag)
            begin
            case(scan_cnt)
                4'd0: begin DIG = 8'b01111111; Y=seg[13]; end
                4'd1: begin DIG = 8'b10111111; Y=8'b10100011; end
                4'd2: begin DIG = 8'b11011111; Y=8'b10101011; end
                4'd3: begin DIG = 8'b11101111; Y=seg[14]; end
                4'd4: begin DIG = 8'b11111111; end
                4'd5: begin DIG = 8'b11111011; Y=seg[13]; end
                4'd6: begin DIG = 8'b11111101; Y=seg[tenss[12]]; end
                4'd7: begin DIG = 8'b11111110; Y=seg[oness[12]]; end
                                default:
                begin
                DIG=8'b1111_1111;
                Y=8'b1111_1111;
                end
            endcase 
            end
            else if(hd4&&(!flag))
            begin
            case(scan_cnt)
                4'd0: begin DIG = 8'b01111111; Y=seg[4]; end
                4'd1: begin DIG = 8'b11111111; end
                4'd2: begin DIG = 8'b11011111; Y=seg[11]; end
                4'd3: begin DIG = 8'b11101111; Y=seg[11]; end
                4'd4: begin DIG = 8'b11111111; end
                4'd5: begin DIG = 8'b11111011; Y=seg[13]; end
                4'd6: begin DIG = 8'b11111101; Y=seg[tenss[3]]; end
                4'd7: begin DIG = 8'b11111110; Y=seg[oness[3]]; end
                                default:
                begin
                DIG=8'b1111_1111;
                Y=8'b1111_1111;
                end
            endcase 
            end 
            else
            begin end
        //Total sales amount
        if(sw3)
        begin
            case(scan_cnt)
            4'd0: begin DIG = 8'b01111111;Y=8'b10001100;end
            4'd1: begin DIG = 8'b10111111;Y=8'b11110111;end
            4'd2: begin DIG = 8'b11011111;Y=8'b10010010;end
            4'd3: begin DIG = 8'b11101111;Y=8'b11000001;end
            4'd4: begin DIG = 8'b11111111;end
            4'd5: begin DIG = 8'b11111011;Y=seg[hundreds];end
            4'd6: begin DIG = 8'b11111101; Y=seg[tenss[8]]; end
            4'd7: begin DIG = 8'b11111110; Y=seg[oness[8]]; end
                            default:
            begin
            DIG=8'b1111_1111;
            Y=8'b1111_1111;
            end
        endcase         
        end  
        
        end
      
    
endmodule
