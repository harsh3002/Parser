`timescale 1ns / 1ns

`include "environment.sv"
`include "interface.sv"

`ifndef ETH_PARSER_BASE_TB
`define ETH_PARSER_BASE_TB

module base_tb();
    
    //Handler Declaration 
    environment env;
    parser_ifc  eth_ifc();
    
    //Intermediate variables declaration
    bit  [1:0]                   packet_len_type; 
    bit  [2:0]                   dst_mac_addr_type; 
    bit  [2:0]                   ether_type;
    bit  [1:0]                   vlan_type;
    
    //DUT instantiation
    ethernet_parser_top dut(
        //Global signals
        .clk_i(eth_ifc.clk),
        .rstn_i(eth_ifc.rst),
        
        //AXI-S signals
        .s_axis_tdata(eth_ifc.s_axis_tdata),
        .s_axis_tkeep(eth_ifc.s_axis_tkeep),
        .s_axis_tvalid(eth_ifc.s_axis_tvalid),
        .s_axis_tready(eth_ifc.s_axis_tready),
        .s_axis_tlast(eth_ifc.s_axis_tlast),
        
        //Header signals
        .dst_mac(eth_ifc.dst_mac),
        .src_mac(eth_ifc.src_mac),
        .ethertype(eth_ifc.ethertype),
        
        //VLAN signals
        .vlan_present(eth_ifc.vlan_present),
        .vlan_id(eth_ifc.vlan_id),
        .qinq_present(eth_ifc.qinq_present),
        .outer_vlan_id(eth_ifc.outer_vlan_id),
        .inner_vlan_id(eth_ifc.inner_vlan_id),
        
        //Packet size signals
        .packet_length(eth_ifc.packet_length),
        .jumbo_frame(eth_ifc.jumbo_frame),
        
        //Addres information signals
        .is_unicast(eth_ifc.is_unicast),
        .is_multicast(eth_ifc.is_multicast),
        .is_broadcast(eth_ifc.is_broadcast),
        
        //Frame information signals
        .is_ipv4(eth_ifc.is_ipv4),
        .is_ipv6(eth_ifc.is_ipv6),
        .is_arp(eth_ifc.is_arp),
        
        //Status signals
        .metadata_valid(eth_ifc.metadata_valid)
        
    );
    
    //Clock and reset intialization
    initial eth_ifc.clk = 1;
    always #2 eth_ifc.clk = ~eth_ifc.clk;
    
    //Run test environment
    initial begin
        
        packet_len_type     = 2'b10;  
        dst_mac_addr_type   = 3'b100;
        ether_type          = 3'b100;
        vlan_type           = 2'b00;
        
        env = new(eth_ifc, 
                  2,
                  packet_len_type,
                  dst_mac_addr_type,
                  ether_type,
                  vlan_type);
                  
        env.run();
    
    end
    

endmodule

`endif