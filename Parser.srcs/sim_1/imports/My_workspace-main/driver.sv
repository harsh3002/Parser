`include "transction.sv"
`include "interface.sv"

`ifndef ETH_PARSE_DRIVER
`define ETH_PARSE_DRIVER

import transaction_pkg::* ;

`define mailbox_drv mailbox#(transaction)
`define virtual parser_ifc vifc


class driver;
    
    transaction tr;
    mailbox_drv gen_driver_mb;
    event       sco_bd_done;
    vifc        drc_ifc;
    
    //initialize function for generator class
    function new(input      mailbox#(transaction)   gen_driver_mb, 
                 input      event                   sco_bd_done,
                 virtual    parser_ifc              drv_ifc
                 );
                   
        //Initialize 
        tr                      = new;
        this.gen_driver_mb      = gen_driver_mb;
        this.sco_bd_done        = sco_bd_done;
        this.drv_ifc            = drv_ifc; 
        
    endfunction
    
    //Display function
    function display();
        $display("---------------------------------------------------------------------------------------------");
        $display("%0t[GEN] : DRIVER PACKET DATA VALUES",$time);
        $display("%0t[GEN] : Beat %0d = %0h", $time, x, tr.copy.packet_data_queue[x]);
    endfunction
    
    //Reset function 
    function reset_dut();
        
        drv_ifc.rst = 1'b1;
        
    endfunction
    
    //Main stimulus genration task
    task drvie_stimulus;
        
        display();
        
        while(1) begin
            
            repeat(tr.copy.packet_len) begin
                
                @(negedge clk);
                assert(tr.randomize());
                gen_driver_mb.put(tr.copy);
                display();
                $display("[GEN] : DATA SENT TO DRIVER");
                @(sco_bd_done);
                #1;
            
            end
            
        end
        
        -> gen_done;
        
    endtask

endclass


`endif
