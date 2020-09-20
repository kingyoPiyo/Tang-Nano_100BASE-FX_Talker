/*****************************************************************
* Title    : Tang-Nano 100BASE-FX Talker Testbench for ModelSim
* Date     : 2020/09/20
* Design   : kingyo
******************************************************************/
`timescale 1ns / 1ps

module tb_top ();
    parameter   P_CYCLE_50M = 20; // System Clock 50MHz

    reg     r_gsr;
    reg     r_mco = 1'b0;
    reg     r_res_n;
    reg     r_btn_b;    // Tx button

    wire    w_led_r;
    wire    w_sfp_tx;
    wire    w_adc_cmp;

    // Global System Reset
    initial begin
        r_gsr = 1'b1;
        #10
        r_gsr = 1'b0;
    end
    GSR GSR (
        .GSRI ( r_gsr )
    );
    
    // System Clock
    always #(P_CYCLE_50M/2) r_mco <= ~r_mco;
    
    // External Reset Button
    initial begin
        r_res_n = 1'b1;
        #100;
        r_res_n = 1'b0;
        #100;
        r_res_n = 1'b1;
    end

    // Tx Button
    initial begin
        r_btn_b = 1'b1;
        #1000
        r_btn_b = 1'b0;
    end

    ///////////////////////////////////////////////////////
    // DUT
    ///////////////////////////////////////////////////////
    tx_top dut (
        .mco ( r_mco ),
        .res_n ( r_res_n ),
        .btn_b ( r_btn_b ),

        // LED
        .onb_led_r ( w_led_r ),
        // SFP
        .sfp_los ( 1'b1 ),      // Low:受信出来ている
        .sfp_rx ( 1'b0 ),       // IO_TYPE=LVDS25
        .sfp_tx ( w_sfp_tx ),   // IO_TYPE=LVCMOS33D

        // ADC
        .adc_in ( 1'b0 ),
        .adc_cmp ( w_adc_cmp )
    );

endmodule
