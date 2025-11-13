	.file	"main.c"
	.text
	.globl	MAX_VALUE
	.section .rdata,"dr"
	.align 4
MAX_VALUE:
	.long	3
	.def	__main;	.scl	2;	.type	32;	.endef
.LC0:
	.ascii "While Loop.......\0"
.LC1:
	.ascii "STARTS:\0"
.LC2:
	.ascii "Loop number %d \12\0"
.LC3:
	.ascii "ENDS:\12\0"
.LC4:
	.ascii "Do-While.........\0"
.LC5:
	.ascii "\12For Loop.....\0"
.LC6:
	.ascii "ENDS:\0"
	.text
	.globl	main
	.def	main;	.scl	2;	.type	32;	.endef
	.seh_proc	main
main:
	pushq	%rbp
	.seh_pushreg	%rbp
	movq	%rsp, %rbp
	.seh_setframe	%rbp, 0
	subq	$48, %rsp
	.seh_stackalloc	48
	.seh_endprologue
	call	__main
	movl	$0, -4(%rbp)
	leaq	.LC0(%rip), %rax
	movq	%rax, %rcx
	call	puts
	leaq	.LC1(%rip), %rax
	movq	%rax, %rcx
	call	puts
	jmp	.L2
.L3:
	movl	-4(%rbp), %eax
	movl	%eax, %edx
	leaq	.LC2(%rip), %rax
	movq	%rax, %rcx
	call	printf
	addl	$1, -4(%rbp)
.L2:
	movl	$3, %eax
	cmpl	%eax, -4(%rbp)
	jl	.L3
	leaq	.LC3(%rip), %rax
	movq	%rax, %rcx
	call	puts
	movl	$0, -4(%rbp)
	leaq	.LC4(%rip), %rax
	movq	%rax, %rcx
	call	puts
	leaq	.LC1(%rip), %rax
	movq	%rax, %rcx
	call	puts
.L4:
	movl	-4(%rbp), %eax
	movl	%eax, %edx
	leaq	.LC2(%rip), %rax
	movq	%rax, %rcx
	call	printf
	addl	$1, -4(%rbp)
	movl	$3, %eax
	cmpl	%eax, -4(%rbp)
	jl	.L4
	leaq	.LC3(%rip), %rax
	movq	%rax, %rcx
	call	puts
	leaq	.LC5(%rip), %rax
	movq	%rax, %rcx
	call	puts
	leaq	.LC1(%rip), %rax
	movq	%rax, %rcx
	call	puts
	movl	$0, -4(%rbp)
	jmp	.L5
.L6:
	movl	-4(%rbp), %eax
	movl	%eax, %edx
	leaq	.LC2(%rip), %rax
	movq	%rax, %rcx
	call	printf
	addl	$1, -4(%rbp)
.L5:
	movl	$3, %eax
	cmpl	%eax, -4(%rbp)
	jl	.L6
	leaq	.LC6(%rip), %rax
	movq	%rax, %rcx
	call	puts
	movl	$0, %eax
	addq	$48, %rsp
	popq	%rbp
	ret
	.seh_endproc
	.ident	"GCC: (GNU) 13.2.0"
	.def	puts;	.scl	2;	.type	32;	.endef
	.def	printf;	.scl	2;	.type	32;	.endef
