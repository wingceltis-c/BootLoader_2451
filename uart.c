#include "uart.h" 
#define ULCON0   		( *((volatile unsigned long *)0x50000000) )
#define UCON0    		( *((volatile unsigned long *)0x50000004) )
#define UFCON0   	 	( *((volatile unsigned long *)0x50000008) )
#define UMCON0    		( *((volatile unsigned long *)0x5000000C) )
#define UTRSTAT0  		( *((volatile unsigned long *)0x50000010) )
#define UFSTAT0 		( *((volatile unsigned long *)0x50000018) )
#define UTXH0      		( *((volatile unsigned char *)0x50000020) )
#define URXH0      		( *((volatile unsigned char *)0x50000024) ) 
#define UBRDIV0    		( *((volatile unsigned short *)0x50000028) )
#define UDIVSLOT0  		( *((volatile unsigned short *)0x5000002C) )
#define GPHCON     		( *((volatile unsigned long *)0x56000070 ) )
#define TXD0READY   	(1<<14)


void uart_init(void)
{
	// 配置引脚  
	GPHCON = (GPHCON & ~0xffff ) | 0xaaaa;
		
	// 设置数据格式等  
	ULCON0 = 0x3;  					// 数据位:8, 无校验, 停止位: 1, 8n1 
	UCON0  = 0x5;  					// 时钟：PCLK，禁止中断，使能UART发送、接收 
	UFCON0 = 0x01; 					// FIFO ENABLE
	UMCON0 = 0;						// 无流控
	
	// 设置波特率  
	// DIV_VAL = (PCLK / (bps x 16 ) ) - 1 = (66500000/(115200x16))-1 = 35.08
	// DIV_VAL = 35.08 = UBRDIVn + (num of 1’s in UDIVSLOTn)/16 
	UBRDIV0   = 35;
	UDIVSLOT0 = 0x2;
}

// 接收一个字符  
char getchar(void)
{
	while ((UFSTAT0 & 0x7f) == 0);  // 如果RX FIFO空，等待 
	return URXH0;                   // 取数据 
}

// 发送一个字符  
void putchar(char c)
{
	while (UFSTAT0 & (1<<14)); 		// 如果TX FIFO满，等待 
	UTXH0 = c;                      // 写数据 
}


void puts(char *str)
{
	int i = 0;
	while (str[i])
	{
		putchar(str[i]);
		i++;
	}
}

void puthex(unsigned int val)
{
	/* 0x1234abcd */
	int i;
	int j;
	
	puts("0x");

	for (i = 0; i < 8; i++)
	{
		j = (val >> ((7-i)*4)) & 0xf;
		if ((j >= 0) && (j <= 9))
			putchar('0' + j);
		else
			putchar('A' + j - 0xa);
		
	}
	
}



