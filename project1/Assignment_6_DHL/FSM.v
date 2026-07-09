module FSM ( 
    input clk,
    input rstn,
    input  in,
    output out 
);

  parameter IDLE  = 2'd0,
            S1    = 2'd1,
            S10   = 2'd2,
            S100  = 2'd3,
            S1001 = 2'd4;

  reg [2:0] cur_state, next_state;

  assign out = (cur_state == S1001) ? 1 : 0; //if_else

  always @ (posedge clk) begin
    if (!rstn)
      cur_state <= IDLE;
    else
      cur_state <= next_state;
  end

  always @* begin
    case (cur_state)
      IDLE : begin
        if (in) next_state = S1;  //Next step
        else    next_state = IDLE; //Back to zero
      end

      S1: begin
        if (!in) next_state = S10; //Next step
        else     next_state = S1; // Because there is one waiting for zero.
      end

      S10: begin
        if (!in) next_state = S100; //Next step
        else     next_state = S1; // Because there is one waiting for zero.
      end

      S100 : begin
        if (in) next_state = S1001;//Next step
        else    next_state = IDLE;//Back to zero
      end

      S1001 : begin
        if (in) next_state = S1;  //Because there is 1001 waiting for zero.
        else    next_state = IDLE; //Back to zero
      end
       
      default: next_state = IDLE;//Back to zero
    endcase
  end
endmodule