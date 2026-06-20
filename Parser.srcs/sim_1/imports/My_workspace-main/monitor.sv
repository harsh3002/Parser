
`include "transction.sv"
`include "interface.sv"

`ifndef ETH_PARSE_MONITOR
`define ETH_PARSE_MONITOR

import transaction_pkg::* ;

`define mailbox_mon mailbox#(transaction)
`define virtual parser_ifc vifc


class monitor;
    
    transaction tr;
    mailbox_drv mon_sco_mb;
    vifc        drc_ifc;
    
    //initialize function for generator class
    function new(input      mailbox#(transaction)   mon_sco_mb, 
                 virtual    parser_ifc              drv_ifc
                 );
                   
        //Initialize 
        tr                      = new;
        this.mon_sco_mb         = mon_sco_mb;
        this.drv_ifc            = drv_ifc; 
        
    endfunction
    
    //Display function
    function display();
        $display("%0t[MON] : MONITOR",$time);
    endfunction
    
    //Reset function 
    task reset_dut();
        
        $display("%0t[DRV] : PROCESSING INITIAL RESET",$time);
        drv_ifc.rst = 1'b1;
        drv_ifc.drv_cb.s_axis_tdata = 0;
        drv_ifc.drv_cb.s_axis_tkeep = 0;
        drv_ifc.drv_cb.s_axis_tvalid = 0;
        drv_ifc.drv_cb.s_axis_tlast = 0;
        repeat(10) @(drv_ifc.drv_cb);
        drv_ifc.drv_cb.rst = 1'b0;
        @(drv_ifc.drv_cb);
        $display("%0t[DRV] : INITIAL RESET DONE",$time);
        
    endtask
    
    //Main stimulus genration task
    task drvie_stimulus;

        reset_dut();
        display();
        
        forever begin
        
            gen_driver_mb.get(tr);
            
            foreach(tr.copy.packet_data_queue[x]) begin
                
                @(drv_ifc.drv_cb);
                drv_ifc.drv_cb.s_axis_tdata  = tr.copy.packet_data_queue[x];
                drv_ifc.drv_cb.s_axis_tkeep  = 'hff;
                drv_ifc.drv_cb.s_axis_tvalid = (x <= (tr.copy.packet_len - 1));
                drv_ifc.drv_cb.s_axis_tlast  = (x == (tr.copy.packet_len - 1));
                $display("%0t[DRV] : Beat %0d = %0h", $time, x, drv_ifc.drv_cb.s_axis_tdata);
                $display("[DRV] : DATA DRVIEN");
            
            end
            
            drv_ifc.drv_cb.s_axis_tdata  = 0;
            drv_ifc.drv_cb.s_axis_tkeep  = 0;
            drv_ifc.drv_cb.s_axis_tvalid = 0;
            drv_ifc.drv_cb.s_axis_tlast  = 0;
            
        end
        
    endtask

endclass


`endif
