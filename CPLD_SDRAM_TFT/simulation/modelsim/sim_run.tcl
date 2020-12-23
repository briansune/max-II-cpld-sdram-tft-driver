delete wave Wave *
do sim_wave.do
restart

run 10ns

#mem load -filltype rand -filldata 0 -fillradix symbolic -skip 0 /tb_CPLD_TFT_V/sdram_model/Bank0
#mem load -filltype rand -filldata 0 -fillradix symbolic -skip 0 /tb_CPLD_TFT_V/sdram_model/Bank1
#mem load -filltype rand -filldata 0 -fillradix symbolic -skip 0 /tb_CPLD_TFT_V/sdram_model/Bank2
#mem load -filltype rand -filldata 0 -fillradix symbolic -skip 0 /tb_CPLD_TFT_V/sdram_model/Bank3


#mem load -filltype inc -filldata 0 -fillradix hexadecimal -skip 0 /tb_CPLD_TFT_V/sdram_model/Bank0
#mem load -filltype inc -filldata 0 -fillradix hexadecimal -skip 0 /tb_CPLD_TFT_V/sdram_model/Bank1
#mem load -filltype inc -filldata 0 -fillradix hexadecimal -skip 0 /tb_CPLD_TFT_V/sdram_model/Bank2
#mem load -filltype inc -filldata 0 -fillradix hexadecimal -skip 0 /tb_CPLD_TFT_V/sdram_model/Bank3

mem load -filltype value -filldata zzzz -fillradix hexadecimal -skip 0 /tb_CPLD_TFT_V/sdram_model/Bank0
mem load -filltype value -filldata zzzz -fillradix hexadecimal -skip 0 /tb_CPLD_TFT_V/sdram_model/Bank1
mem load -filltype value -filldata zzzz -fillradix hexadecimal -skip 0 /tb_CPLD_TFT_V/sdram_model/Bank2
mem load -filltype value -filldata zzzz -fillradix hexadecimal -skip 0 /tb_CPLD_TFT_V/sdram_model/Bank3

run 3400582 ns
run 34552 ns

