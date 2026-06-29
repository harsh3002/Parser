
`include "transction.sv"
`include "interface.sv"

`ifndef ETH_PARSE_MONITOR
`define ETH_PARSE_MONITOR

import transaction_pkg::* ;

//`define mailbox_mon mailbox#(transaction)
//`define virtual parser_ifc vifc


class monitor;
    
    transaction tr;
    mailbox#(transaction) mon_sco_mb;
    virtual parser_ifc        mon_ifc;
    
    //initialize function for generator class
    function new(input      mailbox#(transaction)   mon_sco_mb, 
                 virtual    parser_ifc              mon_ifc
                 );
                   
        //Initialize 
        tr                      = new;
        this.mon_sco_mb         = mon_sco_mb;
        this.mon_ifc            = mon_ifc; 
        
    endfunction
    
    //Reset  sampling function 
    task sample_reset();
        
        $display("%0t[MON] : SAMPLING RESET",$time);
        @(negedge mon_ifc.rst);
        $display("%0t[MON] : SAMPLING RESET DONE",$time);
        
    endtask
    
    //Data sampling function
    task sample_data();
        
//        $display("%0t[MON] : SAMPLING DATA",$time);
        tr.dst_mac_addr         = mon_ifc.dst_mac;
        tr.src_mac_addr         = mon_ifc.src_mac;
        tr.ether_type            = mon_ifc.ethertype;
        tr.vlan_valid           = mon_ifc.vlan_present;
        tr.vlan_id              = mon_ifc.vlan_id;
        tr.qinq_valid           = mon_ifc.qinq_present;
        tr.outer_vlan_id        = mon_ifc.outer_vlan_id;
        tr.inner_vlan_id        = mon_ifc.inner_vlan_id;
        tr.packet_len           = mon_ifc.packet_length;
        tr.jumbo_frame_valid    = mon_ifc.jumbo_frame;
        tr.unicast_addr_valid   = mon_ifc.is_unicast;
        tr.multicast_addr_valid = mon_ifc.is_multicast;
        tr.broadcast_addr_valid = mon_ifc.is_broadcast;
        tr.ipv4_valid           = mon_ifc.is_ipv4;
        tr.ipv6_valid           = mon_ifc.is_ipv6;
        tr.arp_valid            = mon_ifc.is_arp;
        tr.packet_data_queue.push_back(mon_ifc.s_axis_tdata);
        
        
        
//        $display("%0t[MON] : SAMPLING DATA BEAT DONE",$time);
        
    endtask
    
    //Main stimulus genration task
    task sample_values;
        
        forever begin
        
            @(mon_ifc.mon_cb);
            if(mon_ifc.rst) begin
                sample_reset;
                mon_sco_mb.put(tr);
            end
            else if(mon_ifc.s_axis_tlast & mon_ifc.s_axis_tvalid & mon_ifc.s_axis_tready)begin
                @(mon_ifc.mon_cb);
                sample_data;
                $display("%0t[MON] : SAMPLING DATA PACKET DONE. SENDING IT TO SCOREBOARD.",$time);
                mon_sco_mb.put(tr);
            end
            else if(mon_ifc.s_axis_tvalid & mon_ifc.s_axis_tready)begin
                sample_data;
            end
            
        end
        
    endtask

endclass


`endif
