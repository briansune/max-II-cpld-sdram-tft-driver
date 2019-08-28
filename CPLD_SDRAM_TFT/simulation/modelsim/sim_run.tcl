restart

run 10ns

mem load -filltype rand -filldata 0 -fillradix symbolic -skip 0 /tb_CPLD_TFT_V/sdram_model/Bank0
mem load -filltype rand -filldata 0 -fillradix symbolic -skip 0 /tb_CPLD_TFT_V/sdram_model/Bank1
mem load -filltype rand -filldata 0 -fillradix symbolic -skip 0 /tb_CPLD_TFT_V/sdram_model/Bank2
mem load -filltype rand -filldata 0 -fillradix symbolic -skip 0 /tb_CPLD_TFT_V/sdram_model/Bank3

run 3803105 ns

