	.file	"main.c"
	.text
	.def	__main;	.scl	2;	.type	32;	.endef
	.section .rdata,"dr"
.LC0:
	.ascii "false\0"
.LC1:
	.ascii "true\0"
.LC2:
	.ascii "a > b Example: %s\12\0"
.LC3:
	.ascii "a < b Example: %s\12\0"
.LC4:
	.ascii "a >= b Example: %s\12\0"
.LC5:
	.ascii "a <= b Example: %s\12\0"
.LC6:
	.ascii "a == b Example: %s\12\0"
.LC7:
	.ascii "a != b Example: %s\12\0"
.LC8:
	.ascii "a && b Example: %s\12\0"
.LC9:
	.ascii "a || b Example: %s\12\0"
.LC10:
	.ascii "!a Example: %s\12\0"
.LC11:
	.ascii "a!! Example: %s\12\0"
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
	movl	$20, -8(%rbp)
	movl	-4(%rbp), %eax
	cmpl	-8(%rbp), %eax
	setg	%al
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
	cmpl	-8(%rbp), %eax
	setl	%al
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
	cmpl	-8(%rbp), %eax
	setge	%al
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
	cmpl	-8(%rbp), %eax
	setle	%al
	movb	%al, -9(%rbp)
	movzbl	-9(%rbp), %eax
	xorl	$1, %eax
	testb	%al, %al
	je	.L8
	leaq	.LC0(%rip), %rax
	jmp	.L9
.L8:
	leaq	.LC1(%rip), %rax
.L9:
	movq	%rax, %rdx
	leaq	.LC5(%rip), %rax
	movq	%rax, %rcx
	call	printf
	movl	-4(%rbp), %eax
	cmpl	-8(%rbp), %eax
	sete	%al
	movb	%al, -9(%rbp)
	movzbl	-9(%rbp), %eax
	xorl	$1, %eax
	testb	%al, %al
	je	.L10
	leaq	.LC0(%rip), %rax
	jmp	.L11
.L10:
	leaq	.LC1(%rip), %rax
.L11:
	movq	%rax, %rdx
	leaq	.LC6(%rip), %rax
	movq	%rax, %rcx
	call	printf
	movl	-4(%rbp), %eax
	cmpl	-8(%rbp), %eax
	setne	%al
	movb	%al, -9(%rbp)
	movzbl	-9(%rbp), %eax
	xorl	$1, %eax
	testb	%al, %al
	je	.L12
	leaq	.LC0(%rip), %rax
	jmp	.L13
.L12:
	leaq	.LC1(%rip), %rax
.L13:
	movq	%rax, %rdx
	leaq	.LC7(%rip), %rax
	movq	%rax, %rcx
	call	printf
	cmpl	$0, -4(%rbp)
	je	.L14
	cmpl	$0, -8(%rbp)
	je	.L14
	movl	$1, %eax
	jmp	.L15
.L14:
	movl	$0, %eax
.L15:
	movb	%al, -9(%rbp)
	andb	$1, -9(%rbp)
	movzbl	-9(%rbp), %eax
	xorl	$1, %eax
	testb	%al, %al
	je	.L16
	leaq	.LC0(%rip), %rax
	jmp	.L17
.L16:
	leaq	.LC1(%rip), %rax
.L17:
	movq	%rax, %rdx
	leaq	.LC8(%rip), %rax
	movq	%rax, %rcx
	call	printf
	cmpl	$0, -4(%rbp)
	jne	.L18
	cmpl	$0, -8(%rbp)
	je	.L19
.L18:
	movl	$1, %eax
	jmp	.L20
.L19:
	movl	$0, %eax
.L20:
	movb	%al, -9(%rbp)
	andb	$1, -9(%rbp)
	movzbl	-9(%rbp), %eax
	xorl	$1, %eax
	testb	%al, %al
	je	.L21
	leaq	.LC0(%rip), %rax
	jmp	.L22
.L21:
	leaq	.LC1(%rip), %rax
.L22:
	movq	%rax, %rdx
	leaq	.LC9(%rip), %rax
	movq	%rax, %rcx
	call	printf
	cmpl	$0, -4(%rbp)
	sete	%al
	movb	%al, -9(%rbp)
	movzbl	-9(%rbp), %eax
	xorl	$1, %eax
	testb	%al, %al
	je	.L23
	leaq	.LC0(%rip), %rax
	jmp	.L24
.L23:
	leaq	.LC1(%rip), %rax
.L24:
	movq	%rax, %rdx
	leaq	.LC10(%rip), %rax
	movq	%rax, %rcx
	call	printf
	cmpl	$0, -4(%rbp)
	setne	%al
	movb	%al, -9(%rbp)
	movzbl	-9(%rbp), %eax
	xorl	$1, %eax
	testb	%al, %al
	je	.L25
	leaq	.LC0(%rip), %rax
	jmp	.L26
.L25:
	leaq	.LC1(%rip), %rax
.L26:
	movq	%rax, %rdx
	leaq	.LC11(%rip), %rax
	movq	%rax, %rcx
	call	printf
	movl	$0, %eax
	addq	$48, %rsp
	popq	%rbp
	ret
	.seh_endproc
	.ident	"GCC: (GNU) 13.2.0"
	.def	printf;	.scl	2;	.type	32;	.endef
