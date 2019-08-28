module TFT_ctrl(
	
	input clk, rst,
	
	/* TFT Hardware IO */
	output [5:0] R, G, B,
	output reg DCLK, DE,

	/* SDRAM Hardware IO */
	output [11:0] addr,
	output [1:0] bank_addr,
	inout [15:0] data,
	output clock_enable,
	output cs_n,
	output ras_n,
	output cas_n,
	output we_n,
	output data_mask_low,
	output data_mask_high,
	
	input [2:0] page_show,
	input [2:0] page_set,
	
	input [8:0] row_add_user,
	input [9:0] col_add_user,
	output reg startup_inc,
	
	output reg FIFO_RD_req,
	input FIFO_full,
	input [15:0] FIFO_out,
	
	input startup
);
	
	////////////////////////////////////////////////////////
	//	registers
	////////////////////////////////////////////////////////
		
		//////////////////////////////////
		//	TFT
		//////////////////////////////////
	reg wr_enable_start;
	reg wr_enable_user;
	
		//////////////////////////////////
		//	SDRAM
		//////////////////////////////////
	reg rd_enable;
	
		//////////////////////////////////
		//	User
		//////////////////////////////////
	wire [8:0] row_add;
	wire [9:0] col_add;
	
	////////////////////////////////////////////////////////
	//	wires
	////////////////////////////////////////////////////////
	
	wire [1:0] clk_33m;
	wire [10:0] TH;
	wire [9:0] TV;
	
	wire dclk_rst;
	
		//////////////////////////////////
		//	SDRAM
		//////////////////////////////////
	wire [21:0] wr_addr;
	wire [15:0] wr_data;
	wire wr_enable;
	
	wire [21:0] rd_addr;
	wire [15:0] rd_data;
	wire rd_ready;
	wire busy;
	
	wire data_user;
	
	wire dump_TV_case1;
	wire dump_TH_case1;
	wire dump_TH_case2;
	wire dump_data_inc1;
	wire dump_data_inc2;
	wire dump_data_case;
	
	wire col_cnt_full;
	wire row_cnt_en;
	
	wire wr_addr_inc;
	
	////////////////////////////////////////////////////////
	//	instantiation
	////////////////////////////////////////////////////////
		
		//////////////////////////////////
		//	SDRAM
		//////////////////////////////////
	sdram_controller sdram_ctrl1(
		
		.rst_n(rst),
		.clk(clk),
		
		.wr_addr(wr_addr),
		.wr_data(wr_data),
		.wr_enable(wr_enable),
		.wr_addr_inc(wr_addr_inc),
		
		.rd_addr(rd_addr),
		.rd_data(rd_data),
		.rd_ready(rd_ready),
		.rd_enable(rd_enable),
		.busy(busy),
		
		/* SDRAM SIDE */
		.addr(addr),
		.bank_addr(bank_addr),
		.data(data),
		.clken(clock_enable),
		.cs_n(cs_n),
		.ras_n(ras_n),
		.cas_n(cas_n),
		.we_n(we_n),
		.data_mask_low(data_mask_low),
		.data_mask_high(data_mask_high)
	);
	
	////////////////////////////////////////////////////////
	//	assignments
	////////////////////////////////////////////////////////
	assign wr_addr = {page_set, row_add_user, col_add_user};
	assign rd_addr = {page_show, row_add, col_add};
	
	assign {R,G,B} = {rd_data[15:11],rd_data[15],rd_data[10:5],rd_data[4:0],rd_data[4]};
	
	assign dump_TV_case1 = ( (TV[8 : 0] >= 9'd23) & (TV[8 : 0] < 9'd503) ) ? 1'b1 : 1'b0;
	
	assign dump_TH_case1 = ( (TH[9 : 0] >= 10'd44) & (TH[9 : 0] < 10'd844) ) ? 1'b1 : 1'b0;
	assign dump_TH_case2 = ( (TH[9 : 0] >= 10'd45) & (TH[9 : 0] < 10'd845) ) ? 1'b1 : 1'b0;
	
	assign dump_data_inc1 = (dump_TV_case1 & dump_TH_case1) ? 1'b1 : 1'b0;
	assign dump_data_inc2 = (dump_TV_case1 & dump_TH_case2) ? 1'b1 : 1'b0;
	
	//assign dump_data_case = ( (TH[9 : 0] < 10'd43) ^ (TH[9 : 0] > 10'd847)) ? 1'b1 : 1'b0;
	assign dump_data_case = (TH[9 : 0] < 10'd43) ? 1'b1 : 1'b0;
	
	assign data_user = (dump_data_case & FIFO_full & startup);
	
	assign wr_enable = (startup) ? wr_enable_user : wr_enable_start;
	
	assign wr_data = FIFO_out;
	
	assign row_cnt_en = col_cnt_full & rd_ready;
	
	always@(posedge clk or negedge rst)begin
		if(!rst)begin
			startup_inc <= 1'b0;
		end else begin
			if(wr_addr_inc & wr_enable)begin
				startup_inc <= 1'b1;
			end else begin
				startup_inc <= 1'b0;
			end
		end
	end
	
	////////////////////////////////////////////////////////
	//	clocked combinational logic
	////////////////////////////////////////////////////////
	always@(posedge clk or negedge rst)begin
		if(!rst)begin
			wr_enable_user <= 1'b0;
			FIFO_RD_req <= 1'b0;
		end else begin
			if(data_user)begin
				
				if(startup_inc)begin
					FIFO_RD_req <= 1'b1;
				end
				
				wr_enable_user <= 1'b1;
				
			end else begin
				FIFO_RD_req <= 1'b0;
				wr_enable_user <= 1'b0;
			end
		end
	end
	
	always@(posedge clk or negedge rst)begin
		if(!rst)begin
			wr_enable_start <= 1'b0;
		end else begin
			if(!startup)begin
				if(!busy)begin
					wr_enable_start <= 1'b1;
				end
			end else begin
				wr_enable_start <= 1'b0;
			end
		end
	end
	
	tft_row_cnt tft_row_cnt_inst0(
		.aclr(~rst),				// input  aclr_sig
		.clock(clk),				// input  clock_sig
		.cnt_en(row_cnt_en),		// input  cnt_en_sig
		.q(row_add) 				// output [8:0] q_sig
	);
	
	tft_col_cnt tft_col_cnt_inst0(
		.aclr(~rst),				// input  aclr_sig
		.clock(clk),				// input  clock_sig
		.cnt_en(rd_ready),			// input  cnt_en_sig
		.cout(col_cnt_full),		// output  cout_sig
		.q(col_add)					// output [9:0] q_sig
	);
	
	/* Dump Data From SDRAM to TFT */
	always@(posedge DCLK or negedge rst)begin
		if(!rst)begin
			rd_enable <= 1'b0;
		end else begin
			if(dump_data_inc1)begin
				rd_enable <= 1'b1;
			end else begin
				rd_enable <= 1'b0;
			end
		end
	end
	
	/* Clock divider for 33.3MHz */
	always@(posedge clk or negedge rst)begin
		
		if(!rst)begin
			DCLK <= 1'b1;
		end else begin
			if(dclk_rst)begin
				DCLK <= ~DCLK;
			end
		end
	end
	
	dclk_cnt dclk_cnt_inst(
		.aclr(~rst),			// input  aset_sig
		.clk_en(startup),		// input  clk_en_sig
		.clock(clk),			// input  clock_sig
		.cout(dclk_rst),		// output  cout_sig
		.q(clk_33m)				// output [1:0] q_sig
	);
	
	/* TFT Hsync Vsync control */
	hsync_cnt hsync_cnt_inst(
		
		.aset(~rst),		// input  aclr_sig
		.clk_en(1'b1),		// input  clk_en_sig
		.clock(DCLK),		// input  clock_sig
		.sclr(TH[10]),		// input  sclr_sig
		.cout(TH[10]),		// output  cout_sig
		.q(TH[9:0])			// output [9:0] q_sig
	);
	
	vsync_cnt vsync_cnt_inst(	
		
		.aset(~rst),		// input  aset_sig
		.clk_en(TH[10]),	// input  clk_en_sig
		.clock(DCLK),		// input  clock_sig
		.sclr(TV[9]),		// input  sclr_sig
		.cout(TV[9]),		// output  cout_sig
		.q(TV[8:0])			// output [8:0] q_sig
	);
	
	/* TFT Hsync Vsync control */
	always@(posedge DCLK or negedge rst)begin
		
		if(!rst)begin
			DE <= 1'b0;
		end else begin
			if(dump_data_inc2)begin
				DE <= 1'b1;
			end else begin
				DE <= 1'b0;
			end
		end
	end
	
endmodule
