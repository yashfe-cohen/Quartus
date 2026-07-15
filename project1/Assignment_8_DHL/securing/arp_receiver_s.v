module arp_receiver  (
    input clk,
    input rst,             
    input [1:0] data_in,
    input [47:0] my_mac_addr,
    output reg done_flag,  
    output reg arp_err     
);

    // states for fsm
    localparam ST_IDLE = 2'b00;
    localparam ST_SKIP = 2'b01;
    localparam ST_READ = 2'b10;
    localparam ST_DONE = 2'b11;
    
    localparam my_ip_addr = 32'h0A64660C; // 10.100.102.12	 
	 
	
    reg [1:0] curr_state;
    reg [7:0] clk_cnt; 

    // registers to hold the packet parts
    reg [47:0] mac_dst; 
    reg [47:0] mac_src;   
    reg [15:0] eth_typ; 
    reg [15:0] hw_typ;  
    reg [15:0] prot_typ; 
    reg [7:0]  h_size;   
    reg [7:0]  p_size; 
    reg [15:0] op_code;  
    reg [47:0] snd_mac; 
    reg [31:0] snd_ip;    
    reg [47:0] tar_mac; 
    reg [31:0] tar_ip; 

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
                    
                    if(data_in == 2'b10) begin 
                        curr_state <= ST_SKIP;
                        clk_cnt <= 1; 
                    end
                end

                ST_SKIP: begin
                    if (clk_cnt == 31) begin  
                        curr_state <= ST_READ;
                        clk_cnt <= 0; 
                    end else begin
                        clk_cnt <= clk_cnt + 1;
                    end
                end

                ST_READ: begin
                    clk_cnt <= clk_cnt + 1;
						  
                    //  data_inpush 2 bits into the reg from right
                    if(clk_cnt < 24) begin
                        mac_dst <= {mac_dst[45:0], data_in};
                        
								
                        // check for mac_dst
                        if (clk_cnt == 23) begin
                            
									 // my mac or brodcast ?
									 if ({mac_dst[45:0], data_in} != 48'hFFFFFFFFFFFF && {mac_dst[45:0], data_in} != my_mac_addr) begin
                                // silent drop 
                                curr_state <= ST_IDLE; 
                                clk_cnt <= 0;
                            end
									 
									 
                        end
                    end 
                    else if (clk_cnt < 48) begin
                        mac_src <= {mac_src[45:0], data_in};
                    end 
                    else if (clk_cnt < 56) begin
                        eth_typ <= {eth_typ[13:0], data_in};
                        
                        if (clk_cnt == 55) begin
								
								
								    // its arp protocol?
                            if ({eth_typ[13:0], data_in} != 16'h0806) begin // check for arp protocol
                                arp_err <= 1;   // dump it, not arp
                                curr_state <= ST_IDLE; 
                                clk_cnt <= 0;
                            end
									 
									 
                        end
                    end 
                    else if(clk_cnt < 64) begin
                        hw_typ <= {hw_typ[13:0], data_in};
                        
                        if (clk_cnt == 63) begin
								
								
								    // its Ethernet protocol?
                            if ({hw_typ[13:0], data_in} != 16'h0001) begin // check for Hardware Type Ethernet
                                arp_err <= 1;   // dump it, not Ethernet
                                curr_state <= ST_IDLE; 
                                clk_cnt <= 0;
                            end
									 
									 
                        end
                    end 
                    else if (clk_cnt < 72) begin
                        prot_typ <= {prot_typ[13:0], data_in};
                        
								
								//its IPv4 protocol?
                        if (clk_cnt == 71) begin
                            if ({prot_typ[13:0], data_in} != 16'h0800) begin // check for IPv4
                                arp_err <= 1;   // dump it, not IPv4
                                curr_state <= ST_IDLE; 
                                clk_cnt <= 0;
                            end
                        end
								
								
                    end 
                    else if (clk_cnt < 76) begin
                        h_size <= {h_size[5:0], data_in};
                    end 
                    else if(clk_cnt < 80) begin
                        p_size <= {p_size[5:0], data_in};
                    end 
                    else if (clk_cnt < 88) begin
                        op_code <= {op_code[13:0], data_in};
                    end 
                    else if (clk_cnt < 112) begin
                        snd_mac <= {snd_mac[45:0], data_in};
								
								
						
								// arp spoofing 
							if (clk_cnt == 111 ) begin
                            if ({snd_mac[45:0], data_in} != mac_src) begin // check for IPv4
                                arp_err <= 1;   // dump it, not IPv4
                                curr_state <= ST_IDLE; 
                                clk_cnt <= 0;
                            end
                        end
                 	
							
								
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

						  
						  
                    // check if we finished reading everything and if my ip == tar_ip
                    if(clk_cnt == 167) begin 
                        if ({tar_ip[29:0], data_in} == my_ip_addr) begin // if im the tar_ip
                            curr_state <= ST_DONE; 
                        end else begin
                            curr_state <= ST_IDLE;
                            clk_cnt <= 0;
                        end
                    end
                end
					 
					 
					 
 
                ST_DONE: begin
                    done_flag <= 1; 
                    curr_state <= ST_IDLE; 
                    clk_cnt <= 0;
                end
                
                default: curr_state <= ST_IDLE;
            endcase
        end
    end

endmodule