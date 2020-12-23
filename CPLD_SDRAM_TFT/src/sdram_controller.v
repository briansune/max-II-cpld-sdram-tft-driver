`timescale 1ns / 1ps

module sdram_controller #(
	
	parameter ROW_WIDTH = 12,
	parameter COL_WIDTH = 8,
	parameter BANK_WIDTH = 2,
	
	parameter SDRADDR_WIDTH = ROW_WIDTH > COL_WIDTH ? ROW_WIDTH : COL_WIDTH,
	parameter HADDR_WIDTH = BANK_WIDTH + ROW_WIDTH + COL_WIDTH,
	
	parameter CLK_FREQUENCY = 100,		// Mhz     
	parameter REFRESH_TIME =  64,		// ms     (how often we need to refresh) 
	parameter REFRESH_COUNT = 8192		// cycles (how many refreshes required per refresh time)
)
(
	
	input	[HADDR_WIDTH-1 : 0]		wr_addr,
	input	[15 : 0]				wr_data,
	input							wr_enable,
	output							wr_addr_inc,

	input	[HADDR_WIDTH-1 : 0]		rd_addr,
	output	[15 : 0]				rd_data,
	input							rd_ready,
	input							rd_enable,
	
	input							rd_usr_en,
	input							rd_type,
	output							rd_type_clr,
	output	[15 : 0]				rd_data_bypass,
	
	output							busy,
	input							rst_n,
	input							clk,
	
	/* SDRAM SIDE */
	output	[SDRADDR_WIDTH-1 : 0]	addr,
	output	[BANK_WIDTH-1 : 0]		bank_addr,
	inout	[15 : 0]				data,
	output							clken,
	output							cs_n,
	output							ras_n,
	output							cas_n,
	output							we_n,
	output							data_mask_low,
	output							data_mask_high
);
	
	////////////////////////////////////////////////////////////
	//	local parameters
	////////////////////////////////////////////////////////////
		
	// clk / refresh =  clk / sec 
	//                , sec / refbatch 
	//                , ref / refbatch
	localparam CYCLES_BETWEEN_REFRESH = ( CLK_FREQUENCY * 1_000 * REFRESH_TIME ) / REFRESH_COUNT;
	
	// SDRAM setup flags
	localparam burst_len	= 3'b010;	// 1,2,4,8,...,full page
	localparam burst_type	= 1'b0;		// 0 = Sequential, 1 = Interleave
	localparam cas_latency	= 3'b010;	// 010 = CAS2, 011 = CAS3
	localparam write_mode	= 1'b1;		// 0 = Burst Write, 1 = Single Write
	localparam auto_prechr	= 1'b1;		// 0 = no auto pre-charge, 1 = auto pre-charge
	
	// STATES - State
	localparam IDLE			= 5'b00000;
	localparam INIT_NOP1	= 5'b01000;
	localparam INIT_PRE1	= 5'b01001;
	localparam INIT_NOP1_1	= 5'b00101;
	localparam INIT_REF1	= 5'b01010;
	localparam INIT_NOP2	= 5'b01011;
	localparam INIT_REF2	= 5'b01100;
	localparam INIT_NOP3	= 5'b01101;
	localparam INIT_LOAD	= 5'b01110;
	localparam INIT_NOP4	= 5'b01111;

	localparam REF_PRE		= 5'b00001;
	localparam REF_NOP1		= 5'b00010;
	localparam REF_REF		= 5'b00011;
	localparam REF_NOP2		= 5'b00100;

	localparam READ_ACT		= 5'b10000;
	localparam READ_NOP1	= 5'b10001;
	localparam READ_CAS		= 5'b10010;
	localparam READ_NOP2	= 5'b10011;
	localparam READ_READ	= 5'b10100;
	localparam READ_NOP3	= 5'b10101;
	localparam READ_NOP4	= 5'b10110;
	
	localparam WRIT_ACT		= 5'b11000;
	localparam WRIT_NOP1	= 5'b11001;
	localparam WRIT_CAS		= 5'b11010;
	localparam WRIT_NOP2	= 5'b11011;
	localparam WRIT_NOP3	= 5'b11100;

	//	Commands				 CCRCWBBA
	//							 ESSSE100
	localparam CMD_PALL		= 8'b10010001;
	localparam CMD_REF		= 8'b10001000;
	localparam CMD_NOP		= 8'b10111000;
	localparam CMD_MRS		= 8'b1000000x;
	localparam CMD_BACT		= 8'b10011xxx;
	localparam CMD_READ		= 8'b10101xx1;
	localparam CMD_WRIT		= 8'b10100xx1;
	localparam CMD_STBR		= 8'b10110xx0;
	
	////////////////////////////////////////////////////////////
	//	registers
	////////////////////////////////////////////////////////////
	
	reg		[HADDR_WIDTH-1 : 0]		haddr_r;
	reg		[15 : 0]				wr_data_r;
	
	reg		[16*4-1 : 0]			rd_data_r;
	reg		[16-1 : 0]				rd_bypass_data_r;
	
	reg								busy_r;
	reg								data_mask_low_r;
	reg								data_mask_high_r;
	
	reg		[SDRADDR_WIDTH-1 : 0]	addr_r;
	reg		[BANK_WIDTH-1 : 0]		bank_addr_r;
	
	reg								wr_addr_inc_r;
	
	/* Internal Wiring */
	reg [3:0] state_cnt;
	reg [9:0] refresh_cnt;

	reg [7:0] command;
	reg [4:0] state;
	
	reg [7:0] command_nxt;
	reg [3:0] state_cnt_nxt;
	reg [4:0] next;
	
	////////////////////////////////////////////////////////////
	//	wires
	////////////////////////////////////////////////////////////
	wire [15:0] sdram_rd_data;
	
	////////////////////////////////////////////////////////////
	//	assignments
	////////////////////////////////////////////////////////////
	assign busy				= busy_r;
	assign rd_data			= rd_data_r[0 +: 16];
	assign rd_data_bypass	= rd_bypass_data_r;
	
	assign wr_addr_inc		= wr_addr_inc_r;
	assign rd_type_clr		= (next == READ_NOP3) ? 1'b1 : 1'b0;
	
	////////////////////////////////////////////////////////////
	//	SDRAM driver signals
	////////////////////////////////////////////////////////////
	assign clken			= command[7];
	assign cs_n				= command[6];
	assign ras_n			= command[5];
	assign cas_n			= command[4];
	assign we_n				= command[3];
	assign data_mask_high	= data_mask_high_r;
	assign data_mask_low	= data_mask_low_r;
	assign bank_addr		= bank_addr_r;
	assign addr				= addr_r;
	
	////////////////////////////////////////////////////////////
	//	instantiate
	////////////////////////////////////////////////////////////
	bidirectional_io sdram_bio_inst(
		.output_enable(state == WRIT_CAS),
		.data(wr_data_r),
		.bidir_variable(data),
		.read_buffer(sdram_rd_data)
	);
	
	////////////////////////////////////////////////////////////
	//	clocked register logic
	////////////////////////////////////////////////////////////
	
	// auto refresh counter
	always@(posedge clk or negedge rst_n)begin
		
		if(!rst_n)begin
			wr_addr_inc_r <= 1'b0;
		end else begin
			/* Handle refresh counter */
			if(state == WRIT_CAS | state == READ_NOP3)begin
				wr_addr_inc_r <= 1'b1;
			end else begin
				wr_addr_inc_r <= 1'b0;
			end
		end
	end
	
	always@(posedge clk or negedge rst_n)begin
		
		if(!rst_n)begin
			refresh_cnt <= 10'b0;
		end else begin
			/* Handle refresh counter */
			if(state == REF_NOP2 || (state == READ_ACT) || (state == WRIT_ACT))begin
				refresh_cnt <= 10'b0;
			end else begin
				refresh_cnt <= refresh_cnt + 10'b1;
			end
		end
	end
	
	always@(negedge clk or negedge rst_n)begin
		if(!rst_n)begin
			rd_bypass_data_r <= 16'b0;
		end else if(state == READ_NOP4)begin
			rd_bypass_data_r <= sdram_rd_data;
		end
	end
	
	always@(negedge clk or negedge rst_n)begin
		if(!rst_n)begin
			rd_data_r <= 64'b0;
		end else begin
			if(state == READ_NOP2)begin
				case(state_cnt[1 : 0])
					2'd0: rd_data_r[48+:16] <= sdram_rd_data;
					2'd1: rd_data_r[32+:16] <= sdram_rd_data;
					2'd2: rd_data_r[16+:16] <= sdram_rd_data;
					2'd3: rd_data_r[0+:16] <= sdram_rd_data;
				endcase
			end else begin
				if(rd_ready)begin
					rd_data_r <= {rd_data_r[48+:16],rd_data_r[16+:48]};
				end
			end
		end
	end
	
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			busy_r <= 1'b1;
		end else begin
			if(state == INIT_NOP4 && !state_cnt)begin
				busy_r <= 1'b0;
			end else begin
				busy_r <= state[4];
			end
		end
	end
	
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			state <= INIT_NOP1;
		end else begin
			state <= next;
		end
	end
	
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			command <= CMD_NOP;
		end else begin
			command <= command_nxt;
		end
	end
	
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			state_cnt <= 4'hf;
		end else begin
			if(!state_cnt)begin
				state_cnt <= state_cnt_nxt;
			end else begin
				state_cnt <= state_cnt - 4'b1;
			end
		end
	end
	
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			haddr_r <= {HADDR_WIDTH{1'b0}};
		end else begin
			if(rd_enable)begin
				haddr_r <= rd_addr;
			end else if (wr_enable | rd_usr_en)begin
				haddr_r <= wr_addr;
			end
		end
	end
	
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			wr_data_r <= 16'b0;
		end else begin
			if(wr_enable)begin
				wr_data_r <= wr_data;
			end
		end
	end
	
	always@(*)begin
		
		{data_mask_low_r, data_mask_high_r} = 2'b11;
		
		if(state[4])begin
			{data_mask_low_r, data_mask_high_r} = 2'b00;
		end else begin
			{data_mask_low_r, data_mask_high_r} = 2'b11;
		end
	end
	
	always@(*)begin
		
		bank_addr_r = 2'b00;
		
		if (state == READ_ACT | state == WRIT_ACT | state == READ_CAS | state == WRIT_CAS | state[4])begin
			bank_addr_r = haddr_r[HADDR_WIDTH-1:HADDR_WIDTH-(BANK_WIDTH)];
		end else begin
			bank_addr_r = command[2:1];
		end
	end
	
	always@(*)begin
		
		addr_r = {SDRADDR_WIDTH{1'b0}};
		
		case(state)
			INIT_LOAD: addr_r = {{SDRADDR_WIDTH-10{1'b0}}, write_mode, 2'b00, cas_latency, burst_type, burst_len};
			READ_ACT, WRIT_ACT: addr_r = haddr_r[HADDR_WIDTH-(BANK_WIDTH+1):HADDR_WIDTH-(BANK_WIDTH+ROW_WIDTH)];
			READ_CAS, WRIT_CAS: addr_r = {{SDRADDR_WIDTH-(COL_WIDTH+3){1'b0}}, auto_prechr, 2'b0, haddr_r[COL_WIDTH-1:0]};
			default: addr_r = { {SDRADDR_WIDTH-11{1'b0}}, command[0], 10'd0 };
		endcase
	end
	
	// Next state logic
	always@(*)begin
		
		state_cnt_nxt = 4'd0;
		command_nxt = CMD_NOP;
		
		if (state == IDLE)begin
			// Monitor for refresh or hold
			if (refresh_cnt >= CYCLES_BETWEEN_REFRESH)begin
				next = REF_PRE;
				command_nxt = CMD_PALL;
			end else if (rd_enable | rd_usr_en)begin
				next = READ_ACT;
				command_nxt = CMD_BACT;
			end else if (wr_enable)begin
				next = WRIT_ACT;
				command_nxt = CMD_BACT;
			end else begin
				// HOLD
				next = IDLE;
			end
			
		end else begin
			
			if (!state_cnt)begin
				
				case (state)
					
					// INIT ENGINE
					INIT_NOP1: begin
						next = INIT_PRE1;
						command_nxt = CMD_PALL;
					end
					
					INIT_PRE1: begin
						next = INIT_NOP1_1;
					end
					
					INIT_NOP1_1: begin
						next = INIT_REF1;
						command_nxt = CMD_REF;
					end
					
					INIT_REF1: begin
						next = INIT_NOP2;
						state_cnt_nxt = 4'd7;
					end
					
					INIT_NOP2: begin
						next = INIT_REF2;
						command_nxt = CMD_REF;
					end
					
					INIT_REF2: begin
						next = INIT_NOP3;
						state_cnt_nxt = 4'd7;
					end
					
					INIT_NOP3: begin
						next = INIT_LOAD;
						command_nxt = CMD_MRS;
					end
					
					INIT_LOAD: begin
						next = INIT_NOP4;
						state_cnt_nxt = 4'd1;
					end
					// INIT_NOP4: default - IDLE

					// REFRESH
					REF_PRE: begin
						next = REF_NOP1;
					end
					
					REF_NOP1: begin
						next = REF_REF;
						command_nxt = CMD_REF;
					end
					
					REF_REF: begin
						next = REF_NOP2;
						state_cnt_nxt = 4'd7;
					end
					// REF_NOP2: default - IDLE

					// WRITE
					WRIT_ACT: begin
						next = WRIT_NOP1;
						state_cnt_nxt = 4'd1;
					end
					
					WRIT_NOP1: begin
						next = WRIT_CAS;
						command_nxt = CMD_WRIT;
					end
					
					WRIT_CAS: begin
						next = WRIT_NOP2;
						state_cnt_nxt = 4'd2;
					end

					// READ
					READ_ACT: begin
						next = READ_NOP1;
						state_cnt_nxt = 4'd1;
					end
					
					READ_NOP1: begin
						next = READ_CAS;
						command_nxt = CMD_READ;
					end
					
					READ_CAS: begin
						if(rd_type)begin
							command_nxt = CMD_STBR;
							next = READ_NOP3;
						end else begin
							next = READ_READ;
						end
					end
					
					READ_READ: begin
						next = READ_NOP2;
						state_cnt_nxt = 4'd3;
					end
					
					READ_NOP2: begin
						next = IDLE;
						state_cnt_nxt = 4'd2;
					end
					
					READ_NOP3: begin
						next = READ_NOP4;
					end

					default: begin
						next = IDLE;
					end
				
				endcase
				
			end else begin
				// Counter Not Reached - HOLD
				next = state;
				command_nxt = command;
			end
		end
	end
	
endmodule
