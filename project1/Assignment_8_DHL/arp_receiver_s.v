module arp_receiver  (
    input clk,
    input rst,             
    input [1:0] data_in,
    input [47:0] my_mac_addr,
    output reg done_flag,  
    output reg arp_err     
);

    // states for fsm 
    localparam ST_IDLE     = 4'd0;
    localparam ST_SKIP     = 4'd1;
    localparam ST_MAC_DST  = 4'd2;
    localparam ST_MAC_SRC  = 4'd3;
    localparam ST_ETH_TYP  = 4'd4;
    localparam ST_HW_TYP   = 4'd5;
    localparam ST_PROT_TYP = 4'd6;
    localparam ST_H_SIZE   = 4'd7;
    localparam ST_P_SIZE   = 4'd8;
    localparam ST_OP_CODE  = 4'd9;
    localparam ST_SND_MAC  = 4'd10;
    localparam ST_SND_IP   = 4'd11;
    localparam ST_TAR_MAC  = 4'd12;
    localparam ST_TAR_IP   = 4'd13;
    localparam ST_DONE     = 4'd14;
    
    localparam my_ip_addr = 32'h0A64660C; // 10.100.102.12    
    
    reg [3:0] curr_state = ST_IDLE;
    
    // clock counter
    reg [7:0] clk_cnt = 8'd0; 

    // registers to hold the packet parts
    reg [47:0] mac_dst  = 48'd0; // where it goes
    reg [47:0] mac_src  = 48'd0; // where it came from
    reg [15:0] eth_typ  = 16'd0; // need to check this for arp
    reg [15:0] hw_typ   = 16'd0; // usually ethernet
    reg [15:0] prot_typ = 16'd0; // mostly ip
    reg [7:0]  h_size   = 8'd0;  // mac size
    reg [7:0]  p_size   = 8'd0;  // ip size
    reg [15:0] op_code  = 16'd0; // req or rep
    reg [47:0] snd_mac  = 48'd0; // sender mac inside arp
    reg [31:0] snd_ip   = 32'd0; // sender ip
    reg [47:0] tar_mac  = 48'd0; // target mac we want
    reg [31:0] tar_ip   = 32'd0; // target ip
    
    // main logic
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            curr_state <= ST_IDLE;
            clk_cnt <= 1'b0;
            done_flag <= 1'b0;
            arp_err <= 1'b0; 
        end else begin
            case (curr_state)
                ST_IDLE: begin
                    done_flag <= 1'b0;
                    arp_err <= 1'b0;
                    clk_cnt <= 1'b0;
                    
                    if(data_in == 2'b10) begin 
                        curr_state <= ST_SKIP; //next state
                        clk_cnt <= 1'b1; 
                    end
                end

                ST_SKIP: begin
                    if (clk_cnt == 31) begin  
                        curr_state <= ST_MAC_DST; // go to next state
                        clk_cnt <= 1'b0; 
                    end else begin
                        clk_cnt <= clk_cnt + 1'b1;
                    end
                end

                ST_MAC_DST: begin
                    mac_dst <= {mac_dst[45:0], data_in};
                    if (clk_cnt == 23) begin
                        // my mac or brodcast ?
                        if ({mac_dst[45:0], data_in} != 48'hFFFFFFFFFFFF && {mac_dst[45:0], data_in} != my_mac_addr) begin
                            // silent drop 
                            curr_state <= ST_IDLE; 
                            clk_cnt <= 1'b0;
                        end else begin
                            curr_state <= ST_MAC_SRC; // next state
                            clk_cnt <= 1'b0;
                        end
                    end else begin
                        clk_cnt <= clk_cnt + 1'b1;
                    end
                end

                ST_MAC_SRC: begin
                    mac_src <= {mac_src[45:0], data_in};
                    if (clk_cnt == 23) begin
                        curr_state <= ST_ETH_TYP; // next state
                        clk_cnt <= 1'b0;
                    end else begin
                        clk_cnt <= clk_cnt + 1'b1;
                    end
                end

                ST_ETH_TYP: begin
                    eth_typ <= {eth_typ[13:0], data_in};
                    if (clk_cnt == 7) begin
                        // its arp protocol?
                        if ({eth_typ[13:0], data_in} != 16'h0806) begin // check for arp protocol
                            arp_err <= 1'b1;   // dump it, not arp
                            curr_state <= ST_IDLE; 
                            clk_cnt <= 1'b0;
                        end else begin
                            curr_state <= ST_HW_TYP; // next state
                            clk_cnt <= 1'b0;
                        end
                    end else begin
                        clk_cnt <= clk_cnt + 1'b1;
                    end
                end

                ST_HW_TYP: begin
                    hw_typ <= {hw_typ[13:0], data_in};
                    if (clk_cnt == 7) begin
                        // its Ethernet protocol?
                        if ({hw_typ[13:0], data_in} != 16'h0001) begin // check for Hardware Type Ethernet
                            arp_err <= 1'b1;   // dump it, not Ethernet
                            curr_state <= ST_IDLE; 
                            clk_cnt <= 1'b0;
                        end else begin
                            curr_state <= ST_PROT_TYP; // next state
                            clk_cnt <= 1'b0;
                        end
                    end else begin
                        clk_cnt <= clk_cnt + 1'b1;
                    end
                end

                ST_PROT_TYP: begin
                    prot_typ <= {prot_typ[13:0], data_in};
                    if (clk_cnt == 7) begin
                        //its IPv4 protocol?
                        if ({prot_typ[13:0], data_in} != 16'h0800) begin // check for IPv4
                            arp_err <= 1'b1;   // dump it, not IPv4
                            curr_state <= ST_IDLE; 
                            clk_cnt <= 1'b0;
                        end else begin
                            curr_state <= ST_H_SIZE; // next state
                            clk_cnt <= 1'b0;
                        end
                    end else begin
                        clk_cnt <= clk_cnt + 1'b1;
                    end
                end

                ST_H_SIZE: begin
                    h_size <= {h_size[5:0], data_in};
                    if (clk_cnt == 3) begin
                        curr_state <= ST_P_SIZE; // next state
                        clk_cnt <= 1'b0;
                    end else begin
                        clk_cnt <= clk_cnt + 1'b1;
                    end
                end

                ST_P_SIZE: begin
                    p_size <= {p_size[5:0], data_in};
                    if (clk_cnt == 3) begin
                        curr_state <= ST_OP_CODE; // next state
                        clk_cnt <= 1'b0;
                    end else begin
                        clk_cnt <= clk_cnt + 1'b1;
                    end
                end

                ST_OP_CODE: begin
                    op_code <= {op_code[13:0], data_in};
                    if (clk_cnt == 7) begin
                        curr_state <= ST_SND_MAC; // next state
                        clk_cnt <= 1'b0;
                    end else begin
                        clk_cnt <= clk_cnt + 1'b1;
                    end
                end

                ST_SND_MAC: begin
                    snd_mac <= {snd_mac[45:0], data_in};
                    if (clk_cnt == 23) begin
                        // check for arp spoofing
                        if ({snd_mac[45:0], data_in} != mac_src) begin 
                            arp_err <= 1'b1;   // dump it, arp spoofing
                            curr_state <= ST_IDLE; 
                            clk_cnt <= 1'b0;
                        end else begin
                            curr_state <= ST_SND_IP; // next state
                            clk_cnt <= 1'b0;
                        end
                    end else begin
                        clk_cnt <= clk_cnt + 1'b1;
                    end
                end

                ST_SND_IP: begin
                    snd_ip <= {snd_ip[29:0], data_in};
                    if (clk_cnt == 15) begin
                        curr_state <= ST_TAR_MAC; // next state
                        clk_cnt <= 1'b0;
                    end else begin
                        clk_cnt <= clk_cnt + 1'b1;
                    end
                end

                ST_TAR_MAC: begin
                    tar_mac <= {tar_mac[45:0], data_in};
                    if (clk_cnt == 23) begin
                        curr_state <= ST_TAR_IP; // next state
                        clk_cnt <= 1'b0;
                    end else begin
                        clk_cnt <= clk_cnt + 1'b1;
                    end
                end

                ST_TAR_IP: begin
                    tar_ip <= {tar_ip[29:0], data_in};
                    if (clk_cnt == 15) begin
                        // check if my ip == tar_ip
                        if ({tar_ip[29:0], data_in} == my_ip_addr) begin
                            curr_state <= ST_DONE; 
                        end else begin
                            curr_state <= ST_IDLE;
                            clk_cnt <= 1'b0;
                        end
                    end else begin
                        clk_cnt <= clk_cnt + 1'b1;
                    end
                end

                ST_DONE: begin
                    done_flag <= 1'b1; 
                    curr_state <= ST_IDLE; 
                    clk_cnt <= 1'b0;
                end
                
                default: curr_state <= ST_IDLE;
            endcase
        end
    end

endmodule
