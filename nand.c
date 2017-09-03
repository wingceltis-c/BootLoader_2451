#define __REG(x)    			(*((volatile unsigned int *)(x)))
#define __REGb(x)				(*(volatile unsigned char *)(x))
#define NFCONF_REG				__REG(0x4e000000)
#define NFCONT_REG				__REG(0x4e000004)
#define NFCMD_REG				__REG(0x4e000008)
#define NFADDR_REG				__REG(0x4e00000c)
#define NFDATA_REG				__REG(0x4e000010)
#define NFDATA8_REG				__REGb(0x4e000010)
#define NFMECCDATA0_REG			__REG(0x4e000014)
#define NFMECCDATA1_REG			__REG(0x4e000018)
#define NFSECCDATA0_REG			__REG(0x4e00001c)
#define NFSBLK_REG				__REG(0x4e000020)
#define NFEBLK_REG				__REG(0x4e000024)
#define NFSTAT_REG				__REG(0x4e000028)
#define NFESTAT0_REG			__REG(0x4e00002c)
#define NFESTAT1_REG			__REG(0x4e000030)
#define NFMECC0_REG				__REG(0x4e000034)
#define NFMECC1_REG				__REG(0x4e000038)
#define NFSECC_REG				__REG(0x4e00003c)
#define NFMLCBITPT_REG			__REG(0x4e000040)
#define NFCONF_ECC_MLC			(1<<24)
#define NFCONF_ECC_1BIT			(0<<23)
#define NFCONF_ECC_4BIT			(2<<23)
#define NFCONF_ECC_8BIT			(1<<23)
#define NFCONT_ECC_ENC			(1<<18)
#define NFCONT_WP				(1<<16)
#define NFCONT_MECCLOCK			(1<<7)
#define NFCONT_SECCLOCK			(1<<6)
#define NFCONT_INITMECC			(1<<5)
#define NFCONT_INITSECC			(1<<4)
#define NFCONT_INITECC			(NFCONT_INITMECC | NFCONT_INITSECC)
#define NFCONT_CS_ALT			(1<<1)
#define NFCONT_CS				(1<<1)
#define NFSTAT_ECCENCDONE		(1<<7)
#define NFSTAT_ECCDECDONE		(1<<6)
#define NFSTAT_RnB				(1<<0)
#define NFESTAT0_ECCBUSY		(1<<31)
#define NAND_DISABLE_CE(nand)	(NFCONT_REG |= (1 << 1))
#define NAND_ENABLE_CE(nand)	(NFCONT_REG &= ~(1 << 1))
#define NF_TRANSRnB()			do { while(!(NFSTAT_REG & (1 << 0))); } while(0)

#define NAND_CMD_READ0			0
#define NAND_CMD_READ1			1
#define NAND_CMD_PAGEPROG		0x10
#define NAND_CMD_READOOB		0x50
#define NAND_CMD_ERASE1			0x60
#define NAND_CMD_STATUS			0x70
#define NAND_CMD_SEQIN			0x80
#define NAND_CMD_READID			0x90
#define NAND_CMD_ERASE2			0xd0
#define NAND_CMD_RESET			0xff
#define NAND_CMD_READSTART		0x30
#define NAND_CMD_RNDOUTSTART	0xE0
#define NAND_CMD_CACHEDPROG		0x15

void nand_init(void)
{
	// 设置NAND Flash控制器
	NFCONF_REG = ( (0x2<<12)|(0xf<<8)|(0x7<<4) );
	NFCONT_REG |= (0x3<<0);
}


void nand_select(void)
{
	// 发片选
	NAND_ENABLE_CE();
}

void nand_deselect(void)
{
	// 取消片选
	NAND_DISABLE_CE();
}

void nand_cmd(unsigned char cmd)
{
	volatile int i;
	NFCMD_REG = cmd;
	for (i = 0; i < 10; i++);
}

void nand_addr(unsigned int addr)
{
	unsigned int col  = addr % 2048;
	unsigned int page = addr / 2048;
	volatile int i;

	NFADDR_REG = col & 0xff;
	for (i = 0; i < 10; i++);
	NFADDR_REG = (col >> 8) & 0xff;
	for (i = 0; i < 10; i++);
	
	NFADDR_REG  = page & 0xff;
	for (i = 0; i < 10; i++);
	NFADDR_REG  = (page >> 8) & 0xff;
	for (i = 0; i < 10; i++);
	NFADDR_REG  = (page >> 16) & 0xff;
	for (i = 0; i < 10; i++);	
}

void nand_wait_ready(void)
{
	// 等待数据
	NF_TRANSRnB();
}

unsigned char nand_data(void)
{
	return NFDATA8_REG;
}

void nand_read(unsigned int addr, unsigned char *buf, unsigned int len)
{
	int col = addr % 2048;
	int i = 0;
		
	/* 1. 选中 */
	nand_select();

	while (i < len)
	{
		/* 2. 发出读命令00h */
		nand_cmd(0x00);

		/* 3. 发出地址(分5步发出) */
		nand_addr(addr);

		/* 4. 发出读命令30h */
		nand_cmd(0x30);

		/* 5. 判断状态 */
		nand_wait_ready();

		/* 6. 读数据 */
		for (; (col < 2048) && (i < len); col++)
		{
			buf[i] = nand_data();
			i++;
			addr++;
		}
		
		col = 0;
	}

	/* 7. 取消选中 */		
	nand_deselect();
}

void clear_bss(void)
{
	extern int bss_start,bss_end;
	
	int *p = &bss_start;

	for(;p< &bss_end;p++)
		*p=0;
	
}
