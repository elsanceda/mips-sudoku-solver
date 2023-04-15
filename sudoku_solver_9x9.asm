# CS 21 Lab 2 -- S2 AY 2021-2022
# Ieiaiel G. Sanceda -- 05/01/2022
# 202003890_9.asm -- an implementation of a 9x9 Sudoku Solver

.macro	do_syscall(%n)					# performs syscalls
		li	$v0, %n
		syscall
.end_macro

.macro 	newline						# prints newline character
		li 	$a0, 10
		do_syscall(11)
.end_macro

.macro	read_row(%n)					# reads each row as an integer and saves it in array
		do_syscall(5)				# read row
		move	$a0, $v0		
		jal	get_row				# store each digit in the row in an array
		sw	$v0, %n(grid)			# store the row in the grid
.end_macro

.macro	get_elem(%elem, %index, %addr, %base)		# get a specific element from the grid
		addu	%addr, %index, %base		# %addr = address of the element
		lw	%elem, (%addr)			# %elem = element
.end_macro

.macro	box_coord(%coord, %box)			# finds the coords of the box the square is part of
		div	%box, %coord, 12		# %box = %coord // 12
		li	$t0, 12				# $t0 = 12
		mult	%box, $t0			# %box * 12
		mflo	%box				# %box = %box * 12
.end_macro

.eqv	grid	$s0
.eqv	row0	$t6
.eqv	col0	$t7

.text
main:
		li	$a0, 36				# allocates memory for an array
		do_syscall(9)				# this array will store the entire grid
		move	grid, $v0			# grid = pointer to the first element in the array
		
		read_row(0)				# read 1st row of the grid
		read_row(4)				# read 2nd row of the grid
		read_row(8)				# read 3rd row of the grid
		read_row(12)				# read 4th row of the grid
		read_row(16)				# read 5th row of the grid
		read_row(20)				# read 6th row of the grid
		read_row(24)				# read 7th row of the grid
		read_row(28)				# read 8th row of the grid
		read_row(32)				# read 9th row of the grid
		
		move	$a0, grid			# $a0 = grid
		li	$a1, 0				# $a1 = row = 0
		li	$a2, 0				# $a2 = col = 0
		jal	solve				# solve the rest of the grid
		
		move	$a0, grid			# $a0 = grid
		jal	print_grid			# print the grid
		
		do_syscall(10)


get_row:	#####preamble######			# arguments: $a0 = row in the form of an integer
		subu 	$sp, $sp, 8
		sw	$s0, 4($sp)		
		sw 	$ra, 0($sp)	
		#####preamble######
		
		move	$t0, $a0			# $t0 = $a0
		li	$a0, 36				# allocates memory for an array
		do_syscall(9)				# this array will store the numbers in the row
		move	$s0, $v0			# $s0 = array
		
		li	$t1, 9				# $t1 = 9
		li	$t2, 32				# $t2 = 32			
gr_loop:	
		beqz	$t1, gr_ret			# $t1 = 0, exit loop
		div	$t0, $t0, 10			# $t0 = $t0 / 10
		mfhi	$t3				# $t3 = remainder
		addu	$t4, $t2, $s0			# prepares address in memory for digit to be stored in
		sw	$t3, ($t4)			# store digit in array
		subi	$t1, $t1, 1			# $t1 = $t1 - 1
		subi	$t2, $t2, 4			# $t2 = $t2 - 4
		j	gr_loop				# loop gr_loop

gr_ret:		move	$v0, $s0			# return the array

		#####end######
		lw	$s0, 4($sp)		
		lw 	$ra, 0($sp)
		addu 	$sp, $sp, 8
		#####end######
		jr	$ra

		
check:		#####preamble######			# arguments: $a0 = row, $a1 = col, $a2 = n, $a3 = grid
		subu 	$sp, $sp, 8
		sw	$s0, 4($sp)		
		sw 	$ra, 0($sp)	
		#####preamble######
		
		move	grid, $a3			# grid = $a3
		get_elem($t3, $a0, $t2, grid)		# $t3 = grid[row]
		li	$t0, 32				# $t0 = 32
		li	$t1, 0				# $t1 = 0
check_row:	
		bgt	$t1, $t0, cr_exit		# if $t1 > 32, exit loop
		get_elem($t5, $t1, $t4, $t3)		# $t5 = grid[row][$t1] 
		beq	$t5, $a2, check_ret_f		# if grid[row][$t1] == n, return false
		addiu	$t1, $t1, 4			# $t1 = $t1 + 4
		j	check_row			# loop check_row
	
cr_exit:	li	$t1, 0				# $t1 = 0
check_column:
		bgt	$t1, $t0, cc_exit		# if $t1 > 32, exit loop
		get_elem($t3, $t1, $t2, grid)		# $t3 = grid[$t1]
		get_elem($t5, $a1, $t4, $t3)		# $t5 = grid[$t1][col]
		beq	$t5, $a2, check_ret_f		# if grid[$t1][col] == n, return false
		addiu	$t1, $t1, 4			# $t1 = $t1 + 4
		j	check_column			# loop check_column

cc_exit:	box_coord($a0, row0)			# find the row of the 3x3 box the given square belongs to
		box_coord($a1, col0)			# find the col of the 3x3 box the given square belongs to

		li	$t0, 8				# $t0 = 8
		li	$t1, 0				# $t0 = 0
		li	$t2, 0				# $t2 = 0
check_box:
		bgt	$t1, $t0, check_ret_t		# if $t1 > 8, return true
check_box2:
		bgt	$t2, $t0, ext_cs2		# if $t2 > 8, exit check_box2
		addu	$t3, $t1, row0			# $t3 = $t1 + row0
		get_elem($t5, $t3, $t4, grid)		# $t5 = grid[$t1 + row0]
		addu	$t3, $t2, col0			# $t3 = $t2 + col0
		get_elem($t5, $t3, $t4, $t5)		# $t5 = grid[$t1 + row0][$t2 + col0}
		beq	$t5, $a2, check_ret_f		# if grid[$t1 + row0][$t2 + col0] == n, return false
		addiu	$t2, $t2, 4			# $t2 = $t2 + 4
		j	check_box2			# loop check_box2
		
ext_cs2:	li	$t2, 0				# $t2 = 0
		add	$t1, $t1, 4			# $t1 = $t1 + 4
		j	check_box

check_ret_f:	li	$v0, 0				# return false
		j	check_ret
		
check_ret_t:	li	$v0, 1				# return true
		j	check_ret

check_ret:	#####end######		
		lw	$s0, 4($sp)
		lw 	$ra, 0($sp)
		addu 	$sp, $sp, 8
		#####end######
		jr	$ra


solve:		#####preamble######			# arguments: $a0 = grid, $a1 = row, $a2 = col
		subu 	$sp, $sp, 24
		sw	$s0, 20($sp)
		sw	$s1, 16($sp)
		sw	$s2, 12($sp)
		sw	$s3, 8($sp)
		sw	$s4, 4($sp)
		sw 	$ra, 0($sp)	
		#####preamble######
		
		move	grid, $a0			# grid = $a0
		move	$s1, $a1			# $s1 = row
		move	$s2, $a2			# $s2 = col

solve_row:
		bgt	$s1, 32, solve_ret_t		# if $s1 > 32, return true to prevent backtracking
solve_col:
		bgt	$s2, 32, ext_solve_col		# if $s2 > 32, exit solve_col
		get_elem($t1, $s1, $t0, grid)		# $t1 = grid[row]
		get_elem($t1, $s2, $s3, $t1)		# $t1 = grid[row][col]
		beqz	$t1, check_n			# if grid[row][col] == 0, check for possible values of n
		add	$s2, $s2, 4			# $s2 = $s2 + 4
		j	solve_col			# loop solve_col

ext_solve_col:	li	$s2, 0				# $s2 = 0
		add	$s1, $s1, 4			# $s1 = $s1 + 4
		j	solve_row		
		
check_n:	li	$s4, 1				# n = 1
check_n_loop:
		bgt	$s4, 9, solve_ret_f		# if n > 9, return false to backtrack
		move	$a0, $s1			# $a0 = row
		move	$a1, $s2			# $a1 = col
		move	$a2, $s4			# $a2 = n
		move	$a3, grid			# $a3 = grid
		jal	check				# check if it is possible to place n in grid[row][col]
		li	$t2, 1				# $t2 = 1
		beq	$v0, $t2, place_n		# if it is possible to place n in grid[row][col], place n
loop_cnl:	add	$s4, $s4, 1			# n = n + 1
		j	check_n_loop			# loop check_n_loop
place_n:
		sw	$s4, ($s3)			# grid[row][col] == n
		move	$a0, grid			# $a0 = grid
		move	$a1, $s1			# $a1 = row
		add	$a2, $s2, 4			# $a2 = next col
		bgt	$a2, 32, next_row		# if $a2 > 32, j next_row
call_solve:	jal	solve				# solve the rest of the grid
		beqz	$v0, backtrack			# if we return false, backtrack
		j	solve_ret_t			# else if we return true, return true again

next_row:	add	$a1, $s1, 4			# $a1 = next row
		li	$a2, 0				# $a2 = col 0
		j	call_solve			# j call_solve

backtrack:	sw	$zero, ($s3)			# grid[row][col] == 0
		j	loop_cnl			# check the next value of n

solve_ret_t:	li	$v0, 1				# return true
		j	solve_ret
		
solve_ret_f:	li	$v0, 0				# return false
		j	solve_ret
		
solve_ret:	#####end######		
		lw	$s0, 20($sp)
		lw	$s1, 16($sp)
		lw	$s2, 12($sp)
		lw	$s3, 8($sp)
		lw	$s4, 4($sp)
		lw 	$ra, 0($sp)
		addu 	$sp, $sp, 24
		#####end######
		jr	$ra
		
		
print_grid:	#####preamble######			# arguments: $a0 = grid
		subu 	$sp, $sp, 8
		sw	$s0, 4($sp)		
		sw 	$ra, 0($sp)	
		#####preamble######
		
		move	grid, $a0			# grid = $a0
		li	$s1, 0				# $s1 = 0
		li	$s2, 0				# $s2 = 0

		newline					# print newline
loop_row:
		bgt	$s1, 32, print_ret		# if $s1 > 32, return
loop_col:
		bgt	$s2, 32, ext_loop_col		# if $s2 > 32, exit loop_col
		get_elem($t1, $s1, $t0, grid)		# $t1 = grid[row]
		get_elem($a0, $s2, $t2, $t1)		# $a0 = grid[row][col]
		do_syscall(1)				# print grid[row][col]
		add	$s2, $s2, 4			# $s2 = $s2 + 4
		j	loop_col			# loop loop_col

ext_loop_col:	newline					# print newline
		li	$s2, 0				# $s2 = 0
		add	$s1, $s1, 4			# $s1 = $s1 + 4
		j	loop_row		

print_ret:	#####end######
		lw	$s0, 4($sp)		
		lw 	$ra, 0($sp)
		addu 	$sp, $sp, 8
		#####end######
		jr	$ra		
		
		
		
		
