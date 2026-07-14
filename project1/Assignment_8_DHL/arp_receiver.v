module arp_receiver  (
    input clk,
    input rst,             
    input [1:0] data_in,   
    output reg done_flag,  
    output reg arp_err     
);

    // states for fsm
    localparam ST_IDLE = 2'b00;
    localparam ST_SKIP = 2'b01;
    localparam ST_READ = 2'b10;
    localparam ST_DONE = 2'b11;

    reg [1:0] curr_state;
    
    // clock counter
    reg [7:0] clk_cnt; 

    // registers to hold the packet parts
    reg [47:0] mac_dst; // where it goes
    reg [47:0] mac_src;   // where it came from
    reg [15:0] eth_typ; // need to check this for arp
    reg[15:0] hw_typ;  // usually ethernet
    reg [15:0] prot_typ; // mostly ip
    reg [7:0] h_size;   // mac size
    reg[7:0] p_size; // ip size
    reg [15:0] op_code;  // req or rep
    reg [47:0] snd_mac; // sender mac inside arp
    reg [31:0] snd_ip;    // sender ip
    reg [47:0] tar_mac; // target mac we want
    reg[31:0] tar_ip; // target ip

    // main logic
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            curr_state <= ST_IDLE;
            clk_cnt <= 0;
            done_flag <= 0;
            arp_err <= 0; 
        end else begin
            case (curr_state)
                ST_IDLE: begin
                    done_flag <= 0;
                    arp_err <= 0;
                    clk_cnt <= 0;
                    
                    // waiting for the 10 sequence
                    if(data_in == 2'b10) begin 
                        curr_state <= ST_SKIP;
                        clk_cnt <= 1; // first "10" is done now go to ST_SKIP count = 1;
                    end
                end

                ST_SKIP: begin
                    // ignore preamble and sfd 32 clocks
                    if (clk_cnt == 31) begin  // 31 becuse clk start from 1
                        curr_state <= ST_READ;
                        clk_cnt <= 0; 
                    end else begin
                        clk_cnt <= clk_cnt + 1;
                    end
                end

                ST_READ: begin
                    clk_cnt <= clk_cnt + 1;

                    // push 2 bits into the reg from right
                    if(clk_cnt < 24) begin
                        mac_dst <= {mac_dst[45:0], data_in};
                    end 
                    else if (clk_cnt < 48) begin
                        mac_src <= {mac_src[45:0],data_in};
                    end 
                    else if (clk_cnt < 56) begin
                        eth_typ <= {eth_typ[13:0], data_in};
                    end 
                    else if(clk_cnt < 64) begin
                        hw_typ <= {hw_typ[13:0], data_in};
                    end 
                    else if (clk_cnt < 72) begin
                        prot_typ <= {prot_typ[13:0], data_in};
                    end 
                    else if (clk_cnt<76) begin
                        h_size <= {h_size[5:0], data_in};
                    end 
                    else if(clk_cnt < 80) begin
                        p_size <= {p_size[5:0], data_in};
                    end 
                    else if (clk_cnt < 88) begin
                        op_code <= {op_code[13:0], data_in};
                    end 
                    else if (clk_cnt < 112) begin
                        snd_mac <= {snd_mac[45:0],data_in};
                    end 
                    else if(clk_cnt < 128) begin
                        snd_ip <= {snd_ip[29:0], data_in};
                    end 
                    else if (clk_cnt < 152) begin
                        tar_mac <= {tar_mac[45:0], data_in};
                    end 
                    else if(clk_cnt < 168) begin
                        tar_ip <= {tar_ip[29:0], data_in};
                    end

                    // check if we finished reading everything
                    if(clk_cnt == 167) begin 
                        if (eth_typ == 16'h0806) begin 
                            curr_state <= ST_DONE; // all good
                        end else begin
                            arp_err <= 1;   // dump it, not arp
                            curr_state <= ST_IDLE; 
                            clk_cnt <= 0;
                        end
                    end
                end

                ST_DONE: begin
                    done_flag <= 1; // ready
                    curr_state <= ST_IDLE; 
                    clk_cnt <= 0;
                end
                
                default: curr_state <= ST_IDLE;
            endcase
        end
    end

endmodule