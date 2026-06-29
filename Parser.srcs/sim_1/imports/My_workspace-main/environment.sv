`include "generator.sv"
`include "driver.sv"
`include "monitor.sv"
`include "scoreboard.sv"
`include "transction.sv"
`include "interface.sv"

`ifndef ETH_PARSE_ENVIRONMENT
`define ETH_PARSE_ENVIRONMENT

import transaction_pkg::* ;

//`define mailbox_sco mailbox#(transaction)

class environment;

    generator   gen;
    monitor     mon;
    driver      drv;
    scoreboard  sco;
    
    mailbox#(transaction) mon_sco_mb;
    mailbox#(transaction) gen_sco_mb;
    mailbox#(transaction) gen_drv_mb;
    event       sco_done;
    event       gen_done;
    
    //initialize function for generator class
    function new(input      virtual     parser_ifc  vifc,
                 input      int                     gen_count,
                 input bit  [1:0]                   packet_len_type, 
                 input bit  [2:0]                   dst_mac_addr_type, 
                 input bit  [2:0]                   ether_type, 
                 input bit  [1:0]                   vlan_type
                 );
                   
        //intialize mailbox
        gen_drv_mb              = new();
        gen_sco_mb              = new();
        mon_sco_mb              = new();
        
        //initiliaze env components
        gen     = new(gen_drv_mb, gen_sco_mb, sco_done, packet_len_type, dst_mac_addr_type, ether_type, vlan_type, gen_count, gen_done);
        drv     = new(gen_drv_mb, sco_done, vifc);
        mon     = new(mon_sco_mb, vifc);
        sco     = new(mon_sco_mb, gen_sco_mb, sco_done);
        
    endfunction
    
    //Define pre_test task
    task pre_test;
        drv.reset_dut();
    endtask
    
    //Define test task
    task test;
            fork
                gen.gen_stimulus();
                drv.drvie_stimulus();
                mon.sample_values();
                sco.sample_values();
            join_none
        endtask
    
    //Define post_test task
    task post_test;
            @(gen_done);
            $display("%0t[ENV] : TERMINATING TEST BENCH.",$time);
            $finish;
        endtask
    
    //Define Main task
    task run;
        pre_test();
        test();
        post_test();
    endtask

endclass


`endif

