#ifndef _NAND_H_
#define _NAND_H_

void nand_init(void);
// 从NAND中拷贝代码到DRAM
void nand_read(unsigned int addr, unsigned char *buf, unsigned int len);
void clear_bss(void);

#endif
