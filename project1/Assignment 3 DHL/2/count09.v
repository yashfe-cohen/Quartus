module top_cnt #(parameter FREQ = 50000000) 
(
    input clk,
    input rst,
    output [3:0] out_val
); 

    wire sec_en; // חוט שמחבר בין הפולס של השניה לבין הקאונטר של השניות

    clk_div #(.MAX(FREQ)) u_div // קומפוננטה ליצירה של שניה 
    (
        .clk(clk),
        .rst(rst),
        .p_sec(sec_en) // מחבר קצה אחד של חוט השניות 
    );

    cnt_9 u_cnt // קומפוננטה ליצירה של קאונטר עד 9     
    (
        .clk(clk),
        .rst(rst),
        .en(sec_en), // מחבר צד שני של החוט לקאונטר, בעצם עכשיו חיברתי את שני הצדדים 
        .val(out_val) // זה מה שבעצם שולח לנו את הערך המשתנה של הקאונטר ליציאה 
    );

endmodule