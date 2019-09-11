/*
 * main.c
 *
 *  Author: Briansune
 */

#include "stm32f10x.h"
#include "delay.h"
#include "cpld_tft.h"


int main(void){
	
	RCC_ClocksTypeDef ClksFreq;
	
	uint8_t in_color_a;
	uint8_t in_color_b;
	
	uint16_t i = 0;
	uint16_t x,y;
	
	while(--i);					//	ensure core is stable
	
	delay_init();				//	use delay route 72MHz sysclk
	
	RCC_GetClocksFreq(&ClksFreq);	//	debug use
	
	delay_ms(200);				//	this delay use for freeing the JTAG / SWD
	lcd_ini();
	delay_ms(200);
	
	lcd_backlight_pwm(15);
	
	while(1){
		
		LCD_write_cmd_data(0x0007,799);	//	799
		LCD_write_cmd_data(0x0006,479);	//	479
		LCD_write_cmd_data(0x0003,0);	//	0
		LCD_write_cmd_data(0x0002,0);	//	0
		
		
		in_color_a = 0x00;
		in_color_b = 0xFF;
		
		LCD_WR_REG(0x000F);
		
		for(x=0; x < 480; x++){
			for(y=0; y < 800; y++){
				LCD_WR_DATA((in_color_b++)<<8 | (in_color_a++));
			}
		}
		
		CS_SET();
		
		LCD_write_cmd_data(0x0005,1);
		LCD_write_cmd_data(0x0007,799);	//	799
		LCD_write_cmd_data(0x0006,479);	//	479
		LCD_write_cmd_data(0x0003,0);	//	0
		LCD_write_cmd_data(0x0002,0);	//	0
		LCD_WR_REG(0x000F);
		
		for(x=0; x < 480; x++){
			for(y=0; y < 800; y++){
				LCD_WR_DATA(0xF800);
			}
		}
		
		CS_SET();
		
		LCD_write_cmd_data(0x0005,2);
		LCD_write_cmd_data(0x0007,799);	//	799
		LCD_write_cmd_data(0x0006,479);	//	479
		LCD_write_cmd_data(0x0003,0);	//	0
		LCD_write_cmd_data(0x0002,0);	//	0
		LCD_WR_REG(0x000F);
		
		for(x=0; x < 480; x++){
			for(y=0; y < 800; y++){
				LCD_WR_DATA(0x001F);
			}
		}
		
		CS_SET();
		
		LCD_write_cmd_data(0x0005,3);
		LCD_write_cmd_data(0x0007,799);	//	799
		LCD_write_cmd_data(0x0006,479);	//	479
		LCD_write_cmd_data(0x0003,0);	//	0
		LCD_write_cmd_data(0x0002,0);	//	0
		LCD_WR_REG(0x000F);
		
		for(x=0; x < 480; x++){
			for(y=0; y < 800; y++){
				LCD_WR_DATA(0x07E0);
			}
		}
		
		CS_SET();
		
		LCD_write_cmd_data(0x0005,4);
		LCD_write_cmd_data(0x0007,799);	//	799
		LCD_write_cmd_data(0x0006,479);	//	479
		LCD_write_cmd_data(0x0003,0);	//	0
		LCD_write_cmd_data(0x0002,0);	//	0
		LCD_WR_REG(0x000F);
		
		for(x=0; x < 480; x++){
			for(y=0; y < 800; y++){
				LCD_WR_DATA(0x0000);
			}
		}
		
		CS_SET();
		
		for(x=0; x < 300; x++){
				
			LCD_write_cmd_data(0x0007,x);	//	0 to 299
			LCD_write_cmd_data(0x0006,x);	//	0 to 299
			LCD_write_cmd_data(0x0003,x);	//	0 to 299
			LCD_write_cmd_data(0x0002,x);	//	0 to 299
			
			LCD_write_cmd_data(0x000F,~0x07E0);
		}
		
		LCD_write_cmd_data(0x0007,399);	//	399 width end
		LCD_write_cmd_data(0x0006,299);	//	299 height end
		LCD_write_cmd_data(0x0003,100);	//	0 width start
		LCD_write_cmd_data(0x0002,100);	//	0 height start
		LCD_WR_REG(0x000F);
		
		for(x=0; x < 300; x++){
			for(y=0; y < 100; y++){
				LCD_WR_DATA(0x07E0);
				LCD_WR_DATA(0x07E0);
			}
		}
		
		CS_SET();
		
		LCD_write_cmd_data(0x0007,199);	//	199
		LCD_write_cmd_data(0x0006,299);	//	299
		LCD_write_cmd_data(0x0003,50);	//	50
		LCD_write_cmd_data(0x0002,0);	//	0
		LCD_WR_REG(0x000F);
		
		for(x=0; x < 150; x++){
			for(y=0; y < 150; y++){
				LCD_WR_DATA(0xFFE0);
				LCD_WR_DATA(0xFFE0);
			}
		}
		
		CS_SET();
		
		LCD_write_cmd_data(0x0007,499);	//	499
		LCD_write_cmd_data(0x0006,299);	//	299
		LCD_write_cmd_data(0x0003,150);	//	0
		LCD_write_cmd_data(0x0002,250);	//	0
		
		LCD_WR_REG(0x000F);
		
		for(x=0; x < 25; x++){
			for(y=0; y < 350; y++){
				LCD_WR_DATA(0x07FF);
				LCD_WR_DATA(0x07FF);
			}
		}
		
		CS_SET();
		
		LCD_write_cmd_data(0x000D,1);
		
		LCD_write_cmd_data(0x0007,599);	//	599
		LCD_write_cmd_data(0x0006,399);	//	399
		LCD_write_cmd_data(0x0003,170);	//	0
		LCD_write_cmd_data(0x0002,270);	//	0
		LCD_WR_REG(0x000F);
		
		for(x=0; x < 215; x++){
			for(y=0; y < 130; y++){
				LCD_WR_DATA(0x001F);
				LCD_WR_DATA(0x001F);
			}
		}
		
		CS_SET();
		
		// change back to col row order
		LCD_write_cmd_data(0x000D,0);
		
		// change write page no.
		LCD_write_cmd_data(0x0005,5);
		
		LCD_write_cmd_data(0x0007,799);	//	799
		LCD_write_cmd_data(0x0006,479);	//	479
		LCD_write_cmd_data(0x0003,0);	//	0
		LCD_write_cmd_data(0x0002,0);	//	0
		LCD_WR_REG(0x000F);
		
		for(x=0; x < 800; x++){
			for(y=0; y < 480; y++){
				LCD_WR_DATA(0x0000);
			}
		}
		
		CS_SET();
		
		LCD_write_cmd_data(0x0004,0);
		delay_ms(2000);
		LCD_write_cmd_data(0x0004,1);
		delay_ms(2000);
		LCD_write_cmd_data(0x0004,2);
		delay_ms(2000);
		LCD_write_cmd_data(0x0004,3);
		delay_ms(2000);
		LCD_write_cmd_data(0x0004,4);
		delay_ms(2000);
		LCD_write_cmd_data(0x0004,5);
		delay_ms(2000);
		
		LCD_write_cmd_data(0x0005,0);
		LCD_write_cmd_data(0x0004,0);
	}
}

/*	EOF		*/

