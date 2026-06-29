
`include "transction.sv"
`include "interface.sv"

`ifndef ETH_PARSE_DRIVER
`define ETH_PARSE_DRIVER

import transaction_pkg::* ;

//`define mailbox_drv mailbox#(transaction)
//`define virtual parser_ifc vifc


class driver;
    
    transaction tr;
    mailbox#(transaction) gen_driver_mb;
    event       sco_bd_done;
    virtual parser_ifc        drv_ifc;
    
    //initialize function for generator class
    function new(input      mailbox#(transaction)   gen_driver_mb, 
                 input      event                   sco_bd_done,
                 virtual    parser_ifc              drv_ifc
                 );
                   
        //Initialize 
        this.gen_driver_mb      = gen_driver_mb;
        this.sco_bd_done        = sco_bd_done;
        this.drv_ifc            = drv_ifc; 
        
    endfunction
    
    //Display function
    function void display();
        $display("---------------------------------------------------------------------------------------------");
        $display("%0t[DRV] : DRIVER PACKET DATA VALUES",$time);
    endfunction
    
    //Reset function 
    task reset_dut();
        
        $display("%0t[DRV] : PROCESSING INITIAL RESET",$time);
        drv_ifc.rst = 1'b1;
        drv_ifc.drv_cb.s_axis_tdata <= 0;
        drv_ifc.drv_cb.s_axis_tkeep <= 0;
        drv_ifc.drv_cb.s_axis_tvalid <= 0;
        drv_ifc.drv_cb.s_axis_tlast <= 0;
        repeat(10) @(drv_ifc.drv_cb);
        drv_ifc.rst = 1'b0;
        @(drv_ifc.drv_cb);
        $display("%0t[DRV] : INITIAL RESET DONE",$time);
        
    endtask
    
    //Main stimulus genration task
    task drvie_stimulus;

        display();
        
        forever begin
        
            gen_driver_mb.get(tr);
            
            foreach(tr.packet_data_queue[x]) begin
                
                @(drv_ifc.drv_cb);
                drv_ifc.drv_cb.s_axis_tdata  <= tr.packet_data_queue[x];
                drv_ifc.drv_cb.s_axis_tkeep  <= 'hff;
                drv_ifc.drv_cb.s_axis_tvalid <= (x <= (tr.packet_len - 1));
                drv_ifc.drv_cb.s_axis_tlast  <= (x == (tr.packet_len - 2));
//                $display("%0t[DRV] : Beat %0d = %0h", $time, x, drv_ifc.s_axis_tdata);
//                $display("[DRV] : DATA DRVIEN");
            
            end
            
            $display("%0t[DRV] : DONE DRIVING DATA.", $time);
            
            drv_ifc.drv_cb.s_axis_tdata  <= 0;
            drv_ifc.drv_cb.s_axis_tkeep  <= 0;
            drv_ifc.drv_cb.s_axis_tvalid <= 0;
            drv_ifc.drv_cb.s_axis_tlast  <= 0;
            
        end
        
    endtask

endclass


`endif
