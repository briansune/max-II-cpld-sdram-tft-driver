#ifndef _CPLD_TFT_H
#define _CPLD_TFT_H

#include "stm32f10x.h"

#define RS		GPIO_Pin_1
#define WR		GPIO_Pin_1
#define RD		GPIO_Pin_0
#define CS		GPIO_Pin_11
#define RESET	GPIO_Pin_9

#define RS_SET()	GPIOA->BSRR = RS
#define RS_CLR()	GPIOA->BRR = RS

#define WR_SET()	GPIOB->BSRR = WR
#define WR_CLR()	GPIOB->BRR = WR

#define RD_SET()	GPIOB->BSRR = RD
#define RD_CLR()	GPIOB->BRR = RD

#define CS_SET()	GPIOA->BSRR = CS
#define CS_CLR()	GPIOA->BRR = CS

#define RESET_SET()	GPIOB->BSRR = RESET
#define RESET_CLR()	GPIOB->BRR = RESET


void LCD_CtrlLinesConfig(void);

void lcd_ini(void);

void LCD_WR_DATA(uint16_t LCD_RegValue);
void LCD_WR_REG(uint16_t LCD_Reg);


void LCD_write_cmd_data(uint16_t cmd, uint16_t data);
void lcd_backlight_pwm(uint16_t pwm_data);

void LCD_write_dot(uint16_t x, uint16_t y, uint16_t color);


#endif 
