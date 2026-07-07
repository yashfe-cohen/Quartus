module Assignment1DHL (
    input wire in_bit,   // אות הכניסה
    output wire out_bit  // אות המוצא (ההיפוך הלוגי)
);

    // ביצוע ההיפוך הלוגי באמצעות האופרטור ~
    assign out_bit = ~in_bit;

endmodule