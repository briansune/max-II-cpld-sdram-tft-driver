// Quartus II Verilog Template


module CPLD_TFT_V(
	
	/* Standard IO */
	input clk, RST,
	inout [15:0] DATA,
	input WR, CS, RS, RD,
	output PWM,
	output [5:0] R, G, B,
	output DCLK, LR, UD, DTB, HS, VS, DE,

	/* SDRAM Hardware IO */
	output [11:0] addr,
	output [1:0] bank_addr,
	inout [15:0] SDRAM_data,
	output clock_enable,
	output cs_n,
	output ras_n,
	output cas_n,
	output we_n,
	output data_mask_low,
	output data_mask_high,
	output SDRAM_CLK
);
	
	reg [14:0] startup;
	wire clk_net;
	reg startflag;
	
	wire [3:0] pwm_backlight;
	wire [2:0] page_show;
	wire [2:0] page_set;
	
	wire FIFO_full;
	wire FIFO_RD_req;
	wire FIFO_RD_ready;
	wire [15:0] FIFO_out;
	
	wire [8:0] row_add;
	wire [9:0] col_add;
	wire startup_inc;
	
	wire [13:0] bk_light_dram_rdy_cnt;
	
	tft_backlight tft_bk_lig_inst1(
		.scale(pwm_backlight),
		.pwm_match(bk_light_dram_rdy_cnt[10:7]),
		.PWM(PWM)
	);
	
	/* User Interface */
	USER_ctrl USER_ctrl_inst0(
		
		.osc_clk(clk),		// input  osc_clk_sig
		.RST(startflag),	// input  RST_sig
		
		.DATA(DATA),	// inout [15:0] DATA_sig
		.WR(WR),		// input  WR_sig
		.CS(CS),		// input  CS_sig
		.RS(RS),		// input  RS_sig
		.RD(RD),		// input  RD_sig
		.LR(LR),		// output  LR_sig
		.UD(UD),		// output  UD_sig
		.DTB(DTB),		// output  DTB_sig
		
		.pwm_backlight(pwm_backlight),		// output [3:0] pwm_backlight_sig
		.page_show(page_show),				// output [2:0] page_show_sig
		.page_set(page_set),				// output [2:0] page_set_sig
		.row_add(row_add),					// output [8:0] row_add_sig
		.col_add(col_add),					// output [9:0] col_add_sig
		
		.startup_inc(startup_inc),
		.FIFO_RD_req(FIFO_RD_req),			// input  FIFO_RD_req_sig
		.FIFO_full(FIFO_full),				// output  FIFO_full_sig
		.FIFO_data(FIFO_out)				// output [15:0] FIFO_data_sig
	);
	
	/* TFT Controller + SDRAM buffer */
	TFT_ctrl tft_ctrl_inst0(
		.clk(clk),			// input  clk_sig
		.rst(startflag),	// input  rst_sig
		
		.R(R),			// output [5:0] R_sig
		.G(G),			// output [5:0] G_sig
		.B(B),			// output [5:0] B_sig
		.DCLK(DCLK),	// output  DCLK_sig
		.HS(HS),		// output  HS_sig
		.VS(VS),		// output  VS_sig
		.DE(DE),		// output  DE_sig
		
		.addr(addr),						// output [11:0] addr_sig
		.bank_addr(bank_addr),				// output [1:0] bank_addr_sig
		.data(SDRAM_data),					// inout [15:0] data_sig
		.clock_enable(clock_enable),		// output  clock_enable_sig
		.cs_n(cs_n),						// output  cs_n_sig
		.ras_n(ras_n),						// output  ras_n_sig
		.cas_n(cas_n),						// output  cas_n_sig
		.we_n(we_n),						// output  we_n_sig
		.data_mask_low(data_mask_low),		// output  data_mask_low_sig
		.data_mask_high(data_mask_high),	// output  data_mask_high_sig
		
		.page_show(page_show),				// input [2:0] page_show_sig
		.page_set(page_set),				// input [2:0] page_set_sig
		.row_add_user(row_add),				// input [8:0] row_add_user_sig
		.col_add_user(col_add),				// input [9:0] col_add_user_sig
		.startup_inc(startup_inc),
		
		.FIFO_RD_req(FIFO_RD_req),			// output  FIFO_RD_req_sig
		.FIFO_full(FIFO_full),				// input  FIFO_full_sig
		.FIFO_out(FIFO_out)					// input [15:0] FIFO_out_sig
	);
	
	bk_light_dram_cnt bk_light_dram_cnt_inst0(
		
		.aclr(~RST),				// input  aclr_sig
		.clock(clk),				// input  clock_sig
		.q(bk_light_dram_rdy_cnt)	// output [14:0] q_sig
	);
	
	always@(posedge clk or negedge RST)begin
		if(!RST)begin
			startflag <= 1'b0;
		end else begin
			if(bk_light_dram_rdy_cnt[11] & bk_light_dram_rdy_cnt[13])begin
				startflag <= 1'b1;
			end
		end
	end
	
	assign SDRAM_CLK = ~clk;
	
endmodule
