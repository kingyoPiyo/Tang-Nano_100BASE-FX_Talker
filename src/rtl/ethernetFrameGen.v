/*****************************************************************
* Title     : Ethernet Frame Generator (UDP)
* Date      : 2020/09/20
* Design    : kingyo
* Reference : https://www.fpga4fun.com/10BASE-T.html
******************************************************************/
module ethernetFrameGen (
    input   wire            i_clk,          // 25MHz
    input   wire            i_res_n,        // Reset
    input   wire            i_tx_trig,      // Tx Trig(Positive 1clk pulse)
    input   wire    [31:0]  i_tx_data,      // UDP Payload
    // MII I/F
    output  wire            o_mii_tx_clk,   // MII TX_CLK
    output  wire            o_mii_tx_en,    // MII TX_EN
    output  wire    [3:0]   o_mii_txd       // MII TXD
);

    // "Ethernet Frame"
    parameter EtherDestinationMAC   = 48'hFFFFFFFFFFFF; // >>Danger!<< Change for your computer MAC.
    parameter EtherSourceMAC        = 48'h123456789ABC; // dummy
    parameter EtherType             = 16'h0800; // (08 00 = IP)
    // "UDP Header"
    parameter UDPsourcePortNum      = 16'd1024;
    parameter UDPdestinationPortNum = 16'd1024;
    parameter UDPlength             = 16'd26;   // UDP Header(8) + Payload(18)[Octet]
    parameter UDPchecksum           = 16'd0;    // not use
    // "IPv4 Header"
    parameter IPversion             = 4'd4;     // IP
    parameter IPIHL                 = 4'd5;     // no option
    parameter IPtypeOfService       = 8'h0;
    parameter IPtotalLength         = 16'd20 + UDPlength;   // IPHeader(20) + IPData[Octet]
    // IP source - put an unused IP
    parameter IPsource_1            = 8'd192;
    parameter IPsource_2            = 8'd168;
    parameter IPsource_3            = 8'd37;
    parameter IPsource_4            = 8'd24;
    // IP destination - put the IP of the PC you want to send to
    parameter IPdestination_1       = 8'd192;
    parameter IPdestination_2       = 8'd168;
    parameter IPdestination_3       = 8'd37;
    parameter IPdestination_4       = 8'd20;
    // calculate the IP checksum, big-endian style
    parameter IPchecksum1 = 32'h0000C53F + (IPsource_1 << 8) + IPsource_2 + (IPsource_3 << 8) + IPsource_4 + 
                            (IPdestination_1 << 8) + IPdestination_2 + (IPdestination_3 << 8) + (IPdestination_4);
    parameter IPchecksum2 =  ((IPchecksum1 & 32'h0000FFFF) + (IPchecksum1 >> 16));
    parameter IPchecksum3 = ~((IPchecksum2 & 32'h0000FFFF) + (IPchecksum2 >> 16));

    reg     [ 3:0]  r_4b_data;
    reg             r_tx_en;
    reg             r_busy;
    reg     [ 7:0]  r_state;
    always @(posedge i_clk or negedge i_res_n) begin
        if (~i_res_n) begin
            r_4b_data <= 4'd0;
            r_tx_en <= 1'b0;
            r_busy <= 1'b0;
            r_state <= 8'd0;
        end else begin
            if (i_tx_trig & ~r_busy) begin
                r_busy <= 1'b1;
                r_state <= 8'd0;
            end else if (r_busy) begin
                r_state <= r_state + 8'd1;
                case (r_state)
                    8'd0: begin
                        r_tx_en <= 1'b1;
                        r_4b_data <= 4'h5;      // Preamble
                    end
                    8'd15: r_4b_data <= 4'hD;   // SFD
                    // Destination MAC Address
                    8'd16: r_4b_data <= EtherDestinationMAC[43:40];
                    8'd17: r_4b_data <= EtherDestinationMAC[47:44];
                    8'd18: r_4b_data <= EtherDestinationMAC[35:32];
                    8'd19: r_4b_data <= EtherDestinationMAC[39:36];
                    8'd20: r_4b_data <= EtherDestinationMAC[27:24];
                    8'd21: r_4b_data <= EtherDestinationMAC[31:28];
                    8'd22: r_4b_data <= EtherDestinationMAC[19:16];
                    8'd23: r_4b_data <= EtherDestinationMAC[23:20];
                    8'd24: r_4b_data <= EtherDestinationMAC[11:8];
                    8'd25: r_4b_data <= EtherDestinationMAC[15:12];
                    8'd26: r_4b_data <= EtherDestinationMAC[3:0];
                    8'd27: r_4b_data <= EtherDestinationMAC[7:4];
                    // Source MAC Address
                    8'd28: r_4b_data <= EtherSourceMAC[43:40];
                    8'd29: r_4b_data <= EtherSourceMAC[47:44];
                    8'd30: r_4b_data <= EtherSourceMAC[35:32];
                    8'd31: r_4b_data <= EtherSourceMAC[39:36];
                    8'd32: r_4b_data <= EtherSourceMAC[27:24];
                    8'd33: r_4b_data <= EtherSourceMAC[31:28];
                    8'd34: r_4b_data <= EtherSourceMAC[19:16];
                    8'd35: r_4b_data <= EtherSourceMAC[23:20];
                    8'd36: r_4b_data <= EtherSourceMAC[11:8];
                    8'd37: r_4b_data <= EtherSourceMAC[15:12];
                    8'd38: r_4b_data <= EtherSourceMAC[3:0];
                    8'd39: r_4b_data <= EtherSourceMAC[7:4];
                    // Ethernet Type
                    8'd40: r_4b_data <= EtherType[11:8];
                    8'd41: r_4b_data <= EtherType[15:12];
                    8'd42: r_4b_data <= EtherType[3:0];
                    8'd43: r_4b_data <= EtherType[7:4];
                    // IP Header
                    8'd44: r_4b_data <= IPIHL[3:0];
                    8'd45: r_4b_data <= IPversion[3:0];
                    8'd46: r_4b_data <= IPtypeOfService[3:0];
                    8'd47: r_4b_data <= IPtypeOfService[7:4];
                    8'd48: r_4b_data <= IPtotalLength[11:8];
                    8'd49: r_4b_data <= IPtotalLength[15:12];
                    8'd50: r_4b_data <= IPtotalLength[3:0];
                    8'd51: r_4b_data <= IPtotalLength[7:4];
                    8'd52: r_4b_data <= 4'h0;
                    8'd53: r_4b_data <= 4'h0;
                    8'd54: r_4b_data <= 4'h0;
                    8'd55: r_4b_data <= 4'h0;
                    8'd56: r_4b_data <= 4'h0;
                    8'd57: r_4b_data <= 4'h0;
                    8'd58: r_4b_data <= 4'h0;
                    8'd59: r_4b_data <= 4'h0;
                    8'd60: r_4b_data <= 4'h0;
                    8'd61: r_4b_data <= 4'h8;
                    8'd62: r_4b_data <= 4'h1;
                    8'd63: r_4b_data <= 4'h1;
                    // IP Check SUM
                    8'd64: r_4b_data <= IPchecksum3[11:8];
                    8'd65: r_4b_data <= IPchecksum3[15:12];
                    8'd66: r_4b_data <= IPchecksum3[3:0];
                    8'd67: r_4b_data <= IPchecksum3[7:4];
                    // IP Source
                    8'd68: r_4b_data <= IPsource_1[3:0];
                    8'd69: r_4b_data <= IPsource_1[7:4];
                    8'd70: r_4b_data <= IPsource_2[3:0];
                    8'd71: r_4b_data <= IPsource_2[7:4];
                    8'd72: r_4b_data <= IPsource_3[3:0];
                    8'd73: r_4b_data <= IPsource_3[7:4];
                    8'd74: r_4b_data <= IPsource_4[3:0];
                    8'd75: r_4b_data <= IPsource_4[7:4];
                    // IP destination
                    8'd76: r_4b_data <= IPdestination_1[3:0];
                    8'd77: r_4b_data <= IPdestination_1[7:4];
                    8'd78: r_4b_data <= IPdestination_2[3:0];
                    8'd79: r_4b_data <= IPdestination_2[7:4];
                    8'd80: r_4b_data <= IPdestination_3[3:0];
                    8'd81: r_4b_data <= IPdestination_3[7:4];
                    8'd82: r_4b_data <= IPdestination_4[3:0];
                    8'd83: r_4b_data <= IPdestination_4[7:4];
                    // UDP header
                    8'd84: r_4b_data <= UDPsourcePortNum[11:8];
                    8'd85: r_4b_data <= UDPsourcePortNum[15:12];
                    8'd86: r_4b_data <= UDPsourcePortNum[3:0];
                    8'd87: r_4b_data <= UDPsourcePortNum[7:4];
                    8'd88: r_4b_data <= UDPdestinationPortNum[11:8];
                    8'd89: r_4b_data <= UDPdestinationPortNum[15:12];
                    8'd90: r_4b_data <= UDPdestinationPortNum[3:0];
                    8'd91: r_4b_data <= UDPdestinationPortNum[7:4];
                    8'd92: r_4b_data <= UDPlength[11:8];
                    8'd93: r_4b_data <= UDPlength[15:12];
                    8'd94: r_4b_data <= UDPlength[3:0];
                    8'd95: r_4b_data <= UDPlength[7:4];
                    8'd96: r_4b_data <= UDPchecksum[11:8];
                    8'd97: r_4b_data <= UDPchecksum[15:12];
                    8'd98: r_4b_data <= UDPchecksum[3:0];
                    8'd99: r_4b_data <= UDPchecksum[7:4];
                    // UDP payload(32bit + Padding112bit = 144bit)
                    8'd100: r_4b_data <= i_tx_data[27:24];
                    8'd101: r_4b_data <= i_tx_data[31:28];
                    8'd102: r_4b_data <= i_tx_data[19:16];
                    8'd103: r_4b_data <= i_tx_data[23:20];
                    8'd104: r_4b_data <= i_tx_data[11: 8];
                    8'd105: r_4b_data <= i_tx_data[15:12];
                    8'd106: r_4b_data <= i_tx_data[ 3: 0];
                    8'd107: r_4b_data <= i_tx_data[ 7: 4];
                    8'd108: r_4b_data <= 4'h0;  // Padding
                    // CRC
                    // End
                    (8'd92 + (UDPlength * 2)): begin
                        r_tx_en <= 1'b0;
                        r_busy <= 1'b0;
                    end
                endcase
            end
        end
    end

    // FCS(CRC-32) Calc
    reg             r_crc_en;
    wire    [31:0]  w_crc_out;
    always @(posedge i_clk or negedge i_res_n) begin
        if (~i_res_n) begin
            r_crc_en <= 1'b0;
        end else begin
            if (r_state == 8'd16) r_crc_en <= 1'b1;                         // CRC calc start
            if (r_state == (8'd84  + (UDPlength * 2))) r_crc_en <= 1'b0;    // CRC calc end
        end
    end
    
    crc crc (
        .CLK ( i_clk ),
        .RESET_N ( i_res_n ),
        .IN_CLR ( r_state == 8'd0 ),
        .IN_ENA ( r_crc_en ),
        .IN_DATA ( r_4b_data[3:0] ),
        .OUT_CRC ( w_crc_out[31:0] )
    );
    defparam crc.DATA_WIDTH     = 4;
    defparam crc.CRC_WIDTH      = 32;
    defparam crc.POLYNOMIAL     = 32'h04C11DB7;
    defparam crc.SEED_VAL       = 32'hFFFFFFFF;
    defparam crc.OUTPUT_EXOR    = 32'hFFFFFFFF;

    // OUTPUT
    assign o_mii_txd = (r_state == (8'd85 + (UDPlength * 2))) ? {w_crc_out[28], w_crc_out[29], w_crc_out[30], w_crc_out[31]} :
                       (r_state == (8'd86 + (UDPlength * 2))) ? {w_crc_out[24], w_crc_out[25], w_crc_out[26], w_crc_out[27]} :
                       (r_state == (8'd87 + (UDPlength * 2))) ? {w_crc_out[20], w_crc_out[21], w_crc_out[22], w_crc_out[23]} :
                       (r_state == (8'd88 + (UDPlength * 2))) ? {w_crc_out[16], w_crc_out[17], w_crc_out[18], w_crc_out[19]} :
                       (r_state == (8'd89 + (UDPlength * 2))) ? {w_crc_out[12], w_crc_out[13], w_crc_out[14], w_crc_out[15]} :
                       (r_state == (8'd90 + (UDPlength * 2))) ? {w_crc_out[ 8], w_crc_out[ 9], w_crc_out[10], w_crc_out[11]} :
                       (r_state == (8'd91 + (UDPlength * 2))) ? {w_crc_out[ 4], w_crc_out[ 5], w_crc_out[ 6], w_crc_out[ 7]} :
                       (r_state == (8'd92 + (UDPlength * 2))) ? {w_crc_out[ 0], w_crc_out[ 1], w_crc_out[ 2], w_crc_out[ 3]} :
                       r_4b_data;

    assign o_mii_tx_clk = i_clk;
    assign o_mii_tx_en = r_tx_en;

endmodule
