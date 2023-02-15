`timescale 1 ns/10 ps  // time-unit = 1 ns, precision = 10 ps

module tb;

  reg clock, reset, carga, conta;
  reg [6:0] chaves;

  localparam PERIOD_100MHZ = 10;  

  initial
  begin
    clock = 1'b1;
    forever #(PERIOD_100MHZ/2) clock = ~clock;
  end

  initial
  begin
    reset = 1'b1;
    carga = 1'b0;
    conta = 1'b0;
    chaves = 7'd5;
    #73;
    reset = 1'b0;
    #60;
    carga = 1'b1;
    #292;
    carga = 1'b0;
    #118;
    conta = 1'b1;
    #382;
    conta = 1'b0;
  end
  
  cronometro #(.CLOCK_FREQ(4)) DUT (.clock(clock), .reset(reset), .carga(carga), .conta(conta), .chaves(chaves), .an(an), .dec_ddp(dec_ddp));

endmodule