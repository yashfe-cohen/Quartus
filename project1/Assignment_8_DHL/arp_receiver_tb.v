`timescale 1ns / 1ps

module tb_arp_rx();

    reg clk, rst;
    reg [1:0] din = 2'b0;
    wire done;
    wire err;
    
    reg [47:0] my_mac = 48'h001122334455; 

    arp_receiver_s uut (
        .clk(clk), 
        .rst(rst), 
        .data_in(din),
        .my_mac_addr(my_mac),
        .done_flag(done),
        .arp_err(err)
    );

    // clock
    always #5 clk = ~clk;

    reg [335:0] pkt; // the packet
    integer i;

    initial begin
        pkt = 336'hFFFFFFFFFFFF_001122334455_0806_0001_0800_06_04_0001_001122334455_C0A80101_000000000000_0A64660C; 

        clk = 0; rst = 1; din = 0;
        #20 rst = 0; #15;

        // send preamble + sfd
        repeat(31) @(posedge clk) din = 2'b10; 
        @(posedge clk) din = 2'b11; 

        // push packet bits
        for (i = 0; i < 168; i = i + 1) begin
            @(posedge clk);
            din = pkt[335:334];    
            pkt = pkt << 2; 
        end

        @(posedge clk) din = 0; // stop
        
        #100;
		  
		  
		  pkt = 336'hFFFFFFFFFFFF_001122334455_0906_0001_0800_06_04_0001_001122334455_C0A80101_000000000000_0A64660C; 

        clk = 0; rst = 1; din = 0;
        #20 rst = 0; #15;

        // send preamble + sfd
        repeat(31) @(posedge clk) din = 2'b10; 
        @(posedge clk) din = 2'b11; 

        // push packet bits
        for (i = 0; i < 168; i = i + 1) begin
            @(posedge clk);
            din = pkt[335:334];    
            pkt = pkt << 2; 
        end

        @(posedge clk) din = 0; // stop
        
        #100 $stop;
		  
		  
    end

endmodule