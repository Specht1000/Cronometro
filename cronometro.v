module cronometro 
#(parameter CLOCK_FREQ = 50000000) // Parâmetro do divisor de clock
(
  input carga, conta, reset, clock,
  input [6:0] chaves,
  output [7:0] an, dec_ddp
);

  reg ck1seg;
  reg [31:0] contador;
  reg [7:0] minutos, segundos;
 
  wire [7:0] minutos_bcd, segundos_bcd;
  wire [5:0] d1,d2,d3,d4,d5,d6,d7,d8;

  reg [1:0] EA;
  reg [7:0] ROM [99:0];

  initial
  begin
    ROM[0]  = 8'b00000000;
    ROM[1]  = 8'b00000001;
    ROM[2]  = 8'b00000010;
    ROM[3]  = 8'b00000011;
    ROM[4]  = 8'b00000100;
    ROM[5]  = 8'b00000101;
    ROM[6]  = 8'b00000110;
    ROM[7]  = 8'b00000111;
    ROM[8]  = 8'b00001000;
    ROM[9]  = 8'b00001001;
    ROM[10] = 8'b00010000;
    ROM[11] = 8'b00010001;
    ROM[12] = 8'b00010010;
    ROM[13] = 8'b00010011;
    ROM[14] = 8'b00010100;
    ROM[15] = 8'b00010101;
    ROM[16] = 8'b00010110;
    ROM[17] = 8'b00010111;
    ROM[18] = 8'b00011000;
    ROM[19] = 8'b00011001;
    ROM[20] = 8'b00100000;
    ROM[21] = 8'b00100001;
    ROM[22] = 8'b00100010;
    ROM[23] = 8'b00100011;
    ROM[24] = 8'b00100100;
    ROM[25] = 8'b00100101;
    ROM[26] = 8'b00100110;
    ROM[27] = 8'b00100111;
    ROM[28] = 8'b00101000;
    ROM[29] = 8'b00101001;
    ROM[30] = 8'b00110000;
    ROM[31] = 8'b00110001;
    ROM[32] = 8'b00110010;
    ROM[33] = 8'b00110011;
    ROM[34] = 8'b00110100;
    ROM[35] = 8'b00110101;
    ROM[36] = 8'b00110110;
    ROM[37] = 8'b00110111;
    ROM[38] = 8'b00111000;
    ROM[39] = 8'b00111001;
    ROM[40] = 8'b01000000;
    ROM[41] = 8'b01000001;
    ROM[42] = 8'b01000010;
    ROM[43] = 8'b01000011;
    ROM[44] = 8'b01000100;
    ROM[45] = 8'b01000101;
    ROM[46] = 8'b01000110;
    ROM[47] = 8'b01000111;
    ROM[48] = 8'b01001000;
    ROM[49] = 8'b01001001;
    ROM[50] = 8'b01010000;
    ROM[51] = 8'b01010001;
    ROM[52] = 8'b01010010;
    ROM[53] = 8'b01010011;
    ROM[54] = 8'b01010100;
    ROM[55] = 8'b01010101;
    ROM[56] = 8'b01010110;
    ROM[57] = 8'b01010111;
    ROM[58] = 8'b01011000;
    ROM[59] = 8'b01011001;
    ROM[60] = 8'b01100000;
    ROM[61] = 8'b01100001;
    ROM[62] = 8'b01100010;
    ROM[63] = 8'b01100011;
    ROM[64] = 8'b01100100;
    ROM[65] = 8'b01100101;
    ROM[66] = 8'b01100110;
    ROM[67] = 8'b01100111;
    ROM[68] = 8'b01101000;
    ROM[69] = 8'b01101001;
    ROM[70] = 8'b01110000;
    ROM[71] = 8'b01110001;
    ROM[72] = 8'b01110010;
    ROM[73] = 8'b01110011;
    ROM[74] = 8'b01110100;
    ROM[75] = 8'b01110101;
    ROM[76] = 8'b01110110;
    ROM[77] = 8'b01110111;
    ROM[78] = 8'b01111000;
    ROM[79] = 8'b01111001;
    ROM[80] = 8'b10000000;
    ROM[81] = 8'b10000001;
    ROM[82] = 8'b10000010;
    ROM[83] = 8'b10000011;
    ROM[84] = 8'b10000100;
    ROM[85] = 8'b10000101;
    ROM[86] = 8'b10000110;
    ROM[87] = 8'b10000111;
    ROM[88] = 8'b10001000;
    ROM[89] = 8'b10001001;
    ROM[90] = 8'b10010000;
    ROM[91] = 8'b10010001;
    ROM[92] = 8'b10010010;
    ROM[93] = 8'b10010011;
    ROM[94] = 8'b10010100;
    ROM[95] = 8'b10010101;
    ROM[96] = 8'b10010110;
    ROM[97] = 8'b10010111;
    ROM[98] = 8'b10011000;
    ROM[99] = 8'b10011001;
  end

  // P1: divisor de clock para gerar o ck1seg
  always @(posedge clock or posedge reset)
    begin
       if (reset == 1) begin
         contador <= 32'd0;
         ck1seg <= 1'd0;
      end
      else begin
        if(contador==CLOCK_FREQ) begin
          contador <= 32'd0;
          ck1seg <= ~ck1seg;
        end
        else begin
           contador <=  contador + 1;
        end
      end
    end
  // P2: máquina de estados para determinar o estado atual (EA)
  always @(posedge clock or posedge reset)
  begin
    //--------------RESET--------------
    if (reset == 1) begin
      EA <= 2'd0;
    end
    //---------------------------------
    else begin
    case (EA) 
      //--------------CASO 0--------------
      2'd0 : begin
        if (carga == 1) begin
          EA <= 2'd1;
          end
        end
      //--------------CASO 1--------------
      2'd1 : begin
        if (conta == 1) begin
        EA <= 2'd2;
        end
      end
      //--------------CASO 2 / DEFAULT--------------
      default : begin
        if (minutos == 0 & segundos == 0)begin
          EA <= 2'd0;
        end
      end
    endcase
  end
  end

  // P3: contador de segundos
  always @(posedge ck1seg or posedge reset)
  begin
    //--------------RESET--------------
    if (reset == 1) begin
      segundos <= 8'd0;
    end
    //---------------------------------
    else begin
      if (EA == 2'd2) begin
        if (segundos == 0) begin
          if (minutos != 0 ) begin
             segundos <= 8'd59;
          end
        end
        else begin
          segundos <= segundos-1;
        end
      end
    end

  end
  // P4: contador de minutos
  always @(posedge ck1seg or posedge reset)
  begin
    //--------------RESET--------------
    if (reset == 1) begin
      minutos <= 8'd0;
    end
    else begin
          if (EA == 2'd1) begin
          minutos[0] <= chaves[0];
          minutos[1] <= chaves[1];
          minutos[2] <= chaves[2];
          minutos[3] <= chaves[3];
          minutos[4] <= chaves[4];
          minutos[5] <= chaves[5];
          minutos[6] <= chaves[6];
      end
      if (EA == 2'd2 && minutos != 0 && segundos == 0) begin
          minutos <= minutos-1;
      end
    end
  end
  // instanciação das ROMs
  assign segundos_bcd = ROM[segundos];
  assign minutos_bcd  = ROM[minutos];

  // display driver
  assign d1 = {1'b1, segundos_bcd[3:0], 1'b1};
  assign d2 = {1'b1, segundos_bcd[7:4], 1'b1};
  assign d3 = {1'b1, minutos_bcd [3:0], 1'b1};
  assign d4 = {1'b1, minutos_bcd [7:4], 1'b1};
  assign d5 = 6'd0;
  assign d6 = 6'd0;
  assign d7 = 6'd0;
  assign d8 = 6'd0;

  // instanciação da display 7seg
  dspl_drv_NexysA7 display_driver (.clock(clock), .reset(reset), .d1(d1), .d2(d2), .d3(d3), .d4(d4), .d5(d5), .d6(d6), .d7(d7), .d8(d8), .an(an), .dec_ddp(dec_ddp)); 
endmodule