
.bss
	a: .skip 80000000
	b: .skip 80000000
	c: .skip 80000000

.text
	calculating:	.asciz "\nCalculating speed...\n\n"
	header:		.asciz "Test |  Best MBp/s |   Avg time   |   Min time   |   Max time   |\n"
	separator:	.asciz "-----+-------------+--------------+--------------+--------------|\n"
	copytime: 	.asciz "Copy |   %d.%d	   |   %d.%06d   |   %d.%06d   |   %d.%06d   |\n"
	scaletime: 	.asciz "Scale|   %d.%d	   |   %d.%06d   |   %d.%06d   |   %d.%06d   |\n"
	addtime: 	.asciz "Add  |   %d.%d	   |   %d.%06d   |   %d.%06d   |   %d.%06d   |\n"
	Triadtime: 	.asciz "Triad|   %d.%d	   |   %d.%06d   |   %d.%06d   |   %d.%06d   |\n"
	done:		.asciz "\nDone\n"
.global _main

_main:				# int main() 
	push %rbp
	movq %rsp, %rbp

	leaq calculating(%rip), %rdi
	xorq %rax, %rax
	call _printf

	call Copy_test
	call Scale_test
	call Add_test
	call Triad_test

	leaq header(%rip), %rdi
	xorq %rax, %rax
	call _printf

	leaq separator(%rip), %rdi
	xorq %rax, %rax
	call _printf

	leaq copytime(%rip), %rdi
	leaq _copy(%rip), %rsi
	movq $160000000, %rdx
	call Print_result

	
	leaq scaletime(%rip), %rdi
	leaq _scale(%rip), %rsi
	movq $160000000, %rdx
	call Print_result

	leaq addtime(%rip), %rdi
	leaq _add(%rip), %rsi
	movq $240000000, %rdx
	call Print_result

	leaq Triadtime(%rip), %rdi
	leaq _triad(%rip), %rsi
	movq $240000000, %rdx
	call Print_result


	leaq done(%rip), %rdi
	xorq %rax, %rax
	call _printf

	movq $0, %rdi
	xor %rax, %rax
	call _exit		# return 0

Print_result:
	push %rbp
	movq %rsp, %rbp

	subq $80, %rsp
	movq %rsi, %r9
	movq %rdx, %r8


	movq (%r9), %rax	#AVG
	movq $10, %rsi
	xorq %rdx, %rdx
	divq %rsi
	xorq %rdx, %rdx
	movq $100000, %rsi
	divq %rsi
	
	movq %rax, -8(%rbp)
	movq %rdx, -16(%rbp)

	movq 8(%r9), %rax	#MIN
	xorq %rdx, %rdx
	movq $100000, %rsi
	divq %rsi

	movq %rax, -24(%rbp)
	movq %rdx, -32(%rbp)


	movq %r8, %rax		#MBP/S
	xorq %rdx, %rdx
	movq 8(%r9), %rsi
	divq %rsi

	movq %rax, -40(%rbp)

	movq %rdx, %rax		#Save only one decimal
	xorq %rdx, %rdx
	movq $10000, %rsi
	divq %rsi

	movq %rax, -48(%rbp)

	movq 16(%r9), %rax	#MAX
	xorq %rdx, %rdx
	movq $100000, %rsi
	divq %rsi

	movq %rax, -56(%rbp)
	movq %rdx, -64(%rbp)


	movq -40(%rbp), %rsi
	movq -48(%rbp), %rdx
	movq -8(%rbp), %rcx	
	movq -16(%rbp), %r8
	movq -24(%rbp), %r9	
	movq -32(%rbp), %rax
	movq %rax, (%rsp)
	movq -56(%rbp), %rax
	movq %rax, 8(%rsp)
	movq -64(%rbp), %rax
	movq %rax, 16(%rsp)
	xorq %rax, %rax
	call _printf

	addq $80, %rsp
	

	movq %rbp, %rsp
	popq %rbp
	ret

Copy_test:
	push %rbp
	movq %rsp, %rbp
	subq $16, %rsp

	movq $0, %r8		# i = 0
Copy_loop0:
	call init_buffers

	movq $0, %rbx		# j = 0
	callq _clock
	movq %rax, -8(%rbp)
	leaq b(%rip), %rdx
	leaq c(%rip), %rcx
Copy_loop1:
	movq (%rdx,%rbx,8), %rsi
	movq %rsi, (%rcx,%rbx,8)
	incq %rbx
	cmpq $10000000, %rbx
	jl Copy_loop1

	call _clock
	subq -8(%rbp), %rax
	addq %rax, _copy(%rip)

	cmpq $0, _copy+8(%rip)
	je Copy_min_time
	cmpq %rax, _copy+8(%rip)
	jl Copy_max_time	# min_time < time
Copy_min_time:
	movq %rax, _copy+8(%rip)
Copy_max_time:
	cmpq %rax,_copy+16(%rip)
	jg Copy_not_time
	movq %rax, _copy+16(%rip)
Copy_not_time:

	incq %r8
	cmpq $10, %r8
	jl Copy_loop0

	addq $16, %rsp
	movq %rbp, %rsp
	popq %rbp
	ret


Scale_test:
	push %rbp
	movq %rsp, %rbp
	subq $32, %rsp

	movq $0, %r8		# i = 0

Scale_loop0:
	call init_buffers

	movq $0, %rbx		# j = 0
	callq _clock
	movq %rax, -8(%rbp)
	leaq c(%rip), %rdx
	leaq b(%rip), %rcx
Scale_loop1:
	imulq $3, (%rdx,%rbx,8), %rsi
	movq %rsi, (%rcx,%rbx,8)
	incq %rbx
	cmpq $10000000, %rbx
	jl Scale_loop1

	call _clock
	subq -8(%rbp), %rax
	addq %rax, _scale(%rip)

	cmpq $0, _scale+8(%rip)
	je Scale_min_time
	cmpq %rax, _scale+8(%rip)
	jl Scale_max_time	# min_time < time
Scale_min_time:
	movq %rax, _scale+8(%rip)
Scale_max_time:
	cmpq %rax, _scale+16(%rip)
	jg Scale_not_time
	movq %rax, _scale+16(%rip)
Scale_not_time:

	incq %r8
	cmpq $10, %r8
	jl Scale_loop0
	
	addq $32, %rsp
	movq %rbp, %rsp
	popq %rbp
	ret

Add_test:
	push %rbp
	movq %rsp, %rbp
	subq $32, %rsp

	movq $0, %r8		# i = 0
	movq $3, -24(%rbp)	# scale = 3
Add_loop0:
	call init_buffers

	movq $0, %rbx		# j = 0
	callq _clock
	movq %rax, -8(%rbp)
	leaq b(%rip), %rdx
	leaq a(%rip), %rcx
	leaq c(%rip), %rdi
Add_loop1:
	movq (%rdx,%rbx,8), %rsi
	addq (%rcx,%rbx,8), %rsi
	movq %rsi, (%rdi, %rbx, 8)
	incq %rbx
	cmpq $10000000, %rbx
	jl Add_loop1

	call _clock
	subq -8(%rbp), %rax
	addq %rax, _add(%rip)

	cmpq $0, _add+8(%rip)
	je Add_min_time
	cmpq %rax, _add+8(%rip)
	jl Add_max_time	# min_time < time
Add_min_time:
	movq %rax, _add+8(%rip)
Add_max_time:
	cmpq %rax, _add+16(%rip)
	jg Add_not_time
	movq %rax, _add+16(%rip)
Add_not_time:

	incq %r8
	cmpq $10, %r8
	jl Add_loop0
	
	addq $32, %rsp
	movq %rbp, %rsp
	popq %rbp
	ret

Triad_test:
	push %rbp
	movq %rsp, %rbp
	subq $32, %rsp

	movq $0, %r8		# i = 0
	movq $3, -24(%rbp)	# scale = 3
Triad_loop0:
	call init_buffers

	movq $0, %rbx		# j = 0
	callq _clock
	movq %rax, -8(%rbp)
	leaq b(%rip), %rdx
	leaq a(%rip), %rcx
	leaq c(%rip), %rdi
Triad_loop1:
	imulq $3, (%rdi,%rbx,8), %rsi
	addq (%rdx, %rbx, 8), %rsi
	movq %rsi, (%rcx, %rbx, 8)
	incq %rbx
	cmpq $10000000, %rbx
	jl Triad_loop1

	call _clock
	subq -8(%rbp), %rax
	addq %rax, _triad(%rip)

	cmpq $0, _triad+8(%rip)
	je Triad_min_time
	cmpq %rax, _triad+8(%rip)
	jl Triad_max_time	# min_time < time
Triad_min_time:
	movq %rax, _triad+8(%rip)
Triad_max_time:
	cmpq %rax, _triad+16(%rip)
	jg Triad_not_time
	movq %rax, _triad+16(%rip)
Triad_not_time:

	incq %r8
	cmpq $10, %r8
	jl Triad_loop0
	
	addq $32, %rsp
	movq %rbp, %rsp
	popq %rbp
	ret


init_buffers:
	push %rbp
	movq %rsp, %rbp

	movq $1, %rax
	movq $10000000, %rcx
	leaq a(%rip), %rdi
	rep stosq

	movq $2, %rax
	movq $10000000, %rcx
	leaq b(%rip), %rdi
	rep stosq

	movq $3, %rax
	movq $10000000, %rcx
	leaq c(%rip), %rdi
	rep stosq
	
	movq %rbp, %rsp
	popq %rbp
	ret

	.globl	_copy                    ## @avg
.zerofill __DATA,__common,_copy,24,4
	.globl	_scale                   ## @avg
.zerofill __DATA,__common,_scale,24,4
	.globl	_add                   ## @avg
.zerofill __DATA,__common,_add,24,4
	.globl	_triad                   ## @avg
.zerofill __DATA,__common,_triad,24,4
