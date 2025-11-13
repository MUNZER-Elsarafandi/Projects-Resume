	.file	"main.c"
	.text
	.globl	MAX_VLAUE
	.section .rdata,"dr"
	.align 4
MAX_VLAUE:
	.long	100
	.globl	PI
	.align 4
PI:
	.long	1078523331
	.def	__main;	.scl	2;	.type	32;	.endef
.LC0:
	.ascii "Value of MAX_VALUE is %d\12\0"
.LC2:
	.ascii "Value of PI is %.2f\12\0"
.LC3:
	.ascii "Value of MIN_VALUE is %d\12\0"
.LC4:
	.ascii "Value of LITERAL is %d\12\0"
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
	movl	$10, -4(%rbp)
	movl	$100, %eax
	movl	%eax, %edx
	leaq	.LC0(%rip), %rax
	movq	%rax, %rcx
	call	printf
	movss	.LC1(%rip), %xmm0
	cvtss2sd	%xmm0, %xmm0
	movq	%xmm0, %rax
	movq	%rax, %rdx
	movq	%rdx, %xmm0
	movapd	%xmm0, %xmm1
	movq	%rax, %rdx
	leaq	.LC2(%rip), %rax
	movq	%rax, %rcx
	call	printf
	movl	-4(%rbp), %eax
	movl	%eax, %edx
	leaq	.LC3(%rip), %rax
	movq	%rax, %rcx
	call	printf
	movl	$16, -8(%rbp)
	movl	-8(%rbp), %eax
	movl	%eax, %edx
	leaq	.LC4(%rip), %rax
	movq	%rax, %rcx
	call	printf
	movl	$0, %eax
	addq	$48, %rsp
	popq	%rbp
	ret
	.seh_endproc
	.section .rdata,"dr"
	.align 4
.LC1:
	.long	1078523331
	.ident	"GCC: (GNU) 13.2.0"
	.def	printf;	.scl	2;	.type	32;	.endef
