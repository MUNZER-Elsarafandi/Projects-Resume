	.file	"main.c"
	.text
	.def	__main;	.scl	2;	.type	32;	.endef
	.section .rdata,"dr"
	.align 8
.LC0:
	.ascii "Enter a number times to loop: \0"
.LC1:
	.ascii "%d\0"
.LC2:
	.ascii "Loop will Run Once\0"
.LC3:
	.ascii "Loop will Run Twice\0"
.LC4:
	.ascii "Loop will Run Trice\0"
	.align 8
.LC5:
	.ascii "Invalid number of loops [ %d ], try between 1 and 3\12\0"
	.align 8
.LC6:
	.ascii "While Loop.......will run [%d] times\12\0"
.LC7:
	.ascii "STARTS:\0"
.LC8:
	.ascii "Loop number %d \12\0"
.LC9:
	.ascii "ENDS:\12\0"
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
	movl	$0, -8(%rbp)
	leaq	.LC0(%rip), %rax
	movq	%rax, %rcx
	call	printf
	leaq	-8(%rbp), %rax
	movq	%rax, %rdx
	leaq	.LC1(%rip), %rax
	movq	%rax, %rcx
	call	scanf
	movl	-8(%rbp), %eax
	cmpl	$3, %eax
	je	.L2
	cmpl	$3, %eax
	jg	.L3
	cmpl	$1, %eax
	je	.L4
	cmpl	$2, %eax
	je	.L5
	jmp	.L3
.L4:
	leaq	.LC2(%rip), %rax
	movq	%rax, %rcx
	call	puts
	jmp	.L6
.L5:
	leaq	.LC3(%rip), %rax
	movq	%rax, %rcx
	call	puts
	jmp	.L6
.L2:
	leaq	.LC4(%rip), %rax
	movq	%rax, %rcx
	call	puts
	jmp	.L6
.L3:
	movl	-8(%rbp), %eax
	movl	%eax, %edx
	leaq	.LC5(%rip), %rax
	movq	%rax, %rcx
	call	printf
	movl	$0, -8(%rbp)
.L6:
	movl	-8(%rbp), %eax
	testl	%eax, %eax
	jle	.L7
	movl	-8(%rbp), %eax
	cmpl	$3, %eax
	jg	.L7
	movl	-8(%rbp), %eax
	movl	%eax, %edx
	leaq	.LC6(%rip), %rax
	movq	%rax, %rcx
	call	printf
	leaq	.LC7(%rip), %rax
	movq	%rax, %rcx
	call	puts
	jmp	.L8
.L9:
	movl	-4(%rbp), %eax
	movl	%eax, %edx
	leaq	.LC8(%rip), %rax
	movq	%rax, %rcx
	call	printf
	addl	$1, -4(%rbp)
.L8:
	movl	-8(%rbp), %eax
	cmpl	%eax, -4(%rbp)
	jl	.L9
	leaq	.LC9(%rip), %rax
	movq	%rax, %rcx
	call	puts
.L7:
	movl	$0, %eax
	addq	$48, %rsp
	popq	%rbp
	ret
	.seh_endproc
	.ident	"GCC: (GNU) 13.2.0"
	.def	printf;	.scl	2;	.type	32;	.endef
	.def	scanf;	.scl	2;	.type	32;	.endef
	.def	puts;	.scl	2;	.type	32;	.endef
