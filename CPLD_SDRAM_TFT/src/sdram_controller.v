/**
 * simple controller for ISSI IS42S16160G-7 SDRAM found in De0 Nano
 *  16Mbit x 16 data bit bus (32 megabytes)
 *  Default options
 *    100MHz
 *    CAS 3
 *
 *  Very simple host interface
 *     * No burst support
 *     * haddr - address for reading and wriging 16 bits of data
 *     * data_input - data for writing, latched in when wr_enable is highz0
 *     * data_output - data for reading, comes available sometime *few clocks* after rd_enable and address is presented on bus
 *     * rst_n - start init ram process
 *     * rd_enable - read enable, on clk posedge haddr will be latched in, after *few clocks* data will be available on the data_output port
 *     * wr_enable - write enable, on clk posedge haddr and data_input will be latched in, after *few clocks* data will be written to sdram
 *
 * Theory
 *  This simple host interface has a busy signal to tell you when you are not able
 *  to issue commands. 
 */

module sdram_controller
#(
	/* Internal Parameters */
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
	/* Interface Definition */
	/* HOST INTERFACE */
	input	[HADDR_WIDTH-1 : 0]		wr_addr,
	input	[15 : 0]				wr_data,
	input							wr_enable,
	output							wr_addr_inc,

	input	[HADDR_WIDTH-1 : 0]		rd_addr,
	output	[15 : 0]				rd_data,
	input							rd_ready,
	input							rd_enable,

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
	
	////////////////////////////////////////////////////////////
	//	registers
	////////////////////////////////////////////////////////////
	
	reg		[HADDR_WIDTH-1 : 0]		haddr_r;
	reg		[15 : 0]				wr_data_r;
	
	reg		[16*4-1 : 0]			rd_data_r;
	
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
	assign data_mask_high	= data_mask_high_r;
	assign data_mask_low	= data_mask_low_r;
	assign rd_data			= rd_data_r[0 +: 16];
	
	assign wr_addr_inc		= wr_addr_inc_r;
	
	// pack the command to sdram interface
	assign {clken, cs_n, ras_n, cas_n, we_n} = command[7:3];
	
	// state[4] will be set if mode is read/write
	assign bank_addr	= (state[4]) ? bank_addr_r : command[2:1];
	assign addr			= (state[4] | state == INIT_LOAD) ? addr_r : { {SDRADDR_WIDTH-11{1'b0}}, command[0], 10'd0 };
	
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
			if(state == WRIT_CAS)begin
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
			
			state <= INIT_NOP1;
			command <= CMD_NOP;
			state_cnt <= 4'hf;
			
			haddr_r <= {HADDR_WIDTH{1'b0}};
			wr_data_r <= 16'b0;
			busy_r <= 1'b1;
			
		end else begin
			
			state <= next;
			command <= command_nxt;
			
			if(next == INIT_NOP4 && !state_cnt_nxt)begin
				busy_r <= 1'b0;
			end else begin
				busy_r <= state[4];
			end
			
			if(!state_cnt)begin
				state_cnt <= state_cnt_nxt;
			end else begin
				state_cnt <= state_cnt - 4'b1;
			end
			
			/* With Auto-Precharge */
			if(wr_enable)begin
				wr_data_r <= wr_data;
			end
			
			if(rd_enable)begin
				haddr_r <= rd_addr;
			end else if (wr_enable)begin
				haddr_r <= wr_addr;
			end
		end
	end
	
	/* Handle logic for sending addresses to SDRAM based on current state*/
	always@(*)begin
	
		if(state[4])begin
			{data_mask_low_r, data_mask_high_r} = 2'b00;
		end else begin
			{data_mask_low_r, data_mask_high_r} = 2'b11;
		end
		
		bank_addr_r = 2'b00;
		addr_r = {SDRADDR_WIDTH{1'b0}};
		
		if (state == READ_ACT | state == WRIT_ACT)begin
			bank_addr_r = haddr_r[HADDR_WIDTH-1:HADDR_WIDTH-(BANK_WIDTH)];
			addr_r = haddr_r[HADDR_WIDTH-(BANK_WIDTH+1):HADDR_WIDTH-(BANK_WIDTH+ROW_WIDTH)];
		end else if (state == READ_CAS | state == WRIT_CAS)begin
			// Send Column Address
			// Set bank to bank to precharge
			bank_addr_r = haddr_r[HADDR_WIDTH-1:HADDR_WIDTH-(BANK_WIDTH)];
			
			// Examples for math
			//               BANK  ROW    COL
			// HADDR_WIDTH   2 +   12 +   8   = 22
			// SDRADDR_WIDTH 12 
			// Set address to 000s + 1 (for auto precharge) + column address
			addr_r = {{SDRADDR_WIDTH-(COL_WIDTH+3){1'b0}}, auto_prechr, 2'b0, haddr_r[COL_WIDTH-1:0]};
			
		end else if (state == INIT_LOAD)begin
			// Program mode register during load cycle
			addr_r = {{SDRADDR_WIDTH-10{1'b0}}, write_mode, 2'b00, cas_latency, burst_type, burst_len};
		end
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
			end else if (rd_enable)begin
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
						next = READ_READ;
					end
					
					READ_READ: begin
						next = READ_NOP2;
						state_cnt_nxt = 4'd3;
					end
					
					READ_NOP2: begin
						next = IDLE;
						state_cnt_nxt = 4'd2;
					end
					
					/*READ_NOP2: begin
						if(rd_enable)begin
							next = READ_NOP3;
							state_cnt_nxt = 4'd14;
						end else begin
							next = IDLE;
						end
					end
					
					READ_NOP3: begin
						if(rd_enable)begin
							next = READ_ACT;
							command_nxt = CMD_BACT;
						end else begin
							next = IDLE;
						end
					end*/

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
