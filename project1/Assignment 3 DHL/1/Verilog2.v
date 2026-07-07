`timescale 1ns / 1ps

module tb_counter_0_9();

    reg        clk;
    reg        rst_n;
    wire [3:0] count;

    // יצירת מופע ודריסת הפרמטר ל-5 עבור סימולציה מהירה וחלקה
    Assignment3DHL #( .CLK_MAX(5) ) uut (
        .clk(clk),
        .rst_n(rst_n),
        .count(count)
    );

    // יצירת אות שעון קבוע (מתהפך כל 10 ננו-שניות)
    always begin
        #10 clk = ~clk; 
    end

    // תהליך הזרקת האותות בסימולציה
    initial begin
        clk = 0;
        rst_n = 0; // הפעלת איפוס בהתחלה
        
        #20;       // המתנה של 20 ננו-שניות
        rst_n = 1; // שחרור האיפוס - המערכת מתחילה לרוץ
        
        #1000;     // הרצת הסימולציה למשך זמן מספק
        $finish;   // סיום הריצה
    end

endmodule