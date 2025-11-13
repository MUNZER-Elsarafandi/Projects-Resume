	.file	"main.c"
	.text
	.def	__main;	.scl	2;	.type	32;	.endef
	.section .rdata,"dr"
.LC0:
	.ascii "a > b \0"
.LC1:
	.ascii "a == 1\0"
.LC2:
	.ascii "a != 1\0"
.LC3:
	.ascii "a !> b \0"
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
	movl	$1, -4(%rbp)
	movl	$0, -8(%rbp)
	movl	-4(%rbp), %eax
	cmpl	-8(%rbp), %eax
	jle	.L2
	leaq	.LC0(%rip), %rax
	movq	%rax, %rcx
	call	puts
	cmpl	$1, -4(%rbp)
	jne	.L3
	leaq	.LC1(%rip), %rax
	movq	%rax, %rcx
	call	puts
	jmp	.L4
.L3:
	leaq	.LC2(%rip), %rax
	movq	%rax, %rcx
	call	puts
	jmp	.L4
.L2:
	leaq	.LC3(%rip), %rax
	movq	%rax, %rcx
	call	puts
.L4:
	movl	$0, %eax
	addq	$48, %rsp
	popq	%rbp
	ret
	.seh_endproc
	.ident	"GCC: (GNU) 13.2.0"
	.def	puts;	.scl	2;	.type	32;	.endef
