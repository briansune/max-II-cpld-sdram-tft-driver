module tft_backlight(
	
	input				clk,
	input				rst,
	
	input		[3:0]	scale,
	input		[3:0]	pwm_match,	// bit 10-7 from counter
	output reg			PWM
);
	
	always@(posedge clk or negedge rst)begin
		if(!rst)begin
			PWM <= 1'b0;
		end else begin
			if(pwm_match >= scale)begin
				PWM <= 1'b0;
			end else begin
				PWM <= 1'b1;
			end
		end
	end
	
endmodule
