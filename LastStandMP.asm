title Game2

; Claude Marvin P. Serrano
; Game2.asm

.model small
.data
	borderl db 20
	borderr db 22
	warhead db 21
	warheaddw dw 21
	proj db 22
	proj2 db 23
	traj db 21
	blockrow db 1
	blockrowdw dw 1
	FINAL_BASE db 24
	FINAL_HEAD db 23
	outofbounds db 0
	noleft db 0
	noright db 0
	delaytime db 1
	prev db ?
	biter db 0
	delayer db 3
	coords db 1720 dup(?)
	coordsmult dw 0
	localinc db 0
	localtemp dw 0
	dwinc dw 0
	delaycounter db 0
	hit db 0
	projdw dw 22
	trajdw dw 21
	updater db 0
	checker db 0
	iterations db 0
	itsover db 0
	overiterator db 0
	startgame db 0
	playmsg db 'PLAY :', '$'
	easymsg db '-EASY-', '$'
	moderatemsg db '-MODERATE-', '$'
	hardmsg db '-HARD-', '$'
	cursor db 'O=>', '$'
	difficulty db '==DIFFICULTY==', '$'
	scoremsg db '==SCORE==', '$'
	gameovermsg db 'G A M E O V E R', '$'
	youwonmsg db 'Y O U W O N ! !', '$'
	hiscoremsg db '==HIGHSCORE==', '$'
	statsmsg db '==STATS==', '$'
	cursorrow db 15
	easycol db 59
	moderatecol db 56
	hardcol db 56
	selected db 0
	direction db 0
	score dw 0
	blockdelay db 0
	result db 5 dup(0)	
	winner db 0
	filename db 'HSCR.txt', '$'
	buffer db 4 dup("0")
	hiscore db 4 dup(0)
	handle dw 0
	nobytes dw ?	
.stack 100h
.code
	main proc
	
	; Clearing data
	mov ax, @data
	mov ds, ax
	
	call hiscoregetter
	call mainmenu
	call maingamestart
	call ifhiscore	
	call gameoverscreen
	
	mov ax, 4c00h
	int 21h	
	
	main endp
	
	mainmenu proc
	
		mov ah, 03h
		mov al, 00h
		int 10h

		mov dh, FINAL_BASE
		mov dl, 20
		xor bh, bh  ; video page 0
		mov ah, 02h ; move cursor to the right place
		int 10h
		
		mov cx, 3200h
		mov ah, 01h
		int 10h
		
		mov ax, 0600h
		mov bh, 07h
		xor cx, cx
		mov dx, 184fh
		int 10h	
		
		mov al, '0'
		mov bh, 0
		mov cx, 3
		mov ah, 0Ah
		int 10h
		
		mov dh, FINAL_HEAD
		mov dl, 21
		xor bh, bh
		mov ah, 02h
		int 10h
		
		mov al, "I"
		mov bh, 0
		mov cx, 1
		mov ah, 0Ah
		int 10h	
		
		mov prev, 0h
		
		menuloop:
		
			cmp startgame, 1
			je ending
		
			cmp al, 13
			je ending	
			cmp al, 77h
			je up
			cmp al, 73h
			je down

			jmp postloop	
			
			up:
				mov direction, 0
				call changecoords
				;call delay
				call printtank
				
				jmp postloop
			
			down:
				mov direction, 1
				call changecoords
				;call delay
				call printtank
			
			postloop:
			
			call printmenu
			call delay
			call printborders
			call projectile
			call projectile
			
			mov ah, 01h
			int 16h
			jz noinput
			
			xor ah, ah
			int 16h
			
			mov prev, al
			
			mov al, prev
			
			jmp endloop
			
			noinput:
			
			mov al, 0
			
			endloop:
			
		jmp menuloop
			
		ending:	
		
		call adjustdiff		
		
		ret
		
	
	mainmenu endp
	
	adjustdiff proc
	
		cmp selected, 0
		je easy
		
		cmp selected, 1
		je moderate

		mov blockdelay, 20
		jmp ending
		
		easy:
		
		mov blockdelay, 60
		jmp ending
		
		moderate:
		
		mov blockdelay, 40
		
		ending:
	
		ret
	
	adjustdiff endp
	
	changecoords proc
	
		cmp direction, 0
		je up
		
		cmp direction, 1
		je down
		
		jmp ending
		
		up:
		
		cmp selected, 0
		je warpup
		
		cmp selected, 2
		je hardup		
		
		moderateup:
		sub cursorrow, 3
		sub moderatecol, 3
		add easycol, 3
		dec selected
			
		
		call clearmoderate
		
		jmp ending
		
		hardup:
		sub cursorrow, 3
		sub hardcol, 3
		add moderatecol, 3
		dec selected	
		
		call clearhard
				
		jmp ending
		
		warpup:
		add cursorrow, 6
		sub easycol, 3
		add hardcol, 3
		mov selected, 2	
		
		call cleareasy
				
		jmp ending
		
		down:
		
		cmp selected, 2
		je warpdown	
		
		cmp selected, 0
		je easydown		
		
		moderatedown:
		add cursorrow, 3
		sub moderatecol, 3
		add hardcol, 3
		inc selected
		
		call clearmoderate
				
		jmp ending
		
		easydown:
		add cursorrow, 3
		sub easycol, 3
		add moderatecol, 3
		inc selected	
		
		call cleareasy
				
		jmp ending
		
		warpdown:
		sub cursorrow, 6
		sub hardcol, 3
		add easycol, 3
		mov selected, 0		

		call clearhard
		
		ending:
	
		ret
	
	changecoords endp
	
	gameoverscreen proc
	
		mov ah, 03h
		mov al, 00h
		int 10h

		mov dh, FINAL_BASE
		mov dl, 20
		xor bh, bh  ; video page 0
		mov ah, 02h ; move cursor to the right place
		int 10h
		
		mov cx, 3200h
		mov ah, 01h
		int 10h
		
		mov ax, 0600h
		mov bh, 07h
		xor cx, cx
		mov dx, 184fh
		int 10h		

		mov dh, 5
		mov dl, 25
		xor bh, bh  ; video page 0
		mov ah, 02h ; move cursor to the right place
		int 10h
		
		mov al, '#'
		mov bh, 0
		mov bl, 04h
		xor cx, cx
		mov cx, 30
		mov ah, 09h
		int 10h		

		mov dh, 9
		mov dl, 25
		xor bh, bh  ; video page 0
		mov ah, 02h ; move cursor to the right place
		int 10h
		
		mov al, '#'
		mov bh, 0
		mov bl, 04h
		xor cx, cx
		mov cx, 30
		mov ah, 09h
		int 10h		

		mov dh, 7
		mov dl, 32
		xor bh, bh  ; video page 0
		mov ah, 02h ; move cursor to the right place
		int 10h
		
		cmp winner, 0
		je loser
		
		lea dx, youwonmsg
		mov ah, 09h
		int 21h
		
		jmp tagumpay
		
		loser:
		
		lea dx, gameovermsg
		mov ah, 09h
		int 21h
		
		tagumpay:
		
		mov dh, 12
		mov dl, 35
		xor bh, bh  ; video page 0
		mov ah, 02h ; move cursor to the right place
		int 10h
		
		lea dx, statsmsg
		mov ah, 09h
		int 21h		
		
		mov dh, 16
		mov dl, 28
		xor bh, bh  ; video page 0
		mov ah, 02h ; move cursor to the right place
		int 10h
		
		lea dx, scoremsg
		mov ah, 09h
		int 21h				
		
		mov dh, 20
		mov dl, 30
		xor bh, bh  ; video page 0
		mov ah, 02h ; move cursor to the right place
		int 10h
		
		mov ax, score
		call printdecimal

		mov dh, 16
		mov dl, 41
		xor bh, bh  ; video page 0
		mov ah, 02h ; move cursor to the right place
		int 10h
		
		lea dx, hiscoremsg
		mov ah, 09h
		int 21h				
		
		mov dh, 20
		mov dl, 45
		xor bh, bh
		mov ah, 02h
		int 10h	
		
		mov al, [hiscore]
		mov bh, 0
		mov bl, 07h
		xor cx, cx
		mov cx, 1
		mov ah, 09h
		int 10h	
		
		mov dh, 20
		mov dl, 46
		xor bh, bh
		mov ah, 02h
		int 10h	
		
		mov al, [hiscore + 1]
		mov bh, 0
		mov bl, 07h
		xor cx, cx
		mov cx, 1
		mov ah, 09h
		int 10h	

		mov dh, 20
		mov dl, 47
		xor bh, bh
		mov ah, 02h
		int 10h	
		
		mov al, [hiscore + 2]
		mov bh, 0
		mov bl, 07h
		xor cx, cx
		mov cx, 1
		mov ah, 09h
		int 10h	

		mov dh, 20
		mov dl, 48
		xor bh, bh
		mov ah, 02h
		int 10h	
		
		mov al, [hiscore + 3]
		mov bh, 0
		mov bl, 07h
		xor cx, cx
		mov cx, 1
		mov ah, 09h
		int 10h				

		ret

	gameoverscreen endp	
	
	cleareasy proc
		
		mov dh, 15
		mov dl, 62
		xor bh, bh
		mov ah, 02h
		int 10h
		
		mov al, ' '
		mov bh, 0
		mov bl, 07h
		xor cx, cx
		mov cx, 5
		mov ah, 09h
		int 10h
		
		ret
		
	cleareasy endp
	
	clearmoderate proc
	
		mov dh, 18
		mov dl, 66
		xor bh, bh
		mov ah, 02h
		int 10h
		
		mov al, ' '
		mov bh, 0
		mov bl, 07h
		xor cx, cx
		mov cx, 5
		mov ah, 09h
		int 10h
		ret
	
	clearmoderate endp

	clearhard proc
	
		mov dh, 21
		mov dl, 62
		xor bh, bh
		mov ah, 02h
		int 10h
		
		mov al, ' '
		mov bh, 0
		mov bl, 07h
		xor cx, cx
		mov cx, 5
		mov ah, 09h
		int 10h
		
		ret
	
	clearhard endp	
	
	printmenu proc
	
		mov dh, 2
		mov dl, 50
		xor bh, bh
		mov ah, 02h
		int 10h
		
		mov al, '#'
		mov bh, 0
		mov bl, 04h
		xor cx, cx
		mov cx, 26
		mov ah, 09h
		int 10h
		
		mov dh, 4
		mov dl, 53
		xor bh, bh
		mov ah, 02h
		int 10h
		
		mov al, 'L'
		mov bh, 0
		mov bl, 08h
		xor cx, cx
		mov cx, 1
		mov ah, 09h
		int 10h

		mov dh, 4
		mov dl, 56
		xor bh, bh
		mov ah, 02h
		int 10h
		
		mov al, 'A'
		mov bh, 0
		mov bl, 08h
		xor cx, cx
		mov cx, 1
		mov ah, 09h
		int 10h		
		
		mov dh, 4
		mov dl, 59
		xor bh, bh
		mov ah, 02h
		int 10h
		
		mov al, 'S'
		mov bh, 0
		mov bl, 08h
		xor cx, cx
		mov cx, 1
		mov ah, 09h
		int 10h	

		mov dh, 4
		mov dl, 62
		xor bh, bh
		mov ah, 02h
		int 10h
		
		mov al, 'T'
		mov bh, 0
		mov bl, 08h
		xor cx, cx
		mov cx, 1
		mov ah, 09h
		int 10h		

		mov dh, 6
		mov dl, 60
		xor bh, bh
		mov ah, 02h
		int 10h
		
		mov al, 'S'
		mov bh, 0
		mov bl, 08h
		xor cx, cx
		mov cx, 1
		mov ah, 09h
		int 10h	

		mov dh, 6
		mov dl, 63
		xor bh, bh
		mov ah, 02h
		int 10h
		
		mov al, 'T'
		mov bh, 0
		mov bl, 08h
		xor cx, cx
		mov cx, 1
		mov ah, 09h
		int 10h	

		mov dh, 6
		mov dl, 66
		xor bh, bh
		mov ah, 02h
		int 10h
		
		mov al, 'A'
		mov bh, 0
		mov bl, 08h
		xor cx, cx
		mov cx, 1
		mov ah, 09h
		int 10h	

		mov dh, 6
		mov dl, 69
		xor bh, bh
		mov ah, 02h
		int 10h
		
		mov al, 'N'
		mov bh, 0
		mov bl, 08h
		xor cx, cx
		mov cx, 1
		mov ah, 09h
		int 10h	

		mov dh, 6
		mov dl, 72
		xor bh, bh
		mov ah, 02h
		int 10h
		
		mov al, 'D'
		mov bh, 0
		mov bl, 08h
		xor cx, cx
		mov cx, 1
		mov ah, 09h
		int 10h			
		
		mov dh, 8
		mov dl, 50
		xor bh, bh
		mov ah, 02h
		int 10h
		
		mov al, '#'
		mov bh, 0
		mov bl, 04h
		xor cx, cx
		mov cx, 26
		mov ah, 09h
		int 10h	

		mov dh, 12
		mov dl, 53
		xor bh, bh
		mov ah, 02h
		int 10h		
		
		lea dx, playmsg
		mov ah, 09h
		int 21h
		
		mov dh, 15
		mov dl, easycol
		xor bh, bh
		mov ah, 02h
		int 10h		
		
		lea dx, easymsg
		mov ah, 09h
		int 21h

		mov dh, 18
		mov dl, moderatecol
		xor bh, bh
		mov ah, 02h
		int 10h		
		
		lea dx, moderatemsg
		mov ah, 09h
		int 21h

		mov dh, 21
		mov dl, hardcol
		xor bh, bh
		mov ah, 02h
		int 10h		
		
		lea dx, hardmsg
		mov ah, 09h
		int 21h		
		
		mov dh, cursorrow
		mov dl, 56
		xor bh, bh
		mov ah, 02h
		int 10h		
		
		lea dx, cursor
		mov ah, 09h
		int 21h			
	
		ret
	
	printmenu endp
	
	maingamestart proc

		mov ah, 03h
		mov al, 00h
		int 10h

		mov dh, FINAL_BASE
		mov dl, 20
		xor bh, bh  ; video page 0
		mov ah, 02h ; move cursor to the right place
		int 10h
		
		mov cx, 3200h
		mov ah, 01h
		int 10h
		
		mov ax, 0600h
		mov bh, 07h
		xor cx, cx
		mov dx, 184fh
		int 10h	
		
		mov al, '0'
		mov bh, 0
		mov cx, 3
		mov ah, 0Ah
		int 10h
		
		mov dh, FINAL_HEAD
		mov dl, 21
		xor bh, bh
		mov ah, 02h
		int 10h
		
		mov al, "I"
		mov bh, 0
		mov cx, 1
		mov ah, 0Ah
		int 10h	
		
		mov prev, 0h
		mov coordsmult, 0
		mov delaycounter, 0	

		call updatecoords	
		
		maingame:
		
			cmp itsover, 1
			je ending
		
			cmp al, 1bh
			je ending	
			cmp al, 61h
			je left
			cmp al, 64h
			je right

			jmp postloop	
			
			left:
			
				;call delay
			
				cmp noleft, 1
				je nomoreleft
				
				call removeprev
				
				dec borderl
				dec borderr
				dec warhead
				dec warheaddw
				
				nomoreleft:	
		
				call checkbounds
				call printtank
				
				jmp postloop
			
			right:
			
				;call delay	
			
				cmp noright, 1
				je nomoreright
				
				call removeprev
			
				inc borderl
				inc borderr
				inc warhead
				inc warheaddw
				
				nomoreright:
				
				call checkbounds	
				call printtank
			
			postloop:	
			
			call delay
			call printsidebar
			call printborders
			call projectile
			call projectile
			call projectile
			call projectile
			call projectile
			call printblocks
			
			mov ah, 01h
			int 16h
			jz noinput
			
			xor ah, ah
			int 16h
			
			mov prev, al
			
			mov al, prev
			
			jmp endloop
			
			noinput:
			
			mov al, 0
			
			endloop:
			
		jmp maingame
			
		ending:	
		
		ret

	maingamestart endp
	
	printsidebar proc
	
		mov dh, 3
		mov dl, 52
		xor bh, bh
		mov ah, 02h
		int 10h	
		
		lea dx, difficulty
		mov ah, 09h
		int 21h
	
		mov dh, 5
		mov dl, 55
		xor bh, bh
		mov ah, 02h
		int 10h
		
		cmp selected, 0
		je easy
		
		cmp selected, 1
		je moderate		
		
		lea dx, hardmsg
		mov ah, 09h
		int 21h
		
		jmp next
		
		easy:
		
		lea dx, easymsg
		mov ah, 09h
		int 21h		
		
		jmp next
		
		moderate:
		
		lea dx, moderatemsg
		mov ah, 09h
		int 21h	

		next:
		
		mov dh, 7
		mov dl, 52
		xor bh, bh
		mov ah, 02h
		int 10h	
		
		lea dx, scoremsg
		mov ah, 09h
		int 21h		
		
		mov dh, 9
		mov dl, 56
		xor bh, bh
		mov ah, 02h
		int 10h	
		
		mov ax, score
		call printdecimal
		
		mov dh, 11
		mov dl, 52
		xor bh, bh
		mov ah, 02h
		int 10h	
		
		lea dx, hiscoremsg
		mov ah, 09h
		int 21h		

		mov dh, 13
		mov dl, 56
		xor bh, bh
		mov ah, 02h
		int 10h	
		
		mov al, [hiscore]
		mov bh, 0
		mov bl, 07h
		xor cx, cx
		mov cx, 1
		mov ah, 09h
		int 10h	
		
		mov dh, 13
		mov dl, 57
		xor bh, bh
		mov ah, 02h
		int 10h	
		
		mov al, [hiscore + 1]
		mov bh, 0
		mov bl, 07h
		xor cx, cx
		mov cx, 1
		mov ah, 09h
		int 10h	

		mov dh, 13
		mov dl, 58
		xor bh, bh
		mov ah, 02h
		int 10h	
		
		mov al, [hiscore + 2]
		mov bh, 0
		mov bl, 07h
		xor cx, cx
		mov cx, 1
		mov ah, 09h
		int 10h	

		mov dh, 13
		mov dl, 59
		xor bh, bh
		mov ah, 02h
		int 10h	
		
		mov al, [hiscore + 3]
		mov bh, 0
		mov bl, 07h
		xor cx, cx
		mov cx, 1
		mov ah, 09h
		int 10h			
	
		ret
	
	printsidebar endp
	
printdecimal proc
		
		mov bx, 3
		
		process:
		
			sub dx, dx		
			mov cx, 10	
			div cx
			
			add dx, 30h		
			
			mov result[bx], dl
			dec bx
			
			cmp bx, 0
			jge process
		
		ending:
		
		mov result + 4, '$'
		
		lea dx, result
		mov ah, 09h
		int 21h	
			
		
		ret
	
printdecimal endp	
	
checkbounds proc

	cmp borderl, 0
	je leftborder
	
	cmp borderr, 44
	je rightborder
	
	mov noleft, 0
	mov noright, 0
	
	ret
	
	leftborder:
	
	mov noleft, 1
	ret
	
	rightborder:
	
	mov noright, 1
	ret

checkbounds endp	

printtank proc

	mov dh, FINAL_BASE
	mov dl, borderl
	xor bh, bh
	mov ah, 02h
	int 10h

	mov al, '0'
	mov bh, 0
	mov cx, 3
	mov ah, 0Ah
	int 10h
	
	mov dh, FINAL_HEAD
	mov dl, warhead
	xor bh, bh
	mov ah, 02h
	int 10h
	
	mov al, "I"
	mov bh, 0
	mov cx, 1
	mov ah, 0Ah
	int 10h
	
	ret
	
printtank endp

removeprev proc

	mov dh, FINAL_BASE
	mov dl, borderl
	xor bh, bh
	mov ah, 02h
	int 10h

	mov al, " "
	mov bh, 0
	mov cx, 3
	mov ah, 0Ah
	int 10h
	
	mov dh, FINAL_HEAD
	mov dl, warhead
	xor bh, bh
	mov ah, 02h
	int 10h
	
	mov al, " "
	mov bh, 0
	mov cx, 1
	mov ah, 0Ah
	int 10h
	
	
	ret
	
removeprev endp

projectile proc
	
	cmp proj, 0
	je restart
	
	cmp proj, 22
	jne takeoff
	
	restart:
	
	cmp hit, 1
	je ithit
	
    mov dh, proj
    mov dl, traj
    xor bh, bh  ; video page 0
    mov ah, 02h ; move cursor to the right place
    int 10h
	
	mov al, '.'
	mov bh, 0
	mov bl, 07h
	xor cx, cx
	mov cx, 1
	mov ah, 09h
	int 10h	
	
	mov dl, proj
	mov proj2, dl
	
	call clearprojectile
	
	call delay
	
    mov dh, 0
    mov dl, traj
    xor bh, bh  ; video page 0
    mov ah, 02h ; move cursor to the right place
    int 10h
	
	mov al, ' '
	mov bh, 0
	mov bl, 07h
	xor cx, cx
	mov cx, 1
	mov ah, 09h
	int 10h		
	
	ithit:

	mov ah, warhead
	mov traj, ah
	mov ax, warheaddw
	mov trajdw, ax

	mov proj, 22	
	mov projdw, 22

	takeoff:

    mov dh, proj
    mov dl, traj
    xor bh, bh  ; video page 0
    mov ah, 02h ; move cursor to the right place
    int 10h

	mov al, '.'
	mov bh, 0
	mov bl, 07h
	xor cx, cx
	mov cx, 1
	mov ah, 09h
	int 10h

	mov dl, proj
	mov proj2, dl
	sub proj, 1
	sub projdw, 1

	call clearprojectile	
	call ifhit
	
	ret

projectile endp

ifhit proc
	
    mov dh, proj
    mov dl, traj
    xor bh, bh  ; video page 0
    mov ah, 02h ; move cursor to the right place
    int 10h	
	
	mov ah, 08h
	int 10h
	
	cmp al, 'X'
	jne nohit
	
	call removecoords
	
	inc proj
	inc projdw
	
	call delay
	
    mov dh, proj
    mov dl, traj
    xor bh, bh  ; video page 0
    mov ah, 02h ; move cursor to the right place
    int 10h
	
	mov al, ' '
	mov bh, 0
	mov bl, 07h
	xor cx, cx
	mov cx, 1
	mov ah, 09h
	int 10h			
	
	mov proj, 22
	mov projdw, 22
	
	mov hit, 1
	
	ret
	
	nohit:
	
	mov hit, 0

	ret

ifhit endp

removecoords proc

	inc projdw
	dec projdw
	
	xor ax, ax
	mov ax, projdw
	mov bx, blockrowdw
	dec bx
	dec bx
	sub bx, ax
	xor ax, ax
	mov ax, 43
	mul bx
	mov bx, ax
	mov dx, trajdw
	dec dx
	add bx, dx
	
	mov [coords + bx], 0
	
    mov dh, proj
    mov dl, traj
    xor bh, bh  ; video page 0
    mov ah, 02h ; move cursor to the right place
    int 10h
	
	mov al, ' '
	mov bh, 0
	mov bl, 07h
	xor cx, cx
	mov cx, 1
	mov ah, 09h
	int 10h
	
	inc score
	
	ret

removecoords endp

clearprojectile proc

	add proj2, 1
	
	cmp proj2, 23
	je skip

    mov dh, proj2
    mov dl, traj
    xor bh, bh  ; video page 0
    mov ah, 02h ; move cursor to the right place
    int 10h
	
	mov al, ' '
	mov bh, 0
	mov bl, 07h
	xor cx, cx
	mov cx, 1
	mov ah, 09h
	int 10h
	
	skip:
	
	ret

clearprojectile endp

delay proc
	
	mov ah, 00
	int 1Ah
	mov bx, dx

	jmp_delay:
	
	int 1Ah
	sub dx, bx
	cmp dl, delaytime
	jl jmp_delay
	
	ret

delay endp

printborders proc

	startprint:
	
	cmp biter, 26
	je endna
	
    mov dh, biter
    mov dl, 45
    xor bh, bh  ; video page 0
    mov ah, 02h ; move cursor to the right place
    int 10h
	
	mov al, 'I'
	mov bh, 0
	mov bl, 07h
	xor cx, cx
	mov cx, 1
	mov ah, 09h
	int 10h
	
	inc biter
	
	jmp startprint
	
	endna:
	
	mov biter, 0
	
	ret

printborders endp

printblocks proc

	mov ah, blockdelay

	mov localtemp, 0	
	
	inc delaycounter
	
	cmp delaycounter, ah
	jl skip
	
	mov delaycounter, 0
	
	mov ah, blockrow
	mov localinc, ah
	
	rowloop:
	
	mov checker, 0
	dec localinc
	mov dx, localtemp
	mov localtemp, dx
	
	colloop:
	
	mov bx, localtemp
		
	cmp [coords + bx], 0
	je skip2
	
	mov dh, localinc
    mov dl, [coords + bx]
    xor bh, bh  ; video page 0
    mov ah, 02h ; move cursor to the right place
    int 10h
	
	mov al, 'X'
	mov bh, 0
	mov bl, 07h
	xor cx, cx
	mov cx, 1
	mov ah, 09h
	int 10h
	
	skip2:
	inc checker
	inc localtemp
	
	cmp checker, 43
	je checkrow
	
	jmp colloop

	checkrow:
	
	cmp localinc, 0
	je done
	
	jmp rowloop
	
	done:

	inc blockrow
	inc blockrowdw
	inc iterations
	
	skip:
	
	call gameoverchecker
	
	ret
	
printblocks endp

gameoverchecker proc

	cmp score, 1000
	jge youwon

	mov overiterator, 0

	loops:

    mov dh, 24
    mov dl, overiterator
    xor bh, bh  ; video page 0
    mov ah, 02h ; move cursor to the right place
    int 10h
	
	mov ah, 08h
	int 10h
	
	cmp al, 'X'
	je itsoverhehe
	
	inc overiterator
	
	cmp overiterator, 42
	jl loops
	
	jmp ending
	
	youwon:
	
	mov winner, 1
	
	itsoverhehe:
	
	mov itsover, 1
	
	ending:

	ret

gameoverchecker endp

updatecoords proc

	repeats:

	xor ax, ax
	mov ax, coordsmult
	mov bx, 43
	mul bx
	xor bx, bx
	mov bx, ax
	xor dx, dx
	mov dx, bx
	add dx, 43
	mov al, 1
	
	update:
	
	mov coords[bx], al
	inc bx
	inc al
	
	cmp bx, dx
	jl update
	
	inc coordsmult
	inc updater
	
	cmp updater, 40
	jl repeats

	ret

updatecoords endp

random proc

	mov ah, 00
	int 1Ah
	mov ax, dx
	xor dx, dx
	xor bx, bx
	mov bx, 43
	div bx
	
	ret

random endp

hiscoregetter proc
	
	;;;;;;;;;;;;;;;;;OPENFILE;;;;;;;;;;;;;;;;;;;;;;;
	
	mov ah, 3Dh   ; 3Dh of DOS Services opens a file.
	mov al, 0   ; 0 - for reading. 1 - for writing. 2 - both
	mov dx, offset filename  ; make a pointer to the filename
	int 21h   ; call DOS
	jc createfile
	mov handle, ax   ; Function 3Dh returns the file handle in AX, here we save it for later use.
	
	jmp continue
	
	createfile:
	
	mov ah, 3Eh	;close file
	int 21h		
	
	;;;;;;;;;;;;;;;;;CREATEFILE;;;;;;;;;;;;;;;;;;;;;;;
	
	mov ah, 3Ch
	mov cx, 0   ; no special file attributes
	mov dx, offset filename
	int 21h
	
	;;;;;;;;;;;;;;;;;OPENFILE;;;;;;;;;;;;;;;;;;;;;;;
	
	mov ah, 3Dh   ; 3Dh of DOS Services opens a file.
	mov al, 2   ; 0 - for reading. 1 - for writing. 2 - both
	mov dx, offset filename  ; make a pointer to the filename
	int 21h   ; call DOS
	
	mov handle, ax   ; Function 3Dh returns the file handle in AX, here we save it for later use.	
	
	;;;;;;;;;;;;;;;;;WRITEFILE;;;;;;;;;;;;;;;;;;;;;	
	
	mov ah, 40h
	mov bx, handle
	mov cx, 4
	mov dx, offset buffer
	int 21h	
	
	mov [hiscore], '0'
	mov [hiscore + 1], '0'
	mov [hiscore + 2], '0'
	mov [hiscore + 3], '0'
	jmp ending
	
	continue:

	;;;;;;;;;;;;;;;;;READFILE;;;;;;;;;;;;;;;;;;;;;
	
	mov ah, 3Fh
	mov cx, 4   ; number of bytes to read
	mov dx, offset hiscore  ; DOS Functions like DX having pointers for some reason.
	mov bx, handle    ; BX needs the file handle.
	int 21h   ; call DOS	
	
	mov nobytes, ax
	
	mov ah, 3Eh	;close file
	int 21h		
	
	ending:
	
	ret

hiscoregetter endp

hiscorewriter proc

	;;;;;;;;;;;;;;;;;OPENFILE;;;;;;;;;;;;;;;;;;;;;;;
	
	mov ah, 3Dh   ; 3Dh of DOS Services opens a file.
	mov al, 1   ; 0 - for reading. 1 - for writing. 2 - both
	mov dx, offset filename  ; make a pointer to the filename
	int 21h   ; call DOS
	
	mov handle, ax   ; Function 3Dh returns the file handle in AX, here we save it for later use.
	
	mov ax, score
	;DECIMALTORESULT
		mov bx, 3
		
		process:
		
			sub dx, dx		
			mov cx, 10	
			div cx
			
			add dx, 30h		
			
			mov result[bx], dl
			dec bx
			
			cmp bx, 0
			jge process
		
		ending:
		
		mov result + 4, '$'	
	
	;DECIMALTORESULT
	
	;;;;;;;;;;;;;;;;;WRITEFILE;;;;;;;;;;;;;;;;;;;;;	
	
	mov ah, 40h
	mov bx, handle
	mov cx, 4
	mov dx, offset result
	int 21h

	mov ah, 3Eh	;close file
	int 21h		

	ret

hiscorewriter endp

ifhiscore proc

	mov ax, score
	mov bx, 3
		
		process:
		
			sub dx, dx		
			mov cx, 10	
			div cx
			
			add dx, 30h		
			
			mov result[bx], dl
			dec bx
			
			cmp bx, 0
			jge process
		
		ending:
		
		mov result + 4, '$'

	cmp [result], '1'
	je write
	
	sub [result + 1], 48
	sub [result + 2], 48
	sub [result + 3], 48
	
	sub [hiscore + 1], 48
	sub [hiscore + 2], 48
	sub [hiscore + 3], 48	
	
	mov ah, [result + 1]
	cmp [hiscore + 1], ah
	jg nope
	
	mov ah, [result + 2]
	cmp [hiscore + 2], ah
	jg nope

	mov ah, [result + 3]
	cmp [hiscore + 3], ah
	jg nope	
	
	write:
	
	call hiscorewriter
	call hiscoregetter

	nope:
	
	ret

ifhiscore endp
	
	end main