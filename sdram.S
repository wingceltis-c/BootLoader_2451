#define ELFIN_MEMCTL_BASE		0x48000000
#define BANKCFG_OFFSET			0x00
#define BANKCON1_OFFSET			0x04
#define BANKCON2_OFFSET			0x08
#define BANKCON3_OFFSET			0x0c
#define REFRESH_OFFSET			0x10
#define TIMEOUT_OFFSET			0x14

#define INIT_NORMAL				0x0
#define INIT_PALL				0x1
#define INIT_MRS				0x2
#define INIT_EMRS				0x3
#define INIT_MASK				0x3

#define PHYS_SDRAM_1			0x30000000 /* SDRAM Bank #1 */
#define PHYS_SDRAM_1_SIZE		0x04000000 /* 64 MB */
#define CFG_BANK_CFG_VAL_DDR2	0x00049253
#define CFG_BANK_CON2_VAL_DDR2	0x006E0035

.global sdr_ctrl_asm_init
sdr_ctrl_asm_init:
	mov r12,#2

	/* Set GPK port when using x32 bus width. */
	ldr	r2,=0x560000e0
	ldr r2,[r2]
	ldr	r1,=0xaaaaaaaa	@ set Sdata[31:16]
	str	r1, [r2]

	/* read setting value from structure */
	ldr	r4, =ELFIN_MEMCTL_BASE
	ldmia	r0!, {r5-r11}
	stmia	r4!, {r5-r9}

1000:
	ldr	r4, =ELFIN_MEMCTL_BASE
	ldr	r1, [r4, #BANKCON1_OFFSET]
	ldr	r2, =0x40000000			/* DDR DSQInDLL Value Setting */
	orr	r1, r1, r2
	bic	r1, r1, #INIT_MASK

	/* Step 1: issue PALL */
	orr	r2, r1, #INIT_PALL
	str	r2, [r4, #BANKCON1_OFFSET]

	/* Step 2: write 0xff into the refresh timer */
	mov	r3, #0xff
	str	r3, [r4, #REFRESH_OFFSET]

	/* Step 3: wait more than 120 clk */
	mov	r3, #0x100
1:	subs	r3, r3, #1
	bne	1b

	/* Step 4: issue MRS */
	orr	r2, r1, #INIT_MRS
	str	r2, [r4, #BANKCON1_OFFSET]

	/* Step 5: nornal operation value into the refresh timer */
	str	r9, [r4, #REFRESH_OFFSET]

	/* Step 6: issue EMRS */
	orr	r2, r1, #INIT_EMRS
	str	r2, [r4, #BANKCON1_OFFSET]

	/* Step 7: Normal Mode */
	orr	r2, r1, #INIT_NORMAL
	str	r2, [r4, #BANKCON1_OFFSET]

	ldr	r6, =(PHYS_SDRAM_1+0x4)
	ldr	r7, =0x24564236
	swp	r8, r7, [r6]
	swp	r5, r8, [r6]
	cmp	r7, r5
	beq	1001f

	sub	r12, r12, #1
	cmp	r12, #0
	beq	1004f

1002:	stmia	r4!, {r10-r11}
	b	1000b

/* boyko : Memory Type DDR2 */
1004:	ldr	r4, =ELFIN_MEMCTL_BASE

	/* Step 1: BANKCFG Setting */
	ldr	r2, =CFG_BANK_CFG_VAL_DDR2
	str	r2, [r4, #BANKCFG_OFFSET]

	ldr	r1, =0x44000040
	str	r1, [r4, #BANKCON1_OFFSET]

	/* Step 2: BANKCON2 Setting */
	ldr	r2, =CFG_BANK_CON2_VAL_DDR2
	str	r2, [r4, #BANKCON2_OFFSET]

	/* Step 3: issue PALL */
	orr	r2, r1, #INIT_PALL
	str	r2, [r4, #BANKCON1_OFFSET]

	/* Step 4: Issue a EMRS2 command */
	ldr	r2, =0x80000000
	str	r2, [r4, #BANKCON3_OFFSET]

	orr	r2, r1, #INIT_EMRS
	str	r2, [r4, #BANKCON1_OFFSET]

	/* Step 5: Issue a EMRS3 command */
	ldr	r2, =0xc0000000
	str	r2, [r4, #BANKCON3_OFFSET]

	orr	r2, r1, #INIT_EMRS
	str	r2, [r4, #BANKCON1_OFFSET]

	/* Step 6: Issue a EMRS1 command */
	ldr	r2, =0x44000000
	str	r2, [r4, #BANKCON3_OFFSET]

	orr	r2, r1, #INIT_EMRS
	str	r2, [r4, #BANKCON1_OFFSET]

	/* Step 7: issue MRS */
	ldr	r2, =0x44000130
	str	r2, [r4, #BANKCON3_OFFSET]

	orr	r2, r1, #INIT_MRS
	str	r2, [r4, #BANKCON1_OFFSET]

	/* Step 8: issue PALL */
	orr	r2, r1, #INIT_PALL
	str	r2, [r4, #BANKCON1_OFFSET]

	/* Step 9: write 0xff into the refresh timer */
	mov	r3, #0xff
	str	r3, [r4, #REFRESH_OFFSET]

	/* Step 10: wait more than 120 clk */
	mov	r3, #0x200
10:	subs	r3, r3, #1
	bne	10b

	/* Step 11: issue MRS */
	ldr	r2, =0x44000030
	str	r2, [r4, #BANKCON3_OFFSET]

	orr	r2, r1, #INIT_MRS
	str	r2, [r4, #BANKCON1_OFFSET]

	/* Step 12: Issue a EMRS1 command */
	ldr	r2, =0x47800030
	str	r2, [r4, #BANKCON3_OFFSET]

	orr	r2, r1, #INIT_EMRS
	str	r2, [r4, #BANKCON1_OFFSET]

	ldr	r2, =0x44000030
	str	r2, [r4, #BANKCON3_OFFSET]

	orr	r2, r1, #INIT_EMRS
	str	r2, [r4, #BANKCON1_OFFSET]

	/* Step 13: write 0x400 into the refresh timer */
	mov	r3, #0x400
	str	r3, [r4, #REFRESH_OFFSET]

	/* Step 14: Normal Mode */
	orr	r2, r1, #INIT_NORMAL
	str	r2, [r4, #BANKCON1_OFFSET]
/* boyko : END - Memory Type DDR2 */

1001:	mov	pc, lr
