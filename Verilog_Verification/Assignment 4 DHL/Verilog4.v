`timescale 1ns / 1ps

module tb_fullAdd;

    // הגדרת משתנים לכניסות
    reg Data_in_A;
    reg Data_in_B;
    reg Data_in_C;

    // הגדרת חוטים ליציאות
    wire Data_out_Sum;
    wire Data_out_Carry;

    // יחידה תחת בדיקה (UUT) - חיבור מדויק לשמות במודול FULLADDER
    FULLADDER uut (
        .inputA1(Data_in_A),      // חיבור לכניסה ראשונה
        .inputA2(Data_in_B),      // חיבור לכניסה שניה
        .carryin(Data_in_C),      // חיבור לכניסת carry
        .finalsum(Data_out_Sum),  // חיבור ליציאת הסכום
        .carryT(Data_out_Carry)   // חיבור ליציאת carry
    );

    initial begin
        // בדיקת כל המצבים האפשריים (Truth Table)
        Data_in_A = 0;  Data_in_B = 0;  Data_in_C = 0;  #10;
        Data_in_A = 0;  Data_in_B = 0;  Data_in_C = 1;  #10;
        Data_in_A = 0;  Data_in_B = 1;  Data_in_C = 0;  #10;
        Data_in_A = 0;  Data_in_B = 1;  Data_in_C = 1;  #10;
        Data_in_A = 1;  Data_in_B = 0;  Data_in_C = 0;  #10;
        Data_in_A = 1;  Data_in_B = 0;  Data_in_C = 1;  #10;
        Data_in_A = 1;  Data_in_B = 1;  Data_in_C = 0;  #10;
        Data_in_A = 1;  Data_in_B = 1;  Data_in_C = 1;  #10;
        
        $stop; // פקודה לעצירת הסימולציה בסיום
    end

endmodule