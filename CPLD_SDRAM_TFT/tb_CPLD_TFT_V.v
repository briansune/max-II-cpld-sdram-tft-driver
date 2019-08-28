`timescale 1ns / 1ns

module tb_CPLD_TFT_V;

	reg [15:0] data_buff;
	wire [15:0] input_value;

	reg clk, RST;
	wire [15:0] DATA;
	reg WR, CS, RS, RD;
	wire PWM;
	wire [5:0] R, G, B;
	wire DCLK, LR, UD, DTB, HS, VS, DE;
	
	/* SDRAM Hardware IO */
	wire [11:0] addr;
	wire [1:0] bank_addr;
	wire [15:0] SDRAM_data;
	wire clock_enable;
	wire cs_n;
	wire ras_n;
	wire cas_n;
	wire we_n;
	wire [1 : 0] dqm;
	wire SDRAM_CLK;
	
	CPLD_TFT_V DUT(
		.clk(clk),		// input  clk_sig
		.RST(RST),		// input  RST_sig
		.DATA(DATA),	// inout [15:0] DATA_sig
		.WR(WR),		// input  WR_sig
		.CS(CS),		// input  CS_sig
		.RS(RS),		// input  RS_sig
		.RD(RD),		// input  RD_sig
		.PWM(PWM),		// output  PWM_sig
		.R(R),			// output [5:0] R_sig
		.G(G),			// output [5:0] G_sig
		.B(B),			// output [5:0] B_sig
		.DCLK(DCLK),	// output  DCLK_sig
		.LR(LR),		// output  LR_sig
		.UD(UD),		// output  UD_sig
		.DTB(DTB),		// output  DTB_sig
		.HS(HS),		// output  HS_sig
		.VS(VS),		// output  VS_sig
		.DE(DE),		// output  DE_sig
		
		.addr(addr),					// output [11:0] addr_sig
		.bank_addr(bank_addr),			// output [1:0] bank_addr_sig
		.SDRAM_data(SDRAM_data),		// inout [15:0] SDRAM_data_sig
		.clock_enable(clock_enable),	// output  clock_enable_sig
		.cs_n(cs_n),		// output  cs_n_sig
		.ras_n(ras_n),		// output  ras_n_sig
		.cas_n(cas_n),		// output  cas_n_sig
		.we_n(we_n),		// output  we_n_sig
		.data_mask_low(dqm[0]),		// output  data_mask_low_sig
		.data_mask_high(dqm[1]),	// output  data_mask_high_sig
		.SDRAM_CLK(SDRAM_CLK) 		// output  SDRAM_CLK_sig
	);
	
	sdr sdram_model(
		.Dq(SDRAM_data),
		.Addr(addr),
		.Ba(bank_addr),
		.Clk(SDRAM_CLK),
		.Cke(clock_enable),
		.Cs_n(cs_n),
		.Ras_n(ras_n),
		.Cas_n(cas_n),
		.We_n(we_n),
		.Dqm(dqm)
	);
	
	integer i;
	
	always begin
		#5 clk = ~clk;	//产生50MHz的时钟
	end
	
	initial begin
		clk = 1'b0;
		RST = 1'b0;
		WR = 1'b1;
		CS = 1'b1;
		RS = 1'b1;
		RD = 1'b1;
		data_buff = 0;
		
		fork begin
			#150 RST = 1'b1;
			
			#150 CS = 1'b0;
			#150 RS = 1'b0;
			/* PWM Regisiter */
			#150 data_buff = 16'h0001;
			#150 WR = 1'b0;
			#150 WR = 1'b1;
			
			#150 RS = 1'b1;
			/* PWM 0-15 value */
			#150 data_buff = 16'h0002;
			#150 WR = 1'b0;
			#150 WR = 1'b1;
			#150 CS = 1'b1;
			
			#31661550 CS = 1'b0;
			#150 RS = 1'b0;
			/* TFT_CMD_Row_Add_E */
			#150 data_buff = 16'h0006;
			#150 WR = 1'b0;
			#150 WR = 1'b1;
			
			#150 RS = 1'b1;
			#150 data_buff = 16'd479;
			#150 WR = 1'b0;
			#150 WR = 1'b1;
			#150 CS = 1'b1;
			
			#150 CS = 1'b0;
			#150 RS = 1'b0;
			/* TFT_CMD_Col_Add_E */
			#150 data_buff = 16'h0007;
			#150 WR = 1'b0;
			#150 WR = 1'b1;
			
			#150 RS = 1'b1;
			#150 data_buff = 16'd799;
			#150 WR = 1'b0;
			#150 WR = 1'b1;
			#150 CS = 1'b1;
			
			
			#150 CS = 1'b0;
			#150 RS = 1'b0;
			/* TFT_CMD_Row_Add_S */
			#150 data_buff = 16'h0002;
			#150 WR = 1'b0;
			#150 WR = 1'b1;
			
			#150 RS = 1'b1;
			#150 data_buff = 16'd470;
			#150 WR = 1'b0;
			#150 WR = 1'b1;
			#150 CS = 1'b1;
			
			#150 CS = 1'b0;
			#150 RS = 1'b0;
			/* TFT_CMD_Col_Add_S */
			#150 data_buff = 16'h0003;
			#150 WR = 1'b0;
			#150 WR = 1'b1;
			
			#150 RS = 1'b1;
			#150 data_buff = 16'd790;
			#150 WR = 1'b0;
			#150 WR = 1'b1;
			#150 CS = 1'b1;
			
			#200 CS = 1'b0;
			#150 RS = 1'b0;
			/* TFT_CMD_Col_Add_E */
			#150 data_buff = 16'h000F;
			#150 WR = 1'b0;
			#150 WR = 1'b1;
			
			
			#150 RS = 1'b1;
			
			for(i=0; i<100000; i=i+1)begin
				#(93) data_buff = (16'h001F+i);
				#(102) WR = 1'b0;
				#(93) WR = 1'b1;
			end
			
			#700 CS = 1'b1;
			
		end join
	end
	
	assign DATA = data_buff;

endmodule
