`include "transction.sv"

`ifndef ETH_PARSE_GENERATOR
`define ETH_PARSE_GENERATOR

import transaction_pkg::* ;

//`define mailbox_gen mailbox#(transaction)


class generator;
    
    transaction tr;
    mailbox#(transaction) gen_driver_mb;
    mailbox#(transaction) gen_sco_mb;
    event       gen_done, sco_bd_done;
    bit  [1:0]  packet_len_type; 
    bit  [2:0]  dst_mac_addr_type;
    bit  [2:0]  ether_type;
    bit  [1:0]  vlan_type;
    int         gen_count;
    
    //initialize function for generator class
    function new(input mailbox#(transaction) gen_driver_mb, 
                 input mailbox#(transaction) gen_sco_mb,
                 input event sco_bd_done,
                 input bit  [1:0] packet_len_type, 
                 input bit  [2:0] dst_mac_addr_type, 
                 input bit  [2:0] ether_type, 
                 input bit  [1:0] vlan_type,
                 input int        gen_count,
                 input event     gen_done
                 );
                 
                 
        //Initialize 
        tr                      = new;
        this.gen_driver_mb      = gen_driver_mb;
        this.gen_sco_mb         = gen_sco_mb;
        this.sco_bd_done        = sco_bd_done;
        this.packet_len_type    = packet_len_type;
        this.dst_mac_addr_type  = dst_mac_addr_type;
        this.ether_type         = ether_type;
        this.vlan_type          = vlan_type;
        this.gen_count          = gen_count;
        this.gen_done           = gen_done;
        
    endfunction
    
    //Display function
    function void display();
        $display("=============================================================================================================================================================================================");
        $display("%0t[GEN] : GENERATED VALUES",$time);
        $display("%0t[GEN] : Packet_Type %h  \t Packet_lenth %d  \t Ether_Type %h  \t VLAN_Type %h", $time, packet_len_type, tr.packet_len, ether_type, vlan_type);
        $display("%0t[GEN] : Source_MAC_Addr %h  \t Dest_MAC_Addr_type %h", $time, tr.src_mac_addr, tr.dst_mac_addr);
        $display("%0t[GEN] : Ether_Type %h ", $time, tr.ether_type, tr.dst_mac_addr);
        $display("%0t[GEN] : VLAN_Type %h  \t TCI %h", $time, tr.vlan_type, tr.inner_vlan_id);
        $display("%0t[GEN] : QinQ_Type %h  \t TCI %h", $time, tr.qinq_type, tr.outer_vlan_id);
    endfunction
    
    //Main stimulus genration task
    task gen_stimulus;
        
        repeat(gen_count) begin
            
            //Assign all flags to transaction
            {tr.jumbo_frame_valid, tr.min_frame_valid}                                  = packet_len_type;
            {tr.unicast_addr_valid, tr.multicast_addr_valid, tr.broadcast_addr_valid}   = dst_mac_addr_type;
            {tr.ipv4_valid, tr.ipv6_valid, tr.arp_valid}                                = ether_type;
            {tr.vlan_valid, tr.qinq_valid}                                              = vlan_type;
            
            //Generate stimulus
            assert(tr.randomize);
            gen_driver_mb.put(tr.copy);
            gen_sco_mb.put(tr.copy);
            display();
            $display("%0t[GEN] : DATA SENT TO DRIVER",$time);
            @(sco_bd_done);
            #1;
        
        end
        
        -> gen_done;
        
    endtask

endclass


`endif