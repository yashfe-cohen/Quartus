module FULLADDER (
  input wire inputA1,
  input wire inputA2,
  input wire carryin,
  output wire finalsum,
  output wire carryT
);

  wire sum1_haA1; // מהיציאה של המסכם הראשון לכניסה של לכניסה של החצי הדר השני
  wire carry1_or;// מהיציאה של הכארי הראשון לכניסה של האור
  wire orout_carryT;// חוט לחיבור של כארי 2 לכניסה השניה של אור

  HALFADDER ha1(
    .inputHA1(inputA1),  //חיבור של ה אינפוט של המאין לחצי הראשון
    .inputHA2(inputA2),  //חיבור של האינפוט השני ל חצי של הראשון 
    .outputsum(sum1_haA1), //חיבור של היציאה של סאם1 לקצה של חוט שיחבר אותו לכניסה של החצי הדר השני 
    .carry(carry1_or) //חיבור של כארי 1 לכניסה הראשונה של שער אור 
  );
   
  HALFADDER ha2(
    .inputHA1(sum1_haA1),  //החיבור של כניסה אחת בחצי הדר השני לחוט של סאם אחד 
    .inputHA2(carryin),  //הכנסה של כאריאין לאינםוט של החצי הדר השני
    .outputsum(finalsum), //חיבור של היציאה של החצי הדר השני ל סאן הסופי 
    .carry(orout_carryT) //חיבור של כארי 2 ליציאה השניה של שער אור 
  );

  assign carryT = carry1_or | orout_carryT; // מימוש של שער אור כדאי להביא כארי סופי 

endmodule

