/*****************************************************************
* Title     : Tang-Nano 100BASE-FX Talker
* Date      : 2020/09/20
* Design    : kingyo
******************************************************************/
module tx_top (
    input   wire    mco,        // 50MHz
    input   wire    res_n,      // Reset
    input   wire    btn_b,      // Button B

    // LED
    output  wire    onb_led_r,  // Tx Enable

    // SFP
    input   wire    sfp_los,    // SFP LOS (not use)
    input   wire    sfp_rx,     // SFP RD (not use)
    output  wire    sfp_tx,     // SFP TD

    // ADC
    input   wire    adc_in,     // LVDS input
    output  wire    adc_cmp     // Comparison value output
);

    // Clock & Reset
    wire            clk125m;
    wire            clk25m;
    wire            w_pll_lock;
    wire            w_res_n;
    // ADC
    wire    [9:0]   w_adc_val;
    wire            w_adc_done;
    // MII
    wire            w_mii_clk;
    wire            w_mii_tx_en;
    wire    [3:0]   w_mii_txd;
    
    // PLL
    Gowin_PLL pll (
        .clkout ( clk125m ),    // output clkout
        .reset ( 1'b0 ),        // input reset
        .clkin ( mco ),         // input clkin
        .lock ( w_pll_lock )    // Locked
    );

    // Synchronous reset
    rstGen rstGen (
        .i_clk ( clk125m ),
        .i_res_n ( res_n & w_pll_lock ),
        .o_res_n ( w_res_n )
    );

    // Clock divider
    // 125MHz / 5 => 25MHz
    CLKDIV CLKDIV1 (
        .HCLKIN ( clk125m ),
        .RESETN ( w_res_n ),
        .CALIB ( 1'b0 ),
        .CLKOUT ( clk25m )
    );
    defparam CLKDIV1.DIV_MODE="5";
    defparam CLKDIV1.GSREN="false";

    // 10bit Delta Sigma ADC
    adc adc1 (
        .i_clk ( clk25m ),
        .i_res_n ( w_res_n ),
        .i_adc_in ( adc_in ),
        .o_adc_cmp ( adc_cmp ),
        .o_adc_val ( w_adc_val[9:0] ),
        .o_adc_done ( w_adc_done )
    );

    // Button-B Capture & Triger Mask
    reg     [1:0]   r_btnb_ff;
    always @(posedge clk25m or negedge w_res_n) begin
        if(~w_res_n) begin
            r_btnb_ff[1:0] <= 2'b11;
        end else begin
            r_btnb_ff[1:0] <= {r_btnb_ff[0], btn_b};
        end
    end
    
    // Ethernet Frame Generator
    ethernetFrameGen ethernetFrameGen (
        .i_clk ( clk25m ),
        .i_res_n ( w_res_n ),
        .i_tx_trig ( w_adc_done & ~r_btnb_ff[1] ),
        .i_tx_data ( {22'd0, w_adc_val[9:0]} ),
        .o_mii_tx_clk ( w_mii_clk ),
        .o_mii_tx_en ( w_mii_tx_en ),
        .o_mii_txd ( w_mii_txd[3:0] )
    );

    // Tx Module(4b5b + Serializer)
    serialTx serialTx (
        .i_clk125m ( clk125m ),
        .i_res_n ( w_res_n ),
        .i_mii_clk ( w_mii_clk ),
        .i_mii_tx_en ( w_mii_tx_en ),
        .i_mii_txd ( w_mii_txd[3:0] ),
        .o_sdata ( sfp_tx )
    );

    // TX Enable LED
    assign onb_led_r = ~w_mii_tx_en;

endmodule
