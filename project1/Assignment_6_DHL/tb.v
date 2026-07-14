
module tb;
  reg  clk, in, rstn;
  wire out;

  always #10 clk = ~clk;

  FSM u0 ( 
                                                                    .clk(clk), 
                                                                    .rstn(rstn), 
                                                                    .in(in), 
																						  .out(out) 
 );
 
  initial begin
    clk  = 0;
    rstn = 0;
    in   = 0;

    #40;
    rstn = 1;
    #15;

    in = 1; #20;
    in = 0; #20;
    in = 0; #20;
    in = 1; #20;

    in = 0; #20;
    in = 0; #20;
    in = 1; #20;

    in = 0;

    #100;
    $finish;
  end

  initial begin
    $monitor("Time=%0t | rstn=%b | in=%b | out=%b", $time, rstn, in, out);
  end

endmodule