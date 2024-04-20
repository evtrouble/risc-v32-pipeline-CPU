#################################################
#	x2		stack pointer
#	x5		return addr
#	x6		31
#	x7		fib(31)
#################################################
#	fib(n)
#		n		fib			n		fib
#		0		0x1			16		0x63d
#		1		0x1			17		0xa18
#		2		0x2			18		0x1055
#		3		0x3			19		0x1a6d
#		4		0x5			20		0x2ac2
#		5		0x8			21		0x452f
#		6		0xd			22		0x6ff1
#		7		0x15			23		0xb520
#		8		0x22			24		0x12511
#		9		0x37			25		0x1da31
#		10		0x59			26		0x2ff42
#		11		0x90			27		0x4d973
#		12		0xe9			28		0x7d8b5
#		13		0x179			29		0xcb228
#		14		0x262			30		0x148add
#		15		0x3db			31		0x213d05
#################################################
#	the instructions in instr.coe

	addi	x4,x0,0
	addi	x20,x0,0x7C
	sb	x20,1(x4)

main:
	lw	x6, 0(x4)
	srli	x6, x6, 10
	andi	x6, x6, 0x01F
    	addi	x7, x7, 1
   	addi	x8, x0, -1
   	addi	x9, x0, 0
	jal	x5, fib
	sw	x7, 4(x4)
   	jal	x0, return

fib:
	addi	x8, x8, 1
	bge	x8, x6, ret
    	add	x10, x7, x0
    	add	x7, x7, x9
   	add	x9, x10, x0
	jal	fib
ret:
	jalr	x0, x5, 0
return:
