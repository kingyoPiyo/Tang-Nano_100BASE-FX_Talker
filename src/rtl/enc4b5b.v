/*****************************************************************
* Title     : 4b5b Encoder for 100BASE-FX
* Date      : 2020/09/20
* Design    : kingyo
******************************************************************/
module enc4b5b (
    input   wire            i_clk,
    input   wire            i_res_n,
    input   wire    [3:0]   i_data,
    input   wire            i_tx_en,
    output  reg     [4:0]   o_data
);

    // Tx Sequence memo
    // [START] J => K => **t_data** => T => R [END]

    reg     [1:0]   r_tx_en_old;
    always @(posedge i_clk or negedge i_res_n) begin
        if (~i_res_n) begin
            o_data[4:0] <= 5'd0;
            r_tx_en_old[1:0] <= 2'd0;
        end else begin
            r_tx_en_old[1:0] <= {r_tx_en_old[0], i_tx_en};

            if (i_tx_en & (r_tx_en_old[1:0] == 2'b00)) begin
                o_data[4:0] <= 5'b11000;    // J
            end else if (i_tx_en & (r_tx_en_old[1:0] == 2'b01)) begin
                o_data[4:0] <= 5'b10001;    // K
            end else if (i_tx_en & (r_tx_en_old[1:0] == 2'b11)) begin
                case (i_data[3:0])
                    4'h0: o_data[4:0] <= 5'b11110;
                    4'h1: o_data[4:0] <= 5'b01001;
                    4'h2: o_data[4:0] <= 5'b10100;
                    4'h3: o_data[4:0] <= 5'b10101;
                    4'h4: o_data[4:0] <= 5'b01010;
                    4'h5: o_data[4:0] <= 5'b01011;
                    4'h6: o_data[4:0] <= 5'b01110;
                    4'h7: o_data[4:0] <= 5'b01111;
                    4'h8: o_data[4:0] <= 5'b10010;
                    4'h9: o_data[4:0] <= 5'b10011;
                    4'hA: o_data[4:0] <= 5'b10110;
                    4'hB: o_data[4:0] <= 5'b10111;
                    4'hC: o_data[4:0] <= 5'b11010;
                    4'hD: o_data[4:0] <= 5'b11011;
                    4'hE: o_data[4:0] <= 5'b11100;
                    4'hF: o_data[4:0] <= 5'b11101;
                endcase
            end else if (~i_tx_en & (r_tx_en_old[1:0] == 2'b11)) begin
                o_data[4:0] <= 5'b01101;    // T
            end else if (~i_tx_en & (r_tx_en_old[1:0] == 2'b10)) begin
                o_data[4:0] <= 5'b00111;    // R
            end else begin
                o_data[4:0] <= 5'b11111;    // IDLE
            end
        end
    end

endmodule
