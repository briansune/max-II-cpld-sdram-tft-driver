/*
 *  Author: Briansune
 */

#include "stm32f10x.h"
#include "delay.h"
#include "cpld_ctrl.h"

uint16_t color_readback;

int main(void){
	
	RCC_ClocksTypeDef ClksFreq;
	
	uint16_t i = 0;
	uint16_t x,y;
	
	while(--i);					//	ensure core is stable
	
	delay_init();				//	use delay route 72MHz sysclk
	
	RCC_GetClocksFreq(&ClksFreq);	//	debug use
	
	delay_ms(200);
	lcd_ini();
	delay_ms(500);
	
	lcd_backlight_pwm(10);
	
	i = 0x5AA5;
	LCD_write_cmd_data(0x0007,799);	//	800
	LCD_write_cmd_data(0x0006,479);	//	480
	LCD_write_cmd_data(0x0003,0);	//	0
	LCD_write_cmd_data(0x0002,0);	//	0
	LCD_WR_REG(0x000F);
	RS_SET();WR_SET();
	
	for(x=0; x < 800; x++){
		for(y=0; y < 480; y++){
			
			LCD_WR_DATA(i);
			i++;
		}
	}
	
	CS_SET();
	delay_ms(2000);
	
	i = 0;
	LCD_write_cmd_data(0x0007,799);	//	800
	LCD_write_cmd_data(0x0006,479);	//	480
	LCD_write_cmd_data(0x0003,0);	//	0
	LCD_write_cmd_data(0x0002,0);	//	0
	LCD_WR_REG(0x000F);
	RS_SET();WR_SET();
	
	for(x=0; x < 800; x++){
		for(y=0; y < 480; y++){
			LCD_RD_DATA();
		}
	}
	
	CS_SET();
	lcd_backlight_pwm(10);
	
	delay_ms(2000);
	
	while(1){
	}
}

/*	EOF		*/

