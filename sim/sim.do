#*****************************************************************
# Title    : Tang-Nano 100BASE-FX Talker ModelSim script
# Date     : 2020/09/20
# Design   : kingyo
#*****************************************************************
vlib work
vmap work work

vlog \
    -L work \
    -l vlog.log \
    -work work \
    -timescale "1ns / 1ps"  \
    -f filelist.txt

vsim tb_top -wlf vsim.wlf -wlfcachesize 512

### tb_top
add wave -r sim:/tb_top/r_gsr
add wave -r sim:/tb_top/r_mco
add wave -r sim:/tb_top/r_res_n
add wave -r sim:/tb_top/r_btn_b
add wave -r sim:/tb_top/w_sfp_tx
add wave -r sim:/tb_top/w_adc_cmp

### dut
add wave -r sim:/tb_top/dut/clk125m
add wave -r sim:/tb_top/dut/clk25m
add wave -r sim:/tb_top/dut/w_pll_lock
add wave -r sim:/tb_top/dut/w_res_n
add wave -r sim:/tb_top/dut/w_adc_val
add wave -r sim:/tb_top/dut/w_adc_done
add wave -r sim:/tb_top/dut/w_mii_clk
add wave -r sim:/tb_top/dut/w_mii_tx_en
add wave -r sim:/tb_top/dut/w_mii_txd

### ethernetFrameGen
add wave -r sim:/tb_top/dut/ethernetFrameGen/w_crc_out

radix hex

run 200000ns
WaveRestoreZoom {0ns} {200000ns}
