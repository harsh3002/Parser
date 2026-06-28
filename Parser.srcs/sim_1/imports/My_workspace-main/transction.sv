`ifndef ETH_PARSE_TRANSACTION
`define ETH_PARSE_TRANSACTION

package transaction_pkg;

    class transaction;
        
        //Packet global parameters
        rand    bit     [14:0]  packet_len;
                bit             jumbo_frame_valid;
                bit             min_frame_valid;
        
        //MAC address parameters
        rand    bit     [47:0]  dst_mac_addr;
        rand    bit     [47:0]  src_mac_addr;
                bit             unicast_addr_valid;
                bit             multicast_addr_valid;
                bit             broadcast_addr_valid;
                
        //IP Layer protocol parameters
        rand    bit     [15:0]  ether_type;
                bit             ipv4_valid;
                bit             ipv6_valid;
                bit             arp_valid;
                
        //VLAN parameters
        rand    bit     [15:0]  vlan_type;
        rand    bit     [15:0]  inner_vlan_id;
        rand    bit     [15:0]  outer_vlan_id;
                bit             vlan_valid;
                bit             qinq_valid;
        rand    bit     [15:0]  qinq_type;
                bit     [15:0]  vlan_id;
        
        //Actual packet data
        rand    bit     [63:0]  packet_data_queue [$];
                
        // Constraints for randomization
        constraint  c_packet_len {if(jumbo_frame_valid == 1)
                                    {
                                        packet_len inside {[1500:9000]};
                                        packet_data_queue.size() == packet_len;
                                    }
                                  else if(min_frame_valid == 1)
                                    {
                                        packet_len == 64;
                                        packet_data_queue.size() == packet_len;
                                    }
                                  else 
                                    {
                                        packet_len inside {[0:9000]};
                                        packet_data_queue.size() == packet_len;
                                    }
                                  };
                                  
        constraint  c_dest_addr {if(broadcast_addr_valid == 1)
                                    {
                                        dst_mac_addr == 48'hff_ff_ff_ff_ff_ff;
                                    }
                                  else if(multicast_addr_valid == 1)
                                    {
                                        dst_mac_addr[40] == 1'b1;
                                    }
                                  else if(unicast_addr_valid == 1)
                                    {
                                        dst_mac_addr inside {[0 : (2**48)-1]};
                                    }
                                  };
                                  
        constraint  c_ether_type {if(ipv4_valid == 1)
                                    {
                                        ether_type == 16'h0800;
                                    }
                                  else if(ipv6_valid == 1)
                                    {
                                        ether_type == 16'h86DD;
                                    }
                                  else if(arp_valid == 1)
                                    {
                                        ether_type == 16'h0806;
                                    }
                                  };
                                  
        constraint  c_vlan_type {if(vlan_valid == 1)
                                    {
                                        vlan_type               == 16'h8100;
                                        inner_vlan_id[15:13]    == 1 ;
                                        inner_vlan_id[12]       == 0 ;
                                        inner_vlan_id[11:0] inside {[0:12'hfff]} ;
                                    }
                                  else if(qinq_valid == 1)
                                    {
                                        qinq_type               == 16'h88A8;
                                        outer_vlan_id[15:13]    == 1 ;
                                        outer_vlan_id[12]       == 0 ;
                                        outer_vlan_id[11:0] inside {[0:12'hfff]} ;
                                        vlan_type               == 16'h0800;
                                        inner_vlan_id[15:13]    == 1 ;
                                        inner_vlan_id[12]       == 0 ;
                                        inner_vlan_id[11:0] inside {[0:12'hfff]} ;
                                    }
                                  };

        
        //Function for post-randomize for the packet data alignment
        function void post_randomize();
            
            packet_data_queue[0]        = {dst_mac_addr, src_mac_addr[47:32]};
            packet_data_queue[1][63:32] = {src_mac_addr[31:0]};
            
            case({qinq_valid, vlan_valid})
            
                2'b10 : begin
                    
                   packet_data_queue[1][31:0] = {qinq_type,outer_vlan_id}; 
                   packet_data_queue[2][63:16]= {vlan_type,inner_vlan_id,ether_type}; 
                    
                end
                
                2'b01 : begin
                    
                   packet_data_queue[1][31:0] = {vlan_type,inner_vlan_id}; 
                   packet_data_queue[2][63:48]= {ether_type}; 
                    
                end
                
                2'b00 : begin
                    
                   packet_data_queue[1][31:16] = {ether_type}; 
                    
                end
                
                2'b11 : begin
                    
                   packet_data_queue[1][31:0] = {qinq_type,outer_vlan_id}; 
                   packet_data_queue[2][63:16]= {vlan_type,inner_vlan_id,ether_type}; 
                    
                end
            
            endcase
            
        endfunction
                
                
        // Function for deep_copy
        function transaction copy;
        
            copy                        = new;
            copy.packet_len             = this.packet_len;
            copy.jumbo_frame_valid      = this.jumbo_frame_valid;
            copy.min_frame_valid        = this.min_frame_valid;
            copy.dst_mac_addr           = this.dst_mac_addr;
            copy.src_mac_addr           = this.src_mac_addr;
            copy.unicast_addr_valid     = this.unicast_addr_valid;
            copy.multicast_addr_valid   = this.multicast_addr_valid;
            copy.broadcast_addr_valid   = this.broadcast_addr_valid;
            copy.ether_type             = this.ether_type;
            copy.ipv4_valid             = this.ipv4_valid;
            copy.ipv6_valid             = this.ipv6_valid;
            copy.arp_valid              = this.arp_valid;
            copy.vlan_type              = this.vlan_type;
            copy.inner_vlan_id          = this.inner_vlan_id;
            copy.outer_vlan_id          = this.outer_vlan_id;
            copy.vlan_valid             = this.vlan_valid;
            copy.qinq_valid             = this.qinq_valid;
            
        endfunction
    
    endclass

endpackage

`endif