/*
 * cpld_tft.c
 *
 * Author: Briansune
 */
 
#include "cpld_tft.h"
#include "delay.h"


void LCD_WR_REG(uint16_t LCD_Reg){
	
	CS_SET();RD_SET();WR_SET();RS_SET();
	GPIOC->ODR = LCD_Reg;
	
	CS_CLR();
	RS_CLR();RS_CLR();
	WR_SET();WR_SET();WR_SET();WR_SET();
	WR_CLR();WR_CLR();WR_CLR();WR_CLR();
	WR_SET();WR_SET();WR_SET();WR_SET();
	
}

void LCD_WR_DATA(uint16_t LCD_RegValue){
	
	GPIOC->ODR = LCD_RegValue;
	RS_SET();
	WR_SET();WR_SET();WR_SET();WR_SET();
	WR_CLR();WR_CLR();WR_CLR();WR_CLR();
	WR_SET();WR_SET();WR_SET();WR_SET();
}

void LCD_CtrlLinesConfig(void){
	
	GPIO_InitTypeDef GPIO_InitStructure;
	
	/*	GPIOC	bus	-	TFT_DATA	*/
	/*	GPIOB	9	-	TFT_RESET	*/
	/*	GPIOB	1	-	TFT_WR		*/
	/*	GPIOB	0	-	TFT_RD		*/
	/*	GPIOA	1	-	TFT_RS		*/
	/*	GPIOA	11	-	TFT_CS		*/
	RCC_APB2PeriphClockCmd(	RCC_APB2Periph_GPIOA | RCC_APB2Periph_GPIOB |
							RCC_APB2Periph_GPIOC, ENABLE);
	
	
	GPIO_PinRemapConfig(GPIO_Remap_SWJ_Disable,ENABLE);

	GPIO_InitStructure.GPIO_Pin = GPIO_Pin_All;
	GPIO_InitStructure.GPIO_Speed = GPIO_Speed_50MHz;
	GPIO_InitStructure.GPIO_Mode = GPIO_Mode_Out_PP;
	GPIO_Init(GPIOC, &GPIO_InitStructure);

	GPIO_InitStructure.GPIO_Pin = GPIO_Pin_0 | GPIO_Pin_1 | GPIO_Pin_9;
	GPIO_InitStructure.GPIO_Speed = GPIO_Speed_50MHz;
	GPIO_InitStructure.GPIO_Mode = GPIO_Mode_Out_PP;
	GPIO_Init(GPIOB, &GPIO_InitStructure);
	
	GPIO_InitStructure.GPIO_Pin = GPIO_Pin_1 | GPIO_Pin_11;
	GPIO_InitStructure.GPIO_Speed = GPIO_Speed_50MHz;
	GPIO_InitStructure.GPIO_Mode = GPIO_Mode_Out_PP;
	GPIO_Init(GPIOA, &GPIO_InitStructure);
}

void lcd_ini(void){

	LCD_CtrlLinesConfig();
	
	GPIOC->ODR = 0x0000;
	
	CS_SET();
	RS_SET();
	RD_SET();
	WR_SET();
	
	RESET_SET();
    delay_ms(100);	
	RESET_CLR();
	delay_ms(200);
	RESET_SET();
	delay_ms(300);
}


void LCD_write_dot(uint16_t x, uint16_t y, uint16_t color){
	
	LCD_write_cmd_data(0x0002, y);
	LCD_write_cmd_data(0x0003, x);
	LCD_write_cmd_data(0x000F, color);
}

void LCD_write_cmd_data(uint16_t cmd, uint16_t data){
	
	CS_CLR();
	RS_CLR();
	WR_SET();
	
	// TFT_CMD
	GPIOC->ODR = cmd;
	
	WR_CLR();
	WR_SET();
	
	RS_SET();
	
	GPIOC->ODR = data;
	
	WR_CLR();
	WR_SET();
	
	CS_SET();
}

void lcd_backlight_pwm(uint16_t pwm_data){
	
	CS_CLR();
	RS_CLR();
	WR_SET();
	
	GPIOC->ODR = 0x0001;
	
	WR_CLR();
	WR_SET();
	
	RS_SET();
	
	GPIOC->ODR = pwm_data;
	
	WR_CLR();
	WR_SET();
	
	CS_SET();
}

/* EOF */
