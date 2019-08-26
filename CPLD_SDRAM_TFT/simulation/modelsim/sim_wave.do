onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix hexadecimal /tb_CPLD_TFT_V/data_buff
add wave -noupdate -radix hexadecimal /tb_CPLD_TFT_V/input_value
add wave -noupdate /tb_CPLD_TFT_V/clk
add wave -noupdate /tb_CPLD_TFT_V/RST
add wave -noupdate -radix hexadecimal /tb_CPLD_TFT_V/DATA
add wave -noupdate /tb_CPLD_TFT_V/WR
add wave -noupdate /tb_CPLD_TFT_V/CS
add wave -noupdate /tb_CPLD_TFT_V/RS
add wave -noupdate /tb_CPLD_TFT_V/RD
add wave -noupdate /tb_CPLD_TFT_V/PWM
add wave -noupdate -radix hexadecimal /tb_CPLD_TFT_V/R
add wave -noupdate -radix hexadecimal /tb_CPLD_TFT_V/G
add wave -noupdate -radix hexadecimal /tb_CPLD_TFT_V/B
add wave -noupdate /tb_CPLD_TFT_V/DCLK
add wave -noupdate /tb_CPLD_TFT_V/LR
add wave -noupdate /tb_CPLD_TFT_V/UD
add wave -noupdate /tb_CPLD_TFT_V/DTB
add wave -noupdate /tb_CPLD_TFT_V/HS
add wave -noupdate /tb_CPLD_TFT_V/VS
add wave -noupdate /tb_CPLD_TFT_V/DE
add wave -noupdate -radix hexadecimal /tb_CPLD_TFT_V/bank_addr
add wave -noupdate -radix hexadecimal /tb_CPLD_TFT_V/addr
add wave -noupdate -radix hexadecimal /tb_CPLD_TFT_V/SDRAM_data
add wave -noupdate /tb_CPLD_TFT_V/clock_enable
add wave -noupdate /tb_CPLD_TFT_V/cs_n
add wave -noupdate /tb_CPLD_TFT_V/ras_n
add wave -noupdate /tb_CPLD_TFT_V/cas_n
add wave -noupdate /tb_CPLD_TFT_V/we_n
add wave -noupdate -radix unsigned /tb_CPLD_TFT_V/DUT/tft_ctrl_inst0/row_add
add wave -noupdate /tb_CPLD_TFT_V/DUT/tft_ctrl_inst0/busy
add wave -noupdate /tb_CPLD_TFT_V/DUT/tft_ctrl_inst0/wr_enable
add wave -noupdate /tb_CPLD_TFT_V/DUT/USER_ctrl_inst0/startup_inc
add wave -noupdate -radix unsigned /tb_CPLD_TFT_V/DUT/USER_ctrl_inst0/row_add
add wave -noupdate -radix unsigned /tb_CPLD_TFT_V/DUT/USER_ctrl_inst0/col_add
add wave -noupdate /tb_CPLD_TFT_V/DUT/tft_ctrl_inst0/startup
add wave -noupdate -radix unsigned /tb_CPLD_TFT_V/DUT/tft_ctrl_inst0/col_add
add wave -noupdate -radix unsigned /tb_CPLD_TFT_V/DUT/tft_ctrl_inst0/row_add
add wave -noupdate -radix hexadecimal /tb_CPLD_TFT_V/DUT/tft_ctrl_inst0/sdram_ctrl1/rd_data_r
add wave -noupdate -radix unsigned /tb_CPLD_TFT_V/DUT/USER_ctrl_inst0/col_add_E
add wave -noupdate -radix unsigned /tb_CPLD_TFT_V/DUT/USER_ctrl_inst0/col_add_S
add wave -noupdate -radix unsigned /tb_CPLD_TFT_V/DUT/USER_ctrl_inst0/row_add_E
add wave -noupdate -radix unsigned /tb_CPLD_TFT_V/DUT/USER_ctrl_inst0/row_add_S
add wave -noupdate -radix hexadecimal /tb_CPLD_TFT_V/DUT/tft_ctrl_inst0/sdram_ctrl1/rd_data_r
add wave -noupdate -radix unsigned /tb_CPLD_TFT_V/DUT/tft_ctrl_inst0/TH
add wave -noupdate -radix unsigned /tb_CPLD_TFT_V/DUT/tft_ctrl_inst0/TV
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {3884945000 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 184
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {3819071848 ps} {3950818152 ps}
