/*****************************************************************
* Title     : 100BASE-FX Serial Transmitter
* Date      : 2020/09/20
* Design    : kingyo
******************************************************************/
module serialTx (
    input   wire            i_clk125m,      // Serial Clock
    input   wire            i_res_n,        // Reset
    input   wire            i_mii_clk,      // MII TX_CLK
    input   wire            i_mii_tx_en,    // MII TX_EN
    input   wire    [3:0]   i_mii_txd,      // MII TXD
    output  wire            o_sdata         // Serial Data Output
);

    wire    [4:0]   w_5b_data;              // ** 25MHz => 125MHz **

    // 4b5b Encoder
    enc4b5b enc4b5b_inst (
        .i_clk ( i_mii_clk ),
        .i_res_n ( i_res_n ),
        .i_data ( i_mii_txd[3:0] ),
        .i_tx_en ( i_mii_tx_en ),
        .o_data ( w_5b_data )
    );

    // Serializer (MSB First)
    reg         r_ser_data;
    reg [2:0]   r_serCnt;
    reg [3:0]   r_5b_lat;
    always @(posedge i_clk125m or negedge i_res_n) begin
        if (~i_res_n) begin
            r_ser_data <= 1'b0;
            r_serCnt <= 3'd0;
            r_5b_lat <= 4'd0;
        end else begin
            if (r_serCnt == 3'd4) begin
                r_serCnt <= 3'd0;
                r_ser_data <= w_5b_data[4];
                r_5b_lat <= w_5b_data[3:0];
            end else begin
                r_ser_data <= r_5b_lat[3];
                r_5b_lat <= {r_5b_lat[2:0], 1'b0};
                r_serCnt <= r_serCnt + 3'd1;
            end
        end
    end

    // NRZI Encoder
    reg         r_nrzi_data;
    always @(posedge i_clk125m or negedge i_res_n) begin
        if (~i_res_n) begin
            r_nrzi_data <= 1'b0;
        end else begin
            r_nrzi_data <= r_ser_data ^ r_nrzi_data;
        end
    end
    assign o_sdata = r_nrzi_data;
    
endmodule
