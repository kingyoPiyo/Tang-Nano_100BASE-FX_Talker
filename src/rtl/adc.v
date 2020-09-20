/*****************************************************************
* Title     : Delta sigma ADC
* Date      : 2020/09/20
* Design    : kingyo
******************************************************************/
module adc (
    input   wire            i_clk,
    input   wire            i_res_n,
    input   wire            i_adc_in,
    output  reg             o_adc_cmp,
    output  reg     [9:0]   o_adc_val,
    output  reg             o_adc_done  // Positive 1clk pulse
);

    reg [9:0] r_adc_cnt;
    reg [9:0] r_adc_val_tmp;
    always @(posedge i_clk or negedge i_res_n) begin
        if (~i_res_n) begin
            r_adc_cnt <= 10'd0;
            r_adc_val_tmp <= 10'd0;
            o_adc_cmp <= 1'b0;
            o_adc_val <= 10'd0;
            o_adc_done <= 1'b0;
        end else begin
            o_adc_cmp <= i_adc_in;
            r_adc_cnt <= r_adc_cnt + 1;
            if (r_adc_cnt == 10'd1023) begin
                o_adc_val <= r_adc_val_tmp;
                r_adc_val_tmp <= {9'd0, o_adc_cmp};
                o_adc_done <= 1'b1;
            end else begin
                r_adc_val_tmp <= r_adc_val_tmp + {9'd0, o_adc_cmp};
                o_adc_done <= 1'b0;
            end
        end
    end

endmodule
