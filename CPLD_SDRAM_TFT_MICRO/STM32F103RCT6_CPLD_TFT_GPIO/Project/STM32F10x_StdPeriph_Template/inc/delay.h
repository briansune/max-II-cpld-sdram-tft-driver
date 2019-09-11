/*
 * delay.h
 *
 *  Author: Briansune
 */


#ifndef _DELAY_H
#define _DELAY_H 			   

#include "stm32f10x.h"

void delay_init(void);
void TimingDelay_Decrement(void);

void delay_us(__IO uint32_t nTime);
void delay_ms(__IO uint32_t nTime);

#endif





























