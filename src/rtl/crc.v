/************************************************************************
* Title     : CRC Calculator
* Date      : 2020/09/20
* Design    : kingyo
* Reference : https://www.rightxlight.co.jp/technical/crc-verilog-hdl
*************************************************************************/
module crc # (
    parameter DATA_WIDTH = 8,                       //% データ幅
    parameter CRC_WIDTH = 16,                       //% CRCデータ幅
    parameter [CRC_WIDTH-1:0] POLYNOMIAL = 16'h1021,//% 生成多項式
    parameter [CRC_WIDTH-1:0] SEED_VAL = 16'h0,     //% シード値
    parameter OUTPUT_EXOR = 16'h0                   //% 出力反転
) (
    input CLK,                          //% クロック
    input RESET_N,                      //% リセット(負論理)
    input IN_CLR,                       //% 入力CRC初期化
    input IN_ENA,                       //% 入力イネーブル
    input [DATA_WIDTH-1:0] IN_DATA,     //% 入力データ
    output [CRC_WIDTH-1:0] OUT_CRC      //% CRC演算結果出力
);
    reg [CRC_WIDTH-1:0] crc_reg;
    
    /*! CRC演算関数
    */
    function [CRC_WIDTH-1:0] crc_calc;
        input [CRC_WIDTH-1:0] in_crc;
        input in_data;
        integer i;
    begin
        for (i = 0; i < CRC_WIDTH; i = i + 1) begin
                crc_calc[i] = 1'b0;
            if (i != 0)
                crc_calc[i] = in_crc[i-1];
            if (POLYNOMIAL[i])
                crc_calc[i] = crc_calc[i] ^ in_crc[CRC_WIDTH-1] ^ in_data;
        end
    end
    endfunction
    
    /*! CRC演算ループ関数
    */
    function [CRC_WIDTH-1:0] crc_calc_l;
        input [CRC_WIDTH-1:0] in_crc;
        input [DATA_WIDTH-1:0] in_data;
        integer i;
        begin
            crc_calc_l = in_crc;
            for (i = 0; i < DATA_WIDTH; i = i + 1) begin
                crc_calc_l = crc_calc(crc_calc_l, in_data[(DATA_WIDTH-1)-i]);
            end
        end
    endfunction
    
    /*! CRCレジスタ
    */
    always @(posedge CLK or negedge RESET_N) begin
        if (~RESET_N)
            crc_reg <= SEED_VAL;
        else begin
            if (IN_CLR)
                crc_reg <= SEED_VAL;
            else if (IN_ENA)
                //crc_reg <= crc_calc_l(crc_reg, IN_DATA); // refin = false
                crc_reg <= crc_calc_l(crc_reg, {IN_DATA[0], IN_DATA[1], IN_DATA[2], IN_DATA[3]}); // refin = true
        end
    end
    
    assign OUT_CRC = crc_reg ^ OUTPUT_EXOR;

endmodule
