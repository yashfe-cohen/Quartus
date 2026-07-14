`timescale 1ns / 1ps

module tb_arp_rx();

    reg clk, rst;
    reg [1:0] din;
    wire done,
	 wire err;

    //  uut
    arp_rx_block uut (
	 
                                                                     .clk(clk), 
		                                                               .rst(rst), 
		                                                               .data_in(din),
                                                                     .done_flag(done),
		                                                               .arp_err(err)
    );
	 

    // clock
    always #5 clk = ~clk;

    reg [335:0] pkt; // the packet
    integer i;

    initial begin
        // n0906 is wrong should be 0806 to pass its for me to see flag err
        pkt = 336'hFFFFFFFFFFFF_001122334455_0906_0001_0800_06_04_0001_001122334455_C0A80101_000000000000_C0A80102; // An example of an ARP from Google. good is with 0806

        clk = 0; rst = 1; din = 0;
        #20 rst = 0; #15;

        // send preamble + sfd
        repeat(31) @(negedge clk) din = 2'b10; // I used `negedge` because it helps with a synchronization issue I had before starting to capture data.
        @(negedge clk) din = 2'b11; 

        // push packet bits
        for (i = 0; i < 168; i = i + 1) begin
            @(negedge clk);
            din = pkt[335:334];    
            pkt = pkt << 2; 
        end

        @(posedge clk) din = 0; // stop
        #50 $stop;
    end

endmodule