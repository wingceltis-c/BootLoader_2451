#define CFG_BANK_CFG_VAL   		0x0004920d
#define CFG_BANK_CON1_VAL		0x04000040
#define CFG_BANK_CON2_VAL		0x0057003a
#define CFG_BANK_CON3_VAL		0x80000030
#define CFG_BANK_REFRESH_VAL		0x00000313

.text

.global _start

_start:
	b reset
	ldr pc,=_undefined_instructions
	ldr pc,=_software_interrupt
	ldr pc,=_prefetch_abort
	ldr pc,=_data_abort
	ldr pc,=_nop_opeartion
	ldr pc,=_irq
	ldr pc,=_fiq

_undefined_instructions: .word undefined_instructions
_software_interrupt: .word software_interrupt
_prefetch_abort: .word prefetch_abort
_data_abort: .word data_abort
_nop_opeartion: .word nop_opeartion
_irq: .word irq
_fiq: .word fiq

undefined_instructions:
	nop

software_interrupt:
	nop

prefetch_abort:
	nop

data_abort:
	nop

nop_opeartion:
	nop

irq:
	nop

fiq:
	nop

reset:
//	bl set_svc_mode   	//设置svc32模式
    bl disable_watchdog	//关闭看门狗
	bl disable_interrupt	//关闭中断
	bl disable_mmu		//关闭mmu
	bl init_led		//初始化led

	//初始化sdram
	adr r0,sdram_bank_set_val
	bl sdr_ctrl_asm_init

	//设置栈
	ldr sp,=0x40002000
	
	//设置时钟
	bl clock_init
	
	//初始化NAND Falsh
	bl nand_init
	
	bl clear_bss
/* 5. 执行main */
	ldr lr, =halt
	ldr pc, =main
halt:
	b halt

set_svc_mode:
	mrs r0,cpsr
	bic r0,r0,#0x1f
	orr r0,r0,#0xdf
//	msr cpsr,r0
	mov pc, lr

#define WTCON 0x53000000
disable_watchdog:
	ldr r0,=WTCON
    	mov r1,#0x00
	str r1,[r0]
	mov pc, lr
	
#define INTMSK_g1 0x4a000008
#define INTMSK_g2 0x4a000048
disable_interrupt:
	mvn r1,#0x00
	ldr r0,=INTMSK_g1
	str r1,[r0]
	ldr r0,=INTMSK_g2
	str r1,[r0]
	mov pc, lr

disable_mmu:
	mcr p15,0,r0,c7,c7,0  //失效 ID cache
	mrc p15,0,r0,c1,c0,0	//读取CP15  register 1
	bic r0, r0, #0x00000005 //   101   Dcache  MMU
	mcr p15,0,r0,c1,c0,0 //写入cp15  register1
	mov pc, lr


delay:
	mov r0, #0x100000
delay_loop:
	cmp r0, #0
	sub r0, r0, #1
	bne delay_loop
	mov pc, lr

	.ltorg
sdram_bank_set_val:
	.word CFG_BANK_CFG_VAL
	.word CFG_BANK_CON1_VAL
	.word CFG_BANK_CON2_VAL
	.word CFG_BANK_CON3_VAL
	.word CFG_BANK_REFRESH_VAL
