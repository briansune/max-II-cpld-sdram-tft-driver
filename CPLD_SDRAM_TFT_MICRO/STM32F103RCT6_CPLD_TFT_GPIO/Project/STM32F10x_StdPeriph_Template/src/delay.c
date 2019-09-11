/*
 * delay.c
 *
 *  Author: Briansune
 */

#include "delay.h"


static __IO uint32_t TimingDelay;

/* Private function prototypes -----------------------------------------------*/

void delay_init(void){
	
	//SysTick_CLKSourceConfig(SysTick_CLKSource_HCLK_Div8);
	if(SysTick_Config(SystemCoreClock / 1000000)){
		while(1);
	}
}

/**
  * @brief  Inserts a delay time.
  * @param  nTime: specifies the delay time length, in milliseconds.
  * @retval None
  */
void delay_us(__IO uint32_t nTime){ 
	TimingDelay = nTime;
	while(TimingDelay != 0);
}

void delay_ms(__IO uint32_t nTime){
	while(nTime--){
		delay_us(1000);
	}
}

/**
  * @brief  Decrements the TimingDelay variable.
  * @param  None
  * @retval None
  */
void TimingDelay_Decrement(void){
	if(TimingDelay != 0x00)
		TimingDelay--;
}
