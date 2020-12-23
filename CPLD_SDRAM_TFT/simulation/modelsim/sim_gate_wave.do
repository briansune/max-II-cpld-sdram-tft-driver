onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix hexadecimal /tb_CPLD_TFT_V/clk
add wave -noupdate -radix hexadecimal /tb_CPLD_TFT_V/CS
add wave -noupdate -radix hexadecimal /tb_CPLD_TFT_V/DATA
add wave -noupdate -radix hexadecimal /tb_CPLD_TFT_V/data_buff
add wave -noupdate -radix hexadecimal /tb_CPLD_TFT_V/data_bus_inout
add wave -noupdate -radix hexadecimal /tb_CPLD_TFT_V/DCLK
add wave -noupdate -radix hexadecimal /tb_CPLD_TFT_V/DE
add wave -noupdate -radix hexadecimal /tb_CPLD_TFT_V/DTB
add wave -noupdate -radix hexadecimal /tb_CPLD_TFT_V/R
add wave -noupdate -radix hexadecimal /tb_CPLD_TFT_V/G
add wave -noupdate -radix hexadecimal /tb_CPLD_TFT_V/B
add wave -noupdate -radix hexadecimal /tb_CPLD_TFT_V/HS
add wave -noupdate -radix hexadecimal /tb_CPLD_TFT_V/PWM
add wave -noupdate -radix hexadecimal /tb_CPLD_TFT_V/RD
add wave -noupdate -radix hexadecimal /tb_CPLD_TFT_V/RS
add wave -noupdate -radix hexadecimal /tb_CPLD_TFT_V/RST
add wave -noupdate -radix hexadecimal /tb_CPLD_TFT_V/LR
add wave -noupdate -radix hexadecimal /tb_CPLD_TFT_V/UD
add wave -noupdate -radix hexadecimal /tb_CPLD_TFT_V/VS
add wave -noupdate -radix hexadecimal /tb_CPLD_TFT_V/WR
add wave -noupdate -radix hexadecimal /tb_CPLD_TFT_V/SDRAM_CLK
add wave -noupdate -radix hexadecimal /tb_CPLD_TFT_V/SDRAM_data
add wave -noupdate -radix hexadecimal /tb_CPLD_TFT_V/addr
add wave -noupdate -radix hexadecimal /tb_CPLD_TFT_V/bank_addr
add wave -noupdate -radix hexadecimal /tb_CPLD_TFT_V/clock_enable
add wave -noupdate -radix hexadecimal /tb_CPLD_TFT_V/cas_n
add wave -noupdate -radix hexadecimal /tb_CPLD_TFT_V/cs_n
add wave -noupdate -radix hexadecimal /tb_CPLD_TFT_V/dqm
add wave -noupdate -radix hexadecimal /tb_CPLD_TFT_V/ras_n
add wave -noupdate -radix hexadecimal /tb_CPLD_TFT_V/we_n
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {3420839154 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
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
configure wave -timelineunits us
update
WaveRestoreZoom {3196503219 ps} {3568992435 ps}
