`include "transction.sv"

`ifndef ETH_PARSE_GENERATOR
`define ETH_PARSE_GENERATOR

import transaction_pkg::* ;

`define mailbox_gen mailbox#(transaction)


class generator;
    
    transaction tr;
    mailbox_gen gen_driver_mb;
    event       gen_done, sco_bd_done;
    bit  [1:0]  packet_len_type; 
    bit  [2:0]  dst_mac_addr_type;
    bit  [2:0]  ether_type;
    bit  [1:0]  vlan_type;
    int         gen_count;
    
    //initialize function for generator class
    function new(input mailbox#(transaction) gen_driver_mb, 
                 input event sco_bd_done,
                 input bit  [1:0] packet_len_type, 
                 input bit  [2:0] dst_mac_addr_type, 
                 input bit  [2:0] ether_type, 
                 input bit  [1:0] vlan_type,
                 input int        gen_count 
                 );
                 
                 
        //Initialize 
        tr = new;
        this.gen_driver_mb      = gen_driver_mb;
        this.sco_bd_done        = sco_bd_done;
        this.packet_len_type    = packet_len_type;
        this.dst_mac_addr_type  = dst_mac_addr_type;
        this.ether_type         = ether_type;
        this.vlan_type          = vlan_type;
        this.gen_count          = gen_count;
        
    endfunction
    
    //Display function
    function display();
        $display("=============================================================================================================================================================================================");
        $display("%0t[GEN] : GENERATED VALUES",$time);
        $display("%0t[GEN] : Packet_Type %d  \t Dest_MAC_Addr_type %d  \t Ether_Type %d  \t VLAN_Type %d", $time, packet_len_type, dst_mac_addr_type, ether_type, vlan_type);
        $display("%0t[GEN] : Source_MAC_Addr %d  \t Dest_MAC_Addr_type %d", $time, tr.copy.src_mac_addr, tr.copy.src_mac_addr);
        $display("%0t[GEN] : Ether_Type %d  \t Dest_MAC_Addr_type %d", $time, tr.copy.src_mac_addr, tr.copy.src_mac_addr);
        $display("%0t[GEN] : VLAN_Type %d  \t TCI %d", $time, tr.copy.vlan_type, tr.copy.inner_vlan_id);
        $display("%0t[GEN] : QinQ_Type %d  \t TCI %d", $time, tr.copy.qinq_type, tr.copy.outer_vlan_id);
    endfunction
    
    //Main stimulus genration task
    task gen_stimulus;
        
        repeat(gen_count) begin
            
            //Assign all flags to transaction 
            tr.gen_driver_mb      = gen_driver_mb;
            tr.sco_bd_done        = sco_bd_done;
            tr.packet_len_type    = packet_len_type;
            tr.dst_mac_addr_type  = dst_mac_addr_type;
            tr.ether_type         = ether_type;
            tr.vlan_type          = vlan_type;
            tr.gen_count          = gen_count;
            
            //Generate stimulus
            assert(tr.randomize());
            gen_driver_mb.put(tr.copy);
            display();
            $display("[GEN] : DATA SENT TO DRIVER");
            @(sco_bd_done);
            #1;
        
        end
        
        -> gen_done;
        
    endtask

endclass


`endif