
`include "transction.sv"
`include "interface.sv"

`ifndef ETH_PARSE_SCOREBOARD
`define ETH_PARSE_SCOREBOARD

import transaction_pkg::* ;

`define mailbox_sco mailbox#(transaction)

class scoreboard;
    
    transaction gen_sco_tr;
    transaction mon_sco_tr;
    mailbox#(transaction) mon_sco_mb;
    mailbox#(transaction) gen_sco_mb;
    event       sco_done;
    int         error_count = 0;
    
    //initialize function for generator class
    function new(input      mailbox#(transaction)   mon_sco_mb, 
                 input      mailbox#(transaction)   gen_sco_mb,
                 input      event                   sco_done
                 );
                   
        //Initialize 
        this.mon_sco_mb         = mon_sco_mb;
        this.gen_sco_mb         = gen_sco_mb;
        this.sco_done           = sco_done;
        
    endfunction
    
    //Display function
    function display();
        $display("%0t[MON] : MONITOR",$time);
    endfunction
    
    //Reset  sampling function 
    task sample_reset();
        
        $display("%0t[SCO] : RESET ENCOUNTERED",$time);
        
    endtask
    
    //Data sampling function
    task validate_packet_data();
        
        $display("%0t[SCO] : VALIDATING PACKET DATA",$time);
        if(mon_sco_tr.dst_mac_addr != gen_sco_tr.dst_mac_addr) begin
            error_count++;
            $display("%0t[SCO] : DESTINATION ADDRESS MISMATCH :",$time);
            $display("%0t[SCO] : EXPECTED DST_ADDR : %0d    SAMPLED DST_ADDR : %0d :",$time, gen_sco_tr.dst_mac_addr, mon_sco_tr.dst_mac_addr);
        end
        if(mon_sco_tr.src_mac_addr != gen_sco_tr.src_mac_addr) begin
            error_count++;
            $display("%0t[SCO] : SOURCE ADDRESS MISMATCH :",$time);
            $display("%0t[SCO] : EXPECTED SRC_ADDR : %0d    SAMPLED SRC_ADDR : %0d :",$time, gen_sco_tr.src_mac_addr, mon_sco_tr.src_mac_addr);
        end
        if(mon_sco_tr.ether_type != gen_sco_tr.ether_type) begin
            error_count++;
            $display("%0t[SCO] : ETHER TYPE MISMATCH :",$time);
            $display("%0t[SCO] : EXPECTED ETHER_TYPE : %0d    SAMPLED ETHER_TYPE : %0d :",$time, gen_sco_tr.ether_type, mon_sco_tr.ether_type);
        end
        else if(mon_sco_tr.vlan_valid != gen_sco_tr.vlan_valid) begin
            error_count++;
            $display("%0t[SCO] : VLAN VALID MISMATCH :",$time);
            $display("%0t[SCO] : EXPECTED VLAN_VALID : %0d    SAMPLED VLAN_VALID : %0d :",$time, gen_sco_tr.vlan_valid, mon_sco_tr.vlan_valid);
        end
        if(mon_sco_tr.vlan_id != gen_sco_tr.vlan_id) begin
            error_count++;
            $display("%0t[SCO] : VLAN ID MISMATCH :",$time);
            $display("%0t[SCO] : EXPECTED VLAN_ID : %0d    SAMPLED VLAN_ID : %0d :",$time, gen_sco_tr.vlan_id, mon_sco_tr.vlan_id);
        end
        if(mon_sco_tr.qinq_valid != gen_sco_tr.qinq_valid) begin
            error_count++;
            $display("%0t[SCO] : QINQ VALID MISMATCH :",$time);
            $display("%0t[SCO] : EXPECTED QINQ_VALID : %0d    SAMPLED QINQ_VALID : %0d :",$time, gen_sco_tr.qinq_valid, mon_sco_tr.qinq_valid);
        end
        if(mon_sco_tr.outer_vlan_id != gen_sco_tr.outer_vlan_id) begin
            error_count++;
            $display("%0t[SCO] : OUTER VLAN ID MISMATCH :",$time);
            $display("%0t[SCO] : EXPECTED OUTER_VLAN_ID : %0d    SAMPLED OUTER_VLAN_ID : %0d :",$time, gen_sco_tr.outer_vlan_id, mon_sco_tr.outer_vlan_id);
        end
        if(mon_sco_tr.inner_vlan_id != gen_sco_tr.inner_vlan_id) begin
            error_count++;
            $display("%0t[SCO] : INNER VLAN ID MISMATCH :",$time);
            $display("%0t[SCO] : EXPECTED INNER_VLAN_ID : %0d    SAMPLED INNER_VLAN_ID : %0d :",$time, gen_sco_tr.inner_vlan_id, mon_sco_tr.inner_vlan_id);
        end
        if(mon_sco_tr.packet_len != (gen_sco_tr.packet_len*8)) begin
            error_count++;
            $display("%0t[SCO] : PACKET LENGTH MISMATCH :",$time);
            $display("%0t[SCO] : EXPECTED PACKET_LEN : %0d    SAMPLED PACKET_LEN : %0d :",$time, (gen_sco_tr.packet_len*8), mon_sco_tr.packet_len);
        end
        if(mon_sco_tr.jumbo_frame_valid != gen_sco_tr.jumbo_frame_valid) begin
            error_count++;
            $display("%0t[SCO] : JUMBO FRAME VALID MISMATCH :",$time);
            $display("%0t[SCO] : EXPECTED JUMBO_FRAME_VALID : %0d    SAMPLED PACKET_LEN : %0d :",$time, gen_sco_tr.jumbo_frame_valid, mon_sco_tr.jumbo_frame_valid);
        end
        if(mon_sco_tr.unicast_addr_valid != gen_sco_tr.unicast_addr_valid) begin
            error_count++;
            $display("%0t[SCO] : UNICAST VALID MISMATCH :",$time);
            $display("%0t[SCO] : EXPECTED UNICAST_VALID : %0d    SAMPLED UNICAST_VALID : %0d :",$time, gen_sco_tr.unicast_addr_valid, mon_sco_tr.unicast_addr_valid);
        end
        if(mon_sco_tr.multicast_addr_valid != gen_sco_tr.multicast_addr_valid) begin
            error_count++;
            $display("%0t[SCO] : MULTICAST VALID MISMATCH :",$time);
            $display("%0t[SCO] : EXPECTED MULTICAST_VALID : %0d    SAMPLED MULTICAST_VALID : %0d :",$time, gen_sco_tr.multicast_addr_valid, mon_sco_tr.multicast_addr_valid);
        end
        if(mon_sco_tr.broadcast_addr_valid != gen_sco_tr.broadcast_addr_valid) begin
            error_count++;
            $display("%0t[SCO] : BROADCAST VALID MISMATCH :",$time);
            $display("%0t[SCO] : EXPECTED BROADCAST_VALID : %0d    SAMPLED BROADCAST_VALID : %0d :",$time, gen_sco_tr.broadcast_addr_valid, mon_sco_tr.broadcast_addr_valid);
        end
        if(mon_sco_tr.ipv4_valid != gen_sco_tr.ipv4_valid) begin
            error_count++;
            $display("%0t[SCO] : IPV4 VALID MISMATCH :",$time);
            $display("%0t[SCO] : EXPECTED IPV4_VALID : %0d    SAMPLED IPV4_VALID : %0d :",$time, gen_sco_tr.ipv4_valid, mon_sco_tr.ipv4_valid);
        end
        if(mon_sco_tr.ipv6_valid != gen_sco_tr.ipv6_valid) begin
            error_count++;
            $display("%0t[SCO] : IPV6 VALID MISMATCH :",$time);
            $display("%0t[SCO] : EXPECTED IPV6_VALID : %0d    SAMPLED IPV6_VALID : %0d :",$time, gen_sco_tr.ipv6_valid, mon_sco_tr.ipv6_valid);
        end
        if(mon_sco_tr.arp_valid != gen_sco_tr.arp_valid) begin
            error_count++;
            $display("%0t[SCO] : ARP VALID MISMATCH :",$time);
            $display("%0t[SCO] : EXPECTED ARP_VALID : %0d    SAMPLED ARP_VALID : %0d :",$time, gen_sco_tr.arp_valid, mon_sco_tr.arp_valid);
        end
//        if(mon_sco_tr.packet_data_queue != gen_sco_tr.packet_data_queue) begin
//            error_count++;
//            $display("%0t[SCO] : DATA PACKET MISMATCH :",$time);
//            $display("%0t[SCO] : EXPECTED DATA PACKET  : %0d    SAMPLED DATA PACKET  : %0d :",$time, gen_sco_tr.packet_data_queue, mon_sco_tr.packet_data_queue);
//        end
        
        if(error_count != 0 )begin
            $display("%0t[SCO] : ERRORS CAUGHT IN PARSER :",$time, error_count);
        end
        else begin
            $display("%0t[SCO] : PARSER IS ERROR FREE ",$time);
        end
        
        $display("%0t[SCO] : VALIDATING DATA PACKET DONE",$time);
        
    endtask
    
    //Main stimulus genration task
    task sample_values;
        
        forever begin
        
            gen_sco_mb.get(gen_sco_tr);
            mon_sco_mb.get(mon_sco_tr);
            validate_packet_data();
            $display("%0t[SCO] : TRANSACTION COMPLETED ",$time);
            $display("---------------------------------------------------------------------------------------------");
            ->sco_done;
            
        end
        
    endtask

endclass


`endif
