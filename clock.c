#define 	LOCKCON0  			(*(volatile unsigned long *)0x4C000000)
#define 	MPLLCON   			(*(volatile unsigned long *)0x4C000010)
#define 	CLKSRC    			(*(volatile unsigned long *)0x4C000020)
#define 	CLKDIV0    			(*(volatile unsigned long *)0x4C000024)

// 400-133-66
#define	Startup_MDIV			400
#define	Startup_PDIV			3
#define	Startup_SDIV			1
#define Startup_MPLLSTOP		0

#define	Startup_ARMCLKdiv		1
#define	Startup_PREdiv			0x2
#define	Startup_HCLKdiv			0x1
#define	Startup_PCLKdiv			1
#define CLK_DIV_VAL				((Startup_ARMCLKdiv<<9)|(Startup_PREdiv<<4)|(Startup_PCLKdiv<<2)|(Startup_HCLKdiv))
#define MPLL_VAL				((Startup_MPLLSTOP<<24)|(Startup_MDIV<<14)|(Startup_PDIV<<5)|(Startup_SDIV))

void clock_init(void)
{
	// 设置分频
	// ARMCLK = MPLLout/ARMCLK Ratio = MPLLout/(ARMDIV+1) = 800/2 = 400MHz
	// HCLK = MPLLout/HCLK Ratio = MPLLout/( (PREDIV+1) * (HCLKDIV + 1) ) = 800/(3*2) = 133MHz
	// PCLK = HCLK/PCLKDIV = 133/2 = 66.5MHz
	CLKDIV0	= (CLKDIV0&~(0x1E37)) | CLK_DIV_VAL;

	// 设置locktime
	LOCKCON0 = 0xffff;

	// 设置MPLL
	MPLLCON = MPLL_VAL;

	// 设置时钟源
	CLKSRC |= 1<<4;
}
