`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.06.2026 13:54:36
// Design Name: 
// Module Name: ethernet_parser_top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module ethernet_parser_top(
        //Global signals
        input               clk_i,
        input               rstn_i,
        
        //AXI-S signals
        input  logic [63:0] s_axis_tdata,
        input  logic [7:0]  s_axis_tkeep,
        input  logic        s_axis_tvalid,
        output logic        s_axis_tready,
        input  logic        s_axis_tlast,
        
        //Header signals
        output logic [47:0] dst_mac,
        output logic [47:0] src_mac,
        output logic [15:0] ethertype,
        
        //VLAN signals
        output logic        vlan_present,
        output logic [11:0] vlan_id,
        output logic        qinq_present,
        output logic [11:0] outer_vlan_id,
        output logic [11:0] inner_vlan_id,
        
        //Packet size signals
        output logic [15:0] packet_length,
        output logic        jumbo_frame,
        
        //Addres information signals
        output logic        is_unicast,
        output logic        is_multicast,
        output logic        is_broadcast,
        
        //Frame information signals
        output logic        is_ipv4,
        output logic        is_ipv6,
        output logic        is_arp,
        
        //Status signals
        output logic        metadata_valid
        
    );
    
    //Ethertypes and VLAN types
    localparam IPv4     = 16'h0800;
    localparam IPv6     = 16'h86DD;
    localparam ARP      = 16'h0806;
    localparam VLAN     = 16'h8100;
    localparam QinQ     = 16'h88A8;
    localparam MULTICAST= 1'd1;
    localparam BROADCAST= 48'hffff_ffff_ffff;
    
    //State enumeration
    typedef enum logic [3:0] {
        ST_IDLE,
        ST_HEADER_EXT,
        ST_PAYLOAD
    }state_t;
    
    //State veriable declaration
    state_t state;
    
    //Intermediate variables
    logic [127:0]   header_window;
    logic [15:0]    beat_counter;
    
    //Function for calculating ethertype
    function logic [18:0] get_ethertype(input logic [15:0] ethertype_field);
        
        case(ethertype_field) 
            
            IPv4    : begin
                        return {3'b100, IPv4};
                      end
            IPv6    : begin
                        return {3'b010, IPv6};
                      end
            ARP     : begin
                        return {3'b001, ARP};
                      end
            default : return 0;
            
        endcase
        
    endfunction
    
    //Function for calculating address type
    function logic [2:0] get_addresstype(input [47:0] dst_mac_addr);
        
        if(dst_mac_addr == BROADCAST)begin
            return 3'b100;
        end
        else if(dst_mac_addr[40] == MULTICAST)begin
            return 3'b010;
        end
        else begin
            return 3'b001;
        end
        
    endfunction
    
    //State machine logic for ethernet parser 
    always@(posedge clk_i)begin
        if(!rstn_i)begin
            state               <= ST_IDLE;
            header_window       <= 0;
            s_axis_tready       <= 0;
            dst_mac             <= 0; 
            src_mac             <= 0;
            ethertype           <= 0;
            vlan_present        <= 0;
            vlan_id             <= 0;
            qinq_present        <= 0;
            outer_vlan_id       <= 0;
            inner_vlan_id       <= 0;
            packet_length       <= 0;
            jumbo_frame         <= 0;
            is_unicast          <= 0;
            is_multicast        <= 0;
            is_broadcast        <= 0;
            is_ipv4             <= 0;
            is_ipv6             <= 0;
            is_arp              <= 0;
            metadata_valid      <= 0;
            beat_counter        <= 0;
        end
        else begin
            s_axis_tready   <= 1'b1;
            
            case(state)
            
                ST_IDLE : begin
                    
                    //State Handling
                    state   <= (s_axis_tready & s_axis_tvalid) ? ST_HEADER_EXT : ST_IDLE;
                    
                    //Data signals 
                    if(s_axis_tready & s_axis_tvalid) begin
                        header_window[127:64]   <= (s_axis_tready & s_axis_tvalid) ? s_axis_tdata : 0;
                        header_window[63:0]     <= 0;
                        dst_mac                 <= 0; 
                        src_mac                 <= 0;
                        ethertype               <= 0;
                        vlan_present            <= 0;
                        vlan_id                 <= 0;
                        qinq_present            <= 0;
                        outer_vlan_id           <= 0;
                        inner_vlan_id           <= 0;
                        packet_length           <= 0;
                        jumbo_frame             <= 0;
                        is_unicast              <= 0;
                        is_multicast            <= 0;
                        is_broadcast            <= 0;
                        is_ipv4                 <= 0;
                        is_ipv6                 <= 0;
                        is_arp                  <= 0;
                        metadata_valid          <= 0;
                        beat_counter            <= beat_counter + 1'b1;
                    end
                    
                end
                
                ST_HEADER_EXT : begin
                    
                    //State Handling
                    state   <= (s_axis_tready & s_axis_tvalid) & 
                               ((s_axis_tdata[31:16] == QinQ) | (s_axis_tdata[31:16] == VLAN)) ? ST_HEADER_EXT : ST_PAYLOAD;
                    
                    //Data signals 
                    header_window[63:0] <= (s_axis_tready & s_axis_tvalid & !qinq_present & !vlan_present) ? s_axis_tdata : 0;
                    
                    if((s_axis_tready & s_axis_tvalid) & (s_axis_tdata[31:16] == QinQ) & !qinq_present) begin
                        qinq_present                                <= 1'b1;
                        outer_vlan_id                               <= s_axis_tdata[11:0];
                        beat_counter                                <= beat_counter + 1'd1;
                    end
                    else if((s_axis_tready & s_axis_tvalid) & qinq_present) begin
                        inner_vlan_id                               <= s_axis_tdata[43:32];
                        {{is_ipv4, is_ipv6, is_arp}, ethertype}     <= get_ethertype(s_axis_tdata[31:16]);
                        beat_counter                                <= beat_counter + 1'd1;
                        dst_mac                                     <= header_window[127:80];
                        src_mac                                     <= header_window[79:32];
                        metadata_valid                              <= 1'b1;
                        {is_broadcast, is_multicast, is_unicast}    <= get_addresstype(header_window[127:80]);
                    end
                    else if((s_axis_tready & s_axis_tvalid) & (s_axis_tdata[31:16] == VLAN) & !vlan_present) begin
                        vlan_present                                <= 1'b1;
                        vlan_id                                     <= s_axis_tdata[11:0];
                        beat_counter                                <= beat_counter + 1'd1;
                    end
                    else if((s_axis_tready & s_axis_tvalid) & vlan_present) begin
                        {{is_ipv4, is_ipv6, is_arp}, ethertype}     <= get_ethertype(s_axis_tdata[63:48]);
                        dst_mac                                     <= header_window[127:80];
                        src_mac                                     <= header_window[79:32];
                        metadata_valid                              <= 1'b1;
                        {is_broadcast, is_multicast, is_unicast}    <= get_addresstype(header_window[127:80]);
                        beat_counter                                <= beat_counter + 1'd1;
                    end
                    else if((s_axis_tready & s_axis_tvalid)) begin
                        {{is_ipv4, is_ipv6, is_arp}, ethertype}     <= get_ethertype(s_axis_tdata[31:16]);
                        dst_mac                                     <= header_window[127:80];
                        src_mac                                     <= {header_window[79:64], s_axis_tdata[63:32]};
                        metadata_valid                              <= 1'b1;
                        beat_counter                                <= beat_counter + 1'd1;
                        {is_broadcast, is_multicast, is_unicast}    <= get_addresstype(header_window[127:80]);
                    end
                end
                
                ST_PAYLOAD : begin
                    
                    //State Handling
                    state   <= (s_axis_tready & s_axis_tvalid & s_axis_tlast) ? ST_IDLE : ST_PAYLOAD;
                    
                    //Data signals 
                    beat_counter    <= (s_axis_tready & s_axis_tvalid) ? beat_counter + 1'b1 : beat_counter;
                    packet_length   <= (s_axis_tready & s_axis_tvalid & s_axis_tlast) ? (beat_counter << 3) + $countones(s_axis_tkeep) : packet_length ;
                    jumbo_frame     <= (((beat_counter << 3) + $countones(s_axis_tkeep)) > 1500) ? 1'd1 : 1'd0;
                    
                end
            
            endcase
        end
    end
    
endmodule
