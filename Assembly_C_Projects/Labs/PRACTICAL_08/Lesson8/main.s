	.file	"main.c"
	.text
	.def	__main;	.scl	2;	.type	32;	.endef
	.section .rdata,"dr"
.LC0:
	.ascii "false\0"
.LC1:
	.ascii "true\0"
.LC2:
	.ascii "a & b Example: %s\12\0"
.LC3:
	.ascii "a | b Example: %s\12\0"
.LC4:
	.ascii "a ^ b Example: %s\12\0"
.LC5:
	.ascii "a << b Example: %d\12\0"
.LC6:
	.ascii "a >> b Example: %d\12\0"
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
	andl	-8(%rbp), %eax
	testl	%eax, %eax
	setne	%al
	movb	%al, -9(%rbp)
	movzbl	-9(%rbp), %eax
	xorl	$1, %eax
	testb	%al, %al
	je	.L2
	leaq	.LC0(%rip), %rax
	jmp	.L3
.L2:
	leaq	.LC1(%rip), %rax
.L3:
	movq	%rax, %rdx
	leaq	.LC2(%rip), %rax
	movq	%rax, %rcx
	call	printf
	movl	-4(%rbp), %eax
	orl	-8(%rbp), %eax
	testl	%eax, %eax
	setne	%al
	movb	%al, -9(%rbp)
	movzbl	-9(%rbp), %eax
	xorl	$1, %eax
	testb	%al, %al
	je	.L4
	leaq	.LC0(%rip), %rax
	jmp	.L5
.L4:
	leaq	.LC1(%rip), %rax
.L5:
	movq	%rax, %rdx
	leaq	.LC3(%rip), %rax
	movq	%rax, %rcx
	call	printf
	movl	-4(%rbp), %eax
	xorl	-8(%rbp), %eax
	testl	%eax, %eax
	setne	%al
	movb	%al, -9(%rbp)
	movzbl	-9(%rbp), %eax
	xorl	$1, %eax
	testb	%al, %al
	je	.L6
	leaq	.LC0(%rip), %rax
	jmp	.L7
.L6:
	leaq	.LC1(%rip), %rax
.L7:
	movq	%rax, %rdx
	leaq	.LC4(%rip), %rax
	movq	%rax, %rcx
	call	printf
	movl	-4(%rbp), %eax
	movl	$15, %edx
	movl	%eax, %ecx
	sall	%cl, %edx
	movl	%edx, %eax
	movl	%eax, -16(%rbp)
	movl	-16(%rbp), %eax
	movl	%eax, %edx
	leaq	.LC5(%rip), %rax
	movq	%rax, %rcx
	call	printf
	movl	-4(%rbp), %eax
	movl	%eax, %ecx
	sarl	%cl, -16(%rbp)
	movl	-16(%rbp), %eax
	movl	%eax, %edx
	leaq	.LC6(%rip), %rax
	movq	%rax, %rcx
	call	printf
	movl	$0, %eax
	addq	$48, %rsp
	popq	%rbp
	ret
	.seh_endproc
	.ident	"GCC: (GNU) 13.2.0"
	.def	printf;	.scl	2;	.type	32;	.endef
