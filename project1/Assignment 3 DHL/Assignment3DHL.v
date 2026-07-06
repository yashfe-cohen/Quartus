module Assignment3DHL #(
    // הגדרת פרמטר ברירת מחדל של 50 מיליון עבור הלוח הפיזי ב-Quartus
    parameter CLK_MAX = 50000000 
)(
    input  wire       clk,   // שעון המערכת
    input  wire       rst_n, // כפתור איפוס (אקטיבי ב-0)
    output reg [3:0]  count  // מונה המוצא (0 עד 9)
);

    // רגיסטר פנימי למדידת הזמן
    reg [25:0] one_second_counter;

    // בלוק אחוד שמטפל בזמן ובספרות במקביל
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            one_second_counter <= 0;
            count              <= 0;
        end else begin
            
            // בדיקה האם הגענו ליעד (50 מיליון בחומרה, או 5 בסימולציה)
            if (one_second_counter == CLK_MAX - 1) begin
                one_second_counter <= 0; // איפוס מד הזמן לשנייה הבאה
                
                // קידום המונה הראשי
                if (count == 9) begin
                    count <= 0; // הגענו ל-9, חוזרים לאפס
                end else begin
                    count <= count + 1; // קידום הספרה ב-1
                end
                
            end else begin
                // אם עדיין לא עברה שנייה, רק נקדם את מד הזמן הפנימי
                one_second_counter <= one_second_counter + 1;
            end
            
        end
    end

endmodule