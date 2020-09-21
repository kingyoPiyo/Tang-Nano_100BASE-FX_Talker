//Copyright (C)2014-2019 GOWIN Semiconductor Corporation.
//All rights reserved.
//File Title: Timing Constraints file
//GOWIN Version: 1.9.2.02 Beta
//Created Time: 2019-12-25 22:24:03
#**************************************************************
# Time Information
#**************************************************************



#**************************************************************
# Create Clock
#**************************************************************
create_clock -period 20.000 -waveform {0.000 10.000} -name mco [get_ports {mco}]
create_generated_clock -name clk125m -source [get_ports {mco}] -master_clock mco -divide_by 2 -multiply_by 5 [get_nets {clk125m}]
create_generated_clock -name clk25m -source [get_ports {mco}] -master_clock mco -divide_by 2 -multiply_by 1 [get_nets {clk25m}]


#**************************************************************
# Set Input Delay
#**************************************************************


#**************************************************************
# Set Output Delay
#**************************************************************


#**************************************************************
# Set Clock Groups
#**************************************************************


#**************************************************************
# Set False Path
#**************************************************************
set_false_path -from [get_ports {res_n}]
set_false_path -from [get_ports {btn_b}]

set_false_path -to   [get_ports {onb_led_r}]

set_false_path -from [get_ports {sfp_los}]
set_false_path -from [get_ports {sfp_rx}]
set_false_path -to   [get_ports {sfp_tx}]
