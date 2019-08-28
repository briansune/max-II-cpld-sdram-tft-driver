module USER_ctrl(

	inout [15:0] DATA,
	input WR, CS, RS, RST, RD,
	input osc_clk,
	output reg LR, UD,
	
	output reg [3:0] pwm_backlight,
	
	/* USER INTERFACE */
	output reg [2:0] page_show,
	output reg [2:0] page_set,
	
	output [8:0] row_add,
	output [9:0] col_add,
	input startup_inc,
	
	input FIFO_RD_req,
	output reg FIFO_full,
	output reg [15:0] FIFO_data,
	
	output reg startup
);
	
	/* Parameter */
	/****************************************************/
	localparam [3:0] TFT_CMD_NOP			= 4'h0;
	localparam [3:0] TFT_CMD_Backlight		= 4'h1;
	localparam [3:0] TFT_CMD_Row_Add_S		= 4'h2;
	localparam [3:0] TFT_CMD_Col_Add_S		= 4'h3;
	localparam [3:0] TFT_CMD_Row_Add_E		= 4'h6;
	localparam [3:0] TFT_CMD_Col_Add_E		= 4'h7;
	localparam [3:0] TFT_CMD_Dis_Page		= 4'h4;
	localparam [3:0] TFT_CMD_Page_No		= 4'h5;	
	localparam [3:0] TFT_CMD_Sleep			= 4'hB;
	localparam [3:0] TFT_CMD_Disp_Mode		= 4'hC;
	localparam [3:0] TFT_CMD_Add_ptr_inc	= 4'hD;
	localparam [3:0] TFT_CMD_data_ptr		= 4'hF;
	/****************************************************/
	
	/* Parameter */
	/****************************************************/
	localparam [2:0] User_SS_Idle			= 3'b000;
	localparam [2:0] User_SS_WR_CMD			= 3'b001;
	localparam [2:0] User_SS_WR_DATA		= 3'b010;
	localparam [2:0] User_SS_RD_DATA		= 3'b011;
	localparam [2:0] User_SS_END			= 3'b100;
	/****************************************************/
	
	/****************************/
	reg data_inout;
	reg [15:0] data_out_buff;
	/****************************/
	
	/* buffer */
	/****************************/
	reg [3:0] cmd_in_buff;
	/****************************/
	
	/* Address Increament */
	/****************************/
	reg row_col_inc;
	/****************************/
	
	/* Address Boundary */
	/****************************/
	reg [8:0] row_add_S;
	reg [9:0] col_add_S;
	reg [8:0] row_add_E;
	reg [9:0] col_add_E;
	/****************************/
	
	/****************************/
	reg update_col_row_add;
	/****************************/
	
	/* state counter */
	reg [2:0] write_read_ss;
	
	wire [15:0] data_in_buff;
	
	bidirectional_io bi_io_inst(
		
		.output_enable(data_inout),
		.data(data_out_buff),
		.bidir_variable(DATA),
		.read_buffer(data_in_buff)
	);
	
	//////////////////////////////////////////////////////////////////
	// user TFT control column and row address
	//////////////////////////////////////////////////////////////////
	
	wire col_cnt_end;
	wire row_cnt_end;
	
	wire user_col_ld;
	wire user_row_ld;
	
	wire col_cnt_en;
	wire row_cnt_en;
	
	assign col_cnt_end = (col_add == col_add_E) ? 1'b1 : 1'b0;
	assign row_cnt_end = (row_add == row_add_E) ? 1'b1 : 1'b0;
	
	assign user_col_ld = update_col_row_add | (col_cnt_end & col_cnt_en);
	assign user_row_ld = update_col_row_add | (row_cnt_end & row_cnt_en);
	
	assign col_cnt_en = (~row_col_inc | row_cnt_end) & startup_inc;
	assign row_cnt_en = (row_col_inc | col_cnt_end) & startup_inc;
	
	user_col_cnt user_col_cnt_inst(
		
		.aclr		(~RST),					// input  aclr_sig
		.clock		(osc_clk),				// input  clock_sig
		
		.sload		(user_col_ld),			// input  sload_sig
		.data		(col_add_S),			// input [9:0] data_sig
		
		.cnt_en		(col_cnt_en),			// input  cnt_en_sig
		.q			(col_add) 				// output [9:0] q_sig
	);
	
	user_row_cnt user_row_cnt_inst(
		
		.aclr		(~RST),					// input  aclr_sig
		.clock		(osc_clk),				// input  clock_sig
		
		.sload		(user_row_ld),			// input  sload_sig
		.data		(row_add_S),			// input [8:0] data_sig
		
		.cnt_en		(row_cnt_en),			// input  cnt_en_sig
		.q			(row_add) 				// output [8:0] q_sig
	);
	
	always@(posedge osc_clk or negedge RST)begin
		if(!RST)begin
			startup <= 1'b0;
		end else begin
			if(col_cnt_en & col_cnt_end & row_cnt_end)begin
				startup <= 1'b1;
			end
		end
	end
	
	wire [3:0] user_in;
	assign user_in	= {CS,RS,WR,RD};
	
	/* User Interface State Machine */
	always@(posedge osc_clk or negedge RST)begin
	
		if(!RST)begin
			write_read_ss <= User_SS_Idle;
			data_inout <= 1'b0;
		end else begin
			
			case(write_read_ss)
				User_SS_Idle: begin
					if(user_in == 4'b0001)begin
						write_read_ss <= User_SS_WR_CMD;
					end else if(user_in == 4'b0101)begin
						write_read_ss <= User_SS_WR_DATA;
					end else if(user_in == 4'b0110)begin
						write_read_ss <= User_SS_RD_DATA;
					end else begin
						write_read_ss <= User_SS_Idle;
					end
					
					data_inout <= 1'b0;
				end
				
				User_SS_WR_CMD: begin
					data_inout <= 1'b0;
					write_read_ss <= User_SS_END;
				end
				
				User_SS_WR_DATA: begin
					data_inout <= 1'b0;
					write_read_ss <= User_SS_END;
				end
				
				User_SS_RD_DATA: begin
					data_inout <= 1'b1;
					write_read_ss <= User_SS_END;
				end
				
				User_SS_END: begin
					if(CS | (WR&RD))begin
						write_read_ss <= User_SS_Idle;
					end else begin
						write_read_ss <= User_SS_END;
					end
					
					data_inout <= 1'b0;
				end
				
				default: begin
					write_read_ss <= User_SS_Idle;
				end
				
			endcase
		end
	end
	
	always@(posedge osc_clk or negedge RST)begin
		if(!RST)begin
			cmd_in_buff <= 4'b0000;
		end else begin
			if(write_read_ss == User_SS_WR_CMD)begin
				cmd_in_buff <= data_in_buff[3:0];
			end
		end
	end
	
	always@(posedge osc_clk or negedge RST)begin
		
		if(!RST)begin
		
			pwm_backlight <= 4'd0;
			
			page_show <= 3'b0;
			page_set <= 3'b0;
			{UD,LR} <= 2'b0;
			
			row_add_S <= 9'd0;
			col_add_S <= 10'd0;
			row_add_E <= 9'd479;
			col_add_E <= 10'd799;
			
			update_col_row_add <= 1'b0;
			
			FIFO_full <= 1'b0;
			FIFO_data <= 16'b0;
			
			data_out_buff <= 16'b0;
			
			row_col_inc <= 1'b0;
			
		end else begin
			
			if(write_read_ss == User_SS_WR_DATA)begin
				case(cmd_in_buff)
					
					TFT_CMD_Backlight: begin
						pwm_backlight <= data_in_buff[3:0];
					end
					
					TFT_CMD_Row_Add_S: begin
						if(data_in_buff[8 : 0] <= row_add_E)begin
							row_add_S <= data_in_buff[8:0];
							update_col_row_add <= 1'b1;
						end
					end
						
					TFT_CMD_Col_Add_S: begin
						if(data_in_buff[9 : 0] <= col_add_E)begin
							col_add_S <= data_in_buff[9:0];
							update_col_row_add <= 1'b1;
						end
					end
						
					TFT_CMD_Row_Add_E: begin
						if(data_in_buff[8 : 0] < 9'd480)begin
							row_add_E <= data_in_buff[8:0];
						end
					end
						
					TFT_CMD_Col_Add_E: begin
						if(data_in_buff[9 : 0] < 10'd800)begin
							col_add_E <= data_in_buff[9:0];
						end
					end
						
					TFT_CMD_Dis_Page: begin
						page_show <= data_in_buff[2:0];
					end
						
					TFT_CMD_Page_No: begin
						page_set <= data_in_buff[2:0];
					end
						
					TFT_CMD_Disp_Mode: begin
						{UD,LR} <= data_in_buff[1:0];
					end
						
					TFT_CMD_Add_ptr_inc: begin
						row_col_inc <= data_in_buff[0];
					end
						
					TFT_CMD_data_ptr: begin
						if(!FIFO_full)begin
							FIFO_data <= data_in_buff;
							FIFO_full <= 1'b1;
						end
					end
					
					default: begin
					end
					
				endcase
				
			end else begin
				
				if(FIFO_RD_req)begin
					FIFO_full <= 1'b0;
				end
				
				if(update_col_row_add)begin
					update_col_row_add <= 1'b0;
				end
			end
		end
	end
	
endmodule

