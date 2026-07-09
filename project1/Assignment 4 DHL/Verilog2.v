module HALFADDER(

 input wire inputHA1,
 input wire inputHA2,
 output wire outputsum,
 output wire carry
);
    assign outputsum  = inputHA1 ^ inputHA2;  // מימוש של קסור
    assign carry = inputHA1  & inputHA2  ; // מימוש של אנד    
	 
endmodule