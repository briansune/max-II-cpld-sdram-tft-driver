module TFT_ctrl(
	
	input clk, rst,
	
	/* TFT Hardware IO */
	output [5:0] R, G, B,
	output reg DCLK,
	output reg DE,
	//output reg HS,VS,

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
	reg sdram_wr_en;
	
		//////////////////////////////////
		//	SDRAM
		//////////////////////////////////
	reg rd_enable_a;
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
	
	wire TH_cout;
	//wire TV_cout;
	wire [9:0] TH;
	wire [8:0] TV;
	
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
	
	wire dump_TV_case_a;
	
	wire dump_TH_case_b;
	wire dump_data_inc;
	wire dump_data_case;
	
	wire col_cnt_full;
	wire row_cnt_en;
	
	wire wr_addr_inc;
	
	reg dclk_clken;
	wire dclken;
	
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
		.rd_enable(rd_enable_a),
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
	
	assign dump_TV_case_a = ( (TV >= 9'd23) && (TV < 9'd503) ) ? 1'b1 : 1'b0;
	assign dump_TH_case_b = ( (TH >= 10'd45) && (TH < 10'd845) ) ? 1'b1 : 1'b0;
	assign dump_data_inc = (dump_TV_case_a & dump_TH_case_b);
	
	wire in_case;
	assign in_case = (!col_add[0] & col_add[1]) & ~dclk_clken;
	
	assign dump_data_case = (TH < 10'd43) | (TH > 10'd847) | (rd_enable & in_case) | !dump_TV_case_a ? 1'b1 : 1'b0;
	
	assign data_user = (startup) ? (dump_data_case & FIFO_full) : wr_enable_start;
	
	assign wr_enable = sdram_wr_en;
	assign wr_data = FIFO_out;
	
	
	wire addr_cnt_a;
	wire read_addr_cnt;
	
	assign addr_cnt_a = (clk_33m == 2'b01) & dclk_clken;
	assign read_addr_cnt = rd_enable & addr_cnt_a;
	
	assign rd_ready = rd_enable & addr_cnt_a;
	
	
	
	always@(posedge clk or negedge rst)begin
		if(!rst)begin
			startup_inc <= 1'b0;
		end else begin
			if(wr_addr_inc)begin
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
			FIFO_RD_req <= 1'b0;
		end else begin
			if(startup_inc & FIFO_full)begin
				FIFO_RD_req <= 1'b1;
			end else begin
				FIFO_RD_req <= 1'b0;
			end
		end
	end
	
	always@(posedge clk or negedge rst)begin
		if(!rst)begin
			sdram_wr_en <= 1'b0;
		end else begin
			if(data_user)begin
				if(!busy)begin
					sdram_wr_en <= 1'b1;
				end else begin
					sdram_wr_en <= 1'b0;
				end
			end else begin
				sdram_wr_en <= 1'b0;
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
	
	
	assign row_cnt_en = col_cnt_full & read_addr_cnt;
	
	tft_row_cnt tft_row_cnt_inst0(
		.aclr(~rst),				// input  aclr_sig
		.clock(clk),				// input  clock_sig
		.cnt_en(row_cnt_en),		// input  cnt_en_sig
		.q(row_add) 				// output [8:0] q_sig
	);
	
	tft_col_cnt tft_col_cnt_inst0(
		.aclr(~rst),				// input  aclr_sig
		.clock(clk),				// input  clock_sig
		.cnt_en(read_addr_cnt),		// input  cnt_en_sig
		.cout(col_cnt_full),		// output  cout_sig
		.q(col_add)					// output [9:0] q_sig
	);
	
	
	
	always@(posedge clk or negedge rst)begin
		if(!rst)begin
			rd_enable <= 1'b0;
		end else begin
			if(addr_cnt_a & dump_TV_case_a)begin
				if(TH == 10'd44)begin
					rd_enable <= 1'b1;
				end else if(TH == 10'd844)begin
					rd_enable <= 1'b0;
				end
			end
		end
	end
	
	always@(posedge clk or negedge rst)begin
		if(!rst)begin
			rd_enable_a <= 1'b0;
		end else begin
			if(dump_TV_case_a)begin
				if((TH > 10'd44 & TH < 10'd843) & col_add[0] & col_add[1] | TH == 10'd44)begin
					rd_enable_a <= addr_cnt_a;
				end else begin
					rd_enable_a <= 1'b0;
				end
			end
		end
	end
	
	
	
	//////////////////////////////////////////////////////////////////
	//                          DCLK
	//////////////////////////////////////////////////////////////////
	dclk_cnt dclk_cnt_inst(
		.aclr(~rst),			// input  aset_sig
		.clk_en(startup),		// input  clk_en_sig
		.clock(clk),			// input  clock_sig
		.cout(dclk_rst),		// output  cout_sig
		.q(clk_33m)				// output [1:0] q_sig
	);
	
	always@(posedge clk or negedge rst)begin
		
		if(!rst)begin
			dclk_clken <= 1'b0;
		end else begin
			if(dclk_rst)begin
				dclk_clken <= ~dclk_clken;
			end
		end
	end
	
	always@(posedge clk or negedge rst)begin
		
		if(!rst)begin
			DCLK <= 1'b1;
		end else begin
			if(dclk_rst)begin
				DCLK <= ~DCLK;
			end
		end
	end
	
	assign dclken = dclk_clken & dclk_rst;
	
	//////////////////////////////////////////////////////////////////
	//                   TFT H-Sync V-Sync control
	//////////////////////////////////////////////////////////////////
	hsync_cnt hsync_cnt_inst(
		
		.aclr		(~rst),			// input  aclr_sig
		.clock		(clk),			// input  clock_sig
		.clk_en		(dclken),		// input  clk_en_sig
		
		.cnt_en		(startup),		// input  clk_en_sig
		.cout		(TH_cout),		// output  cout_sig
		.q			(TH)			// output [9:0] q_sig
	);
	
	vsync_cnt vsync_cnt_inst(	
		
		.aclr		(~rst),			// input  aset_sig
		.clock		(clk),			// input  clock_sig
		.clk_en		(dclken),		// input  clk_en_sig
		
		.cnt_en		(TH_cout),		// input  clk_en_sig
		.q			(TV)			// output [8:0] q_sig
	);
	
	always@(posedge clk or negedge rst)begin
		
		if(!rst)begin
			DE <= 1'b0;
		end else begin
			if(dclken)begin
				if(dump_data_inc)begin
					DE <= 1'b1;
				end else begin
					DE <= 1'b0;
				end
			end
		end
	end
	//////////////////////////////////////////////////////////////////
	
endmodule
