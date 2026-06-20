
`ifndef ETH_PARSER_IFC
`define ETH_PARSER_IFC

interface parser_ifc();

    //Port Declaration
    //Global ports
    logic        clk;
    logic        rst;
    
    //AXI-S signals
    logic [63:0] s_axis_tdata;
    logic [7:0]  s_axis_tkeep;
    logic        s_axis_tvalid;
    logic        s_axis_tready;
    logic        s_axis_tlast;
    
    //Header signals
    logic [47:0] dst_mac;
    logic [47:0] src_mac;
    logic [15:0] ethertype;
    
    //VLAN signals
    logic        vlan_present;
    logic [11:0] vlan_id;
    logic        qinq_present;
    logic [11:0] outer_vlan_id;
    logic [11:0] inner_vlan_id;
    
    //Packet size signals
    logic [15:0] packet_length;
    logic        jumbo_frame;
    
    //Addres information signals
    logic        is_unicast;
    logic        is_multicast;
    logic        is_broadcast;
    
    //Frame information signals
    logic        is_ipv4;
    logic        is_ipv6;
    logic        is_arp;
    
    //Status signals
    logic        metadata_valid;
    
    
    //Clocking blocks
    //Driver clocking block
    clocking drv_cb @(negedge clk_i);
        
        //Drive 1 time unit after the negedge
        default output #1;
        
        output  rst;
        output  s_axis_tdata;
        output  s_axis_tkeep;
        output  s_axis_tvalid;
        output  s_axis_tready;
        output  s_axis_tlast;
        
    endclocking
    
    //Monitor clocking block
    clocking mon_cb @(posedge clk_i);

        input   rst;
        input   s_axis_tdata;
        input   s_axis_tkeep;
        input   s_axis_tvalid;
        input   s_axis_tready;
        input   s_axis_tlast;
               
        input   dst_mac;
        input   src_mac;
        input   ethertype;
        input   vlan_present;
        input   vlan_id;
        input   qinq_present;
        input   outer_vlan_id;
        input   inner_vlan_id;
        input   packet_length;
        input   jumbo_frame;
        input   is_unicast;
        input   is_multicast;
        input   is_broadcast;
        input   is_ipv4;
        input   is_ipv6;
        input   is_arp;
        input   metadata_valid;
        
    endclocking

endinterface

`endif
