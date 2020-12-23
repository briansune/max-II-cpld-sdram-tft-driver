onerror {resume}
quietly virtual signal -install /tb_CPLD_TFT_V/DUT/tft_ctrl_inst0 { /tb_CPLD_TFT_V/DUT/tft_ctrl_inst0/col_add[1:0]} wr_case
quietly virtual signal -install /tb_CPLD_TFT_V/DUT/tft_ctrl_inst0 { /tb_CPLD_TFT_V/DUT/tft_ctrl_inst0/col_add[1:0]} col_addr_2
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix hexadecimal /tb_CPLD_TFT_V/data_buff
add wave -noupdate /tb_CPLD_TFT_V/clk
add wave -noupdate /tb_CPLD_TFT_V/RST
add wave -noupdate -radix hexadecimal /tb_CPLD_TFT_V/DATA
add wave -noupdate /tb_CPLD_TFT_V/CS
add wave -noupdate /tb_CPLD_TFT_V/RS
add wave -noupdate /tb_CPLD_TFT_V/WR
add wave -noupdate /tb_CPLD_TFT_V/RD
add wave -noupdate /tb_CPLD_TFT_V/PWM
add wave -noupdate -radix hexadecimal /tb_CPLD_TFT_V/R
add wave -noupdate -radix hexadecimal /tb_CPLD_TFT_V/G
add wave -noupdate -radix hexadecimal /tb_CPLD_TFT_V/B
add wave -noupdate -radix hexadecimal /tb_CPLD_TFT_V/DUT/tft_ctrl_inst0/rd_data
add wave -noupdate /tb_CPLD_TFT_V/DUT/tft_ctrl_inst0/addr_cnt_a
add wave -noupdate /tb_CPLD_TFT_V/DUT/tft_ctrl_inst0/rd_enable_a
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
add wave -noupdate -color {Cadet Blue} /tb_CPLD_TFT_V/DUT/tft_ctrl_inst0/busy
add wave -noupdate /tb_CPLD_TFT_V/dqm
add wave -noupdate /tb_CPLD_TFT_V/DUT/tft_ctrl_inst0/dump_data_case
add wave -noupdate /tb_CPLD_TFT_V/DUT/tft_ctrl_inst0/data_user_wr
add wave -noupdate /tb_CPLD_TFT_V/DUT/tft_ctrl_inst0/data_user_rd
add wave -noupdate /tb_CPLD_TFT_V/DUT/USER_ctrl_inst0/startup_inc
add wave -noupdate /tb_CPLD_TFT_V/DUT/tft_ctrl_inst0/rd_enable_a
add wave -noupdate /tb_CPLD_TFT_V/DUT/tft_ctrl_inst0/user_rd_en
add wave -noupdate -color Cyan /tb_CPLD_TFT_V/DUT/tft_ctrl_inst0/FIFO_full
add wave -noupdate /tb_CPLD_TFT_V/DUT/tft_ctrl_inst0/wr_enable
add wave -noupdate /tb_CPLD_TFT_V/DUT/tft_ctrl_inst0/dclk_clken
add wave -noupdate /tb_CPLD_TFT_V/DUT/tft_ctrl_inst0/col_addr_2
add wave -noupdate -radix hexadecimal /tb_CPLD_TFT_V/DUT/tft_ctrl_inst0/FIFO_out
add wave -noupdate /tb_CPLD_TFT_V/DUT/tft_ctrl_inst0/FIFO_RD_req
add wave -noupdate -radix unsigned -childformat {{{/tb_CPLD_TFT_V/DUT/USER_ctrl_inst0/row_add[8]} -radix unsigned} {{/tb_CPLD_TFT_V/DUT/USER_ctrl_inst0/row_add[7]} -radix unsigned} {{/tb_CPLD_TFT_V/DUT/USER_ctrl_inst0/row_add[6]} -radix unsigned} {{/tb_CPLD_TFT_V/DUT/USER_ctrl_inst0/row_add[5]} -radix unsigned} {{/tb_CPLD_TFT_V/DUT/USER_ctrl_inst0/row_add[4]} -radix unsigned} {{/tb_CPLD_TFT_V/DUT/USER_ctrl_inst0/row_add[3]} -radix unsigned} {{/tb_CPLD_TFT_V/DUT/USER_ctrl_inst0/row_add[2]} -radix unsigned} {{/tb_CPLD_TFT_V/DUT/USER_ctrl_inst0/row_add[1]} -radix unsigned} {{/tb_CPLD_TFT_V/DUT/USER_ctrl_inst0/row_add[0]} -radix unsigned}} -subitemconfig {{/tb_CPLD_TFT_V/DUT/USER_ctrl_inst0/row_add[8]} {-height 15 -radix unsigned} {/tb_CPLD_TFT_V/DUT/USER_ctrl_inst0/row_add[7]} {-height 15 -radix unsigned} {/tb_CPLD_TFT_V/DUT/USER_ctrl_inst0/row_add[6]} {-height 15 -radix unsigned} {/tb_CPLD_TFT_V/DUT/USER_ctrl_inst0/row_add[5]} {-height 15 -radix unsigned} {/tb_CPLD_TFT_V/DUT/USER_ctrl_inst0/row_add[4]} {-height 15 -radix unsigned} {/tb_CPLD_TFT_V/DUT/USER_ctrl_inst0/row_add[3]} {-height 15 -radix unsigned} {/tb_CPLD_TFT_V/DUT/USER_ctrl_inst0/row_add[2]} {-height 15 -radix unsigned} {/tb_CPLD_TFT_V/DUT/USER_ctrl_inst0/row_add[1]} {-height 15 -radix unsigned} {/tb_CPLD_TFT_V/DUT/USER_ctrl_inst0/row_add[0]} {-height 15 -radix unsigned}} /tb_CPLD_TFT_V/DUT/USER_ctrl_inst0/row_add
add wave -noupdate -radix unsigned /tb_CPLD_TFT_V/DUT/USER_ctrl_inst0/col_add
add wave -noupdate /tb_CPLD_TFT_V/DUT/tft_ctrl_inst0/startup
add wave -noupdate -radix unsigned -childformat {{{/tb_CPLD_TFT_V/DUT/tft_ctrl_inst0/col_add[9]} -radix unsigned} {{/tb_CPLD_TFT_V/DUT/tft_ctrl_inst0/col_add[8]} -radix unsigned} {{/tb_CPLD_TFT_V/DUT/tft_ctrl_inst0/col_add[7]} -radix unsigned} {{/tb_CPLD_TFT_V/DUT/tft_ctrl_inst0/col_add[6]} -radix unsigned} {{/tb_CPLD_TFT_V/DUT/tft_ctrl_inst0/col_add[5]} -radix unsigned} {{/tb_CPLD_TFT_V/DUT/tft_ctrl_inst0/col_add[4]} -radix unsigned} {{/tb_CPLD_TFT_V/DUT/tft_ctrl_inst0/col_add[3]} -radix unsigned} {{/tb_CPLD_TFT_V/DUT/tft_ctrl_inst0/col_add[2]} -radix unsigned} {{/tb_CPLD_TFT_V/DUT/tft_ctrl_inst0/col_add[1]} -radix unsigned} {{/tb_CPLD_TFT_V/DUT/tft_ctrl_inst0/col_add[0]} -radix unsigned}} -subitemconfig {{/tb_CPLD_TFT_V/DUT/tft_ctrl_inst0/col_add[9]} {-height 15 -radix unsigned} {/tb_CPLD_TFT_V/DUT/tft_ctrl_inst0/col_add[8]} {-height 15 -radix unsigned} {/tb_CPLD_TFT_V/DUT/tft_ctrl_inst0/col_add[7]} {-height 15 -radix unsigned} {/tb_CPLD_TFT_V/DUT/tft_ctrl_inst0/col_add[6]} {-height 15 -radix unsigned} {/tb_CPLD_TFT_V/DUT/tft_ctrl_inst0/col_add[5]} {-height 15 -radix unsigned} {/tb_CPLD_TFT_V/DUT/tft_ctrl_inst0/col_add[4]} {-height 15 -radix unsigned} {/tb_CPLD_TFT_V/DUT/tft_ctrl_inst0/col_add[3]} {-height 15 -radix unsigned} {/tb_CPLD_TFT_V/DUT/tft_ctrl_inst0/col_add[2]} {-height 15 -radix unsigned} {/tb_CPLD_TFT_V/DUT/tft_ctrl_inst0/col_add[1]} {-height 15 -radix unsigned} {/tb_CPLD_TFT_V/DUT/tft_ctrl_inst0/col_add[0]} {-height 15 -radix unsigned}} /tb_CPLD_TFT_V/DUT/tft_ctrl_inst0/col_add
add wave -noupdate -radix unsigned /tb_CPLD_TFT_V/DUT/tft_ctrl_inst0/row_add
add wave -noupdate -radix hexadecimal /tb_CPLD_TFT_V/DUT/tft_ctrl_inst0/sdram_ctrl1/rd_data_r
add wave -noupdate -radix unsigned /tb_CPLD_TFT_V/DUT/USER_ctrl_inst0/col_add_E
add wave -noupdate -radix unsigned /tb_CPLD_TFT_V/DUT/USER_ctrl_inst0/col_add_S
add wave -noupdate -radix unsigned /tb_CPLD_TFT_V/DUT/USER_ctrl_inst0/row_add_E
add wave -noupdate -radix unsigned /tb_CPLD_TFT_V/DUT/USER_ctrl_inst0/row_add_S
add wave -noupdate -radix hexadecimal /tb_CPLD_TFT_V/DUT/tft_ctrl_inst0/sdram_ctrl1/rd_data_r
add wave -noupdate -radix unsigned /tb_CPLD_TFT_V/DUT/tft_ctrl_inst0/TH
add wave -noupdate -radix unsigned /tb_CPLD_TFT_V/DUT/tft_ctrl_inst0/TV
add wave -noupdate -divider user_ctrl
add wave -noupdate /tb_CPLD_TFT_V/DUT/USER_ctrl_inst0/FIFO_WR_req
add wave -noupdate -radix hexadecimal /tb_CPLD_TFT_V/DUT/USER_ctrl_inst0/sdram_rq_data
add wave -noupdate -radix hexadecimal /tb_CPLD_TFT_V/DUT/USER_ctrl_inst0/data_inout
add wave -noupdate -radix hexadecimal /tb_CPLD_TFT_V/DUT/USER_ctrl_inst0/data_out_buff
add wave -noupdate /tb_CPLD_TFT_V/DUT/tft_ctrl_inst0/sdram_rd_type
add wave -noupdate -radix hexadecimal /tb_CPLD_TFT_V/DUT/tft_ctrl_inst0/sdram_ctrl1/rd_data_r
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {3393645000 ps} 0}
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
WaveRestoreZoom {3392399408 ps} {3394160592 ps}
