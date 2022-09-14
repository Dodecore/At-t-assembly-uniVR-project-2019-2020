.data
  A:
    .long 0 #18
  B:
    .long 0
  C:
    .long 0

  newline:
    .ascii "\n"

.text
  .global parking

parking:

  pushl %ebp
  movl %esp, %ebp

  movl 8(%ebp), %esi #salvo in esi indirizzo prima cella bufferin
  movl 12(%ebp), %edi #salvo in edi indirizzo perima cella bufferout_asm
  pushl %ebx #push di ebx per evitare segmentation fault
  pushl %edi

  movl $2, %edi
  movl $0, %ecx #contatore di riga
  movl $0, %edx

controllo_quale_settore_riempire:
  movb (%esi, %edx), %al #esamino primo carattere
  cmpb $65, %al
  jne controllo_B
  pushl %ecx
  pushl %edx
  pushl %eax
  je preparo_registri_per_A
ciclo_da_A:
  popl %eax
  popl %edx
  popl %ecx
  jmp nuovo_ciclo
controllo_B:
  cmpb $66, %al
  jne controllo_C
  pushl %ecx
  pushl %edx
  pushl %eax
  je preparo_registri_per_B
ciclo_da_B:
  popl %eax
  popl %edx
  popl %ecx
  jmp nuovo_ciclo
controllo_C: #da inserire condizione stringa corrotta
  cmpb $67,%al
  jne nuovo_ciclo
  pushl %ecx
  pushl %edx
  pushl %eax
  je preparo_registri_per_C
ciclo_da_C:
  popl %eax
  popl %edx
  popl %ecx
nuovo_ciclo:
  cmpb newline, %al #controllo se sono a fine riga
  je aggiorno_riga
aggiorno_carattere:
  incl %edx
  jmp controllo_quale_settore_riempire
aggiorno_riga:
  cmpl $2, %ecx     #controllo a che numero di riga sono
  je  ripristino_edi
  incl %ecx
  incl %edx
  movl %edx, %edi
  addl $2, %edi
  jmp controllo_quale_settore_riempire

preparo_registri_per_A:
  movl %edi, %ecx #ecx spiazza esi a partire dalla prima cifra
  movb $10, %bl #10 in bl per moltiplicazione di al

estraggo_posti_A:
  movb (%esi, %ecx), %al #esamino prima cifra
  subb $48, %al #converto la cifra in numero
  movb %al, A #inserisco prima cifra in A

check_seconda_cifra_A:
  incl %ecx
  movb (%esi, %ecx), %dl  #controllo il carattere successivo alla cifra
  cmpb newline, %dl #se è un \n abbiamo una sola cifra e abbiamo finito
  je ciclo_da_A#

inserisco_A: #se sono qui in dl ho la seconda cifra
  mulb %bl
  subb $48, %dl
  addb %dl, %al
  movb %al, A #A contiene 18!
  jmp ciclo_da_A

preparo_registri_per_B:
  xorl %edx, %edx
  movl %edi, %ecx #ecx spiazza esi a partire dalla prima cifra
  movb $10, %bl #10 in bl per moltiplicazione di al

estraggo_posti_B:
  movb (%esi, %ecx), %al
  subb $48, %al
  movb %al, B #inserisco prima cifra in B

check_seconda_cifra_B:
  incl %ecx
  movb (%esi, %ecx), %dl
  cmpb newline, %dl
  je ciclo_da_B

inserisco_B: #se sono qui in dl ho la seconda cifra
  mulb %bl
  subb $48, %dl
  addb %dl, %al
  movb %al, B
  jmp ciclo_da_B

preparo_registri_per_C:
  xorl %edx, %edx
  movl %edi, %ecx #ecx spiazza esi a partire dalla prima cifra
  movb $10, %bl #10 in bl per moltiplicazione di al

estraggo_posti_C:
  movb (%esi, %ecx), %al
  subb $48, %al
  movb %al, C

check_seconda_cifra_C:
  incl %ecx
  movb (%esi, %ecx), %dl
  cmpb newline, %dl
  je ciclo_da_C

inserisco_C:
  mulb %bl
  subb $48, %dl
  addb %dl, %al
  movb %al, C
  jmp ciclo_da_C

ripristino_edi:
  movl %edi, %ecx
  popl %edi

loop_riga:
  incl %ecx
  movb (%esi, %ecx), %al
  cmpb $10, %al
  jne loop_riga

  movl $0, %edx
accensione_parcheggio: #inizio funzionamento automatico accensione_parcheggio
  incl %ecx #incremento per puntare subito dopo il \n
  movb (%esi, %ecx), %al

ingresso:
  cmpb $0, %al
  je interrupt_di_sistema
  cmpb $73, %al
  jne uscita
  incl %ecx
  movb (%esi, %ecx), %al
  cmpb $78, %al
  jne fine_riga_corrotta
  incl %ecx
  movb (%esi, %ecx), %al
  cmpb $45, %al
  jne fine_riga_corrotta
  incl %ecx
  movb (%esi, %ecx), %al
  cmpb $65, %al
  je check_ingresso_A
  cmpb $66, %al
  je check_ingresso_B
  cmpb $67, %al
  je check_ingresso_C
  jmp fine_riga_corrotta

check_ingresso_A:
   #parto dall'inizio di bufferout
  cmpb $31, A #controllo che A abbia posto
  jl A_libero #se cì+ posto salto all'etichetta
A_pieno:
  movb $67, (%edi, %edx)
  incl %edx
  movb $67, (%edi, %edx)
  incl %edx
  movb $45, (%edi, %edx)
itoa_A:
  movl A, %eax
  movb $10, %bl
  divb %bl #in ah c'è il resto
  addb $48, %ah
  cmpb $0, %al
  je una_cifra_A
  jmp due_cifre_A
una_cifra_A:
  incl %edx
  movb $48, (%edi, %edx)
  incl %edx
  movb %ah, (%edi, %edx)
  incl %edx
  movb $45, (%edi, %edx)
  jmp itoa_B
due_cifre_A:
  incl %edx
  addb $48, %al
  movb %al, (%edi, %edx)
  incl %edx
  movb %ah, (%edi, %edx)
  incl %edx
  movb $45, (%edi, %edx)
  jmp itoa_B
A_libero:
  incl A
  movl A, %eax
  movb $79, (%edi, %edx)
  incl %edx
  movb $67, (%edi, %edx)
  incl %edx
  movb $45, (%edi, %edx)
itoa_libero_A:
  movl A, %eax
  movb $10, %bl
  divb %bl #in ah c'è il resto
  addb $48, %ah
  cmpb $0, %al
  je una_cifra_libero_A
  jmp due_cifre_libero_A
una_cifra_libero_A:
  incl %edx
  movb $48, (%edi, %edx)
  incl %edx
  movb %ah, (%edi, %edx)
  incl %edx
  movb $45, (%edi, %edx)
  jmp itoa_B
due_cifre_libero_A:
  incl %edx
  addb $48, %al
  movb %al, (%edi, %edx)
  incl %edx
  movb %ah, (%edi, %edx)
  incl %edx
  movb $45, (%edi, %edx)

itoa_B:
  movl B, %eax
  movb $10, %bl
  divb %bl #in ah c'è il resto
  addb $48, %ah
  cmpb $0, %al
  je una_cifra_B
  jmp due_cifre_B
una_cifra_B:
  incl %edx
  movb $48, (%edi, %edx)
  incl %edx
  movb %ah, (%edi, %edx)
  incl %edx
  movb $45, (%edi, %edx)
  jmp itoa_C
due_cifre_B:
  incl %edx
  addb $48, %al
  movb %al, (%edi, %edx)
  incl %edx
  movb %ah, (%edi, %edx)
  incl %edx
  movb $45, (%edi, %edx)
  jmp itoa_C

itoa_C:
  movl C, %eax
  movb $10, %bl
  divb %bl #in ah c'è il resto
  addb $48, %ah
  cmpb $0, %al
  je una_cifra_C
  jmp due_cifre_C
una_cifra_C:
  incl %edx
  movb $48, (%edi, %edx)
  incl %edx
  movb %ah, (%edi, %edx)
  incl %edx
  movb $45, (%edi, %edx)
  jmp semafori
due_cifre_C:
  incl %edx
  addb $48, %al
  movb %al, (%edi, %edx)
  incl %edx
  movb %ah, (%edi, %edx)
  incl %edx
  movb $45, (%edi, %edx)
  jmp semafori

check_ingresso_B:
  cmpb $31, B
  jl B_libero
B_pieno:
  movb $67, (%edi, %edx)
  incl %edx
  movb $67, (%edi, %edx)
  incl %edx
  movb $45, (%edi, %edx)
itoa_A_B:
  movl A, %eax
  movb $10, %bl
  divb %bl #in ah c'è il resto
  addb $48, %ah
  cmpb $0, %al
  je una_cifra_A_B
  jmp due_cifre_A_B
una_cifra_A_B:
  incl %edx
  movb $48, (%edi, %edx)
  incl %edx
  movb %ah, (%edi, %edx)
  incl %edx
  movb $45, (%edi, %edx)
due_cifre_A_B:
  incl %edx
  addb $48, %al
  movb %al, (%edi, %edx)
  incl %edx
  movb %ah, (%edi, %edx)
  incl %edx
  movb $45, (%edi, %edx)
itoa_B2:
  movl B, %eax
  movb $10, %bl
  divb %bl #in ah c'è il resto
  addb $48, %ah
  cmpb $0, %al
  je una_cifra_B2
  jmp due_cifre_B2
una_cifra_B2:
  incl %edx
  movb $48, (%edi, %edx)
  incl %edx
  movb %ah, (%edi, %edx)
  incl %edx
  movb $45, (%edi, %edx)
  jmp itoa_C_B
due_cifre_B2:
  incl %edx
  addb $48, %al
  movb %al, (%edi, %edx)
  incl %edx
  movb %ah, (%edi, %edx)
  incl %edx
  movb $45, (%edi, %edx)
  jmp itoa_C_B
B_libero:
  incl B
  movl B, %eax
  movb $79, (%edi, %edx)
  incl %edx
  movb $67, (%edi, %edx)
  incl %edx
  movb $45, (%edi, %edx)
itoa_A_B1:
  movl A, %eax
  movb $10, %bl
  divb %bl #in ah c'è il resto
  addb $48, %ah
  cmpb $0, %al
  je una_cifra_A_B1
  jmp due_cifre_A_B1
una_cifra_A_B1:
  incl %edx
  movb $48, (%edi, %edx)
  incl %edx
  movb %ah, (%edi, %edx)
  incl %edx
  movb $45, (%edi, %edx)
due_cifre_A_B1:
  incl %edx
  addb $48, %al
  movb %al, (%edi, %edx)
  incl %edx
  movb %ah, (%edi, %edx)
  incl %edx
  movb $45, (%edi, %edx)
itoa_libero_B:
  movl B, %eax
  movb $10, %bl
  divb %bl #in ah c'è il resto
  addb $48, %ah
  cmpb $0, %al
  je una_cifra_libero_B
  jmp due_cifre_libero_B
una_cifra_libero_B:
  incl %edx
  movb $48, (%edi, %edx)
  incl %edx
  movb %ah, (%edi, %edx)
  incl %edx
  movb $45, (%edi, %edx)
  jmp itoa_C_B
due_cifre_libero_B:
  incl %edx
  addb $48, %al
  movb %al, (%edi, %edx)
  incl %edx
  movb %ah, (%edi, %edx)
  incl %edx
  movb $45, (%edi, %edx)
itoa_C_B:
  movl C, %eax
  movb $10, %bl
  divb %bl #in ah c'è il resto
  addb $48, %ah
  cmpb $0, %al
  je una_cifra_C_B
  jmp due_cifre_C_B
una_cifra_C_B:
  incl %edx
  movb $48, (%edi, %edx)
  incl %edx
  movb %ah, (%edi, %edx)
  incl %edx
  movb $45, (%edi, %edx)
  jmp semafori
due_cifre_C_B:
  incl %edx
  addb $48, %al
  movb %al, (%edi, %edx)
  incl %edx
  movb %ah, (%edi, %edx)
  incl %edx
  movb $45, (%edi, %edx)
  jmp semafori

check_ingresso_C:
  cmpb $24, C
  jl C_libero
C_pieno:
  movb $67, (%edi, %edx)
  incl %edx
  movb $67, (%edi, %edx)
  incl %edx
  movb $45, (%edi, %edx)
itoa_A_C:
  movl A, %eax
  movb $10, %bl
  divb %bl #in ah c'è il resto
  addb $48, %ah
  cmpb $0, %al
  je una_cifra_A_C
  jmp due_cifre_A_C
una_cifra_A_C:
  incl %edx
  movb $48, (%edi, %edx)
  incl %edx
  movb %ah, (%edi, %edx)
  incl %edx
  movb $45, (%edi, %edx)
due_cifre_A_C:
  incl %edx
  addb $48, %al
  movb %al, (%edi, %edx)
  incl %edx
  movb %ah, (%edi, %edx)
  incl %edx
  movb $45, (%edi, %edx)
itoa_B3:
  movl B, %eax
  movb $10, %bl
  divb %bl #in ah c'è il resto
  addb $48, %ah
  cmpb $0, %al
  je una_cifra_B3
  jmp due_cifre_B3
una_cifra_B3:
  incl %edx
  movb $48, (%edi, %edx)
  incl %edx
  movb %ah, (%edi, %edx)
  incl %edx
  movb $45, (%edi, %edx)
  jmp itoa_C_C
due_cifre_B3:
  incl %edx
  addb $48, %al
  movb %al, (%edi, %edx)
  incl %edx
  movb %ah, (%edi, %edx)
  incl %edx
  movb $45, (%edi, %edx)
  jmp itoa_C_C
C_libero:
  incl C
  movl C, %eax
  movb $79, (%edi, %edx)
  incl %edx
  movb $67, (%edi, %edx)
  incl %edx
  movb $45, (%edi, %edx)
itoa_A_C1:
  movl A, %eax
  movb $10, %bl
  divb %bl #in ah c'è il resto
  addb $48, %ah
  cmpb $0, %al
  je una_cifra_A_C1
  jmp due_cifre_A_C1
una_cifra_A_C1:
  incl %edx
  movb $48, (%edi, %edx)
  incl %edx
  movb %ah, (%edi, %edx)
  incl %edx
  movb $45, (%edi, %edx)
due_cifre_A_C1:
  incl %edx
  addb $48, %al
  movb %al, (%edi, %edx)
  incl %edx
  movb %ah, (%edi, %edx)
  incl %edx
  movb $45, (%edi, %edx)
itoa_B_C:
  movl B, %eax
  movb $10, %bl
  divb %bl #in ah c'è il resto
  addb $48, %ah
  cmpb $0, %al
  je una_cifra_B_C
  jmp due_cifre_B_C
una_cifra_B_C:
  incl %edx
  movb $48, (%edi, %edx)
  incl %edx
  movb %ah, (%edi, %edx)
  incl %edx
  movb $45, (%edi, %edx)
  jmp itoa_C_C
due_cifre_B_C:
  incl %edx
  addb $48, %al
  movb %al, (%edi, %edx)
  incl %edx
  movb %ah, (%edi, %edx)
  incl %edx
  movb $45, (%edi, %edx)
  jmp itoa_C_C
itoa_C_C:
  movl C, %eax
  movb $10, %bl
  divb %bl #in ah c'è il resto
  addb $48, %ah
  cmpb $0, %al
  je una_cifra_C_C
  jmp due_cifre_C_C
una_cifra_C_C:
  incl %edx
  movb $48, (%edi, %edx)
  incl %edx
  movb %ah, (%edi, %edx)
  incl %edx
  movb $45, (%edi, %edx)
  jmp semafori
due_cifre_C_C:
  incl %edx
  addb $48, %al
  movb %al, (%edi, %edx)
  incl %edx
  movb %ah, (%edi, %edx)
  incl %edx
  movb $45, (%edi, %edx)
  jmp semafori

uscita:
  movb (%esi, %ecx), %al
  cmpb $79, %al
  jne fine_riga_corrotta
  incl %ecx
  movb (%esi, %ecx), %al
  cmpb $85, %al
  jne fine_riga_corrotta
  incl %ecx
  movb (%esi, %ecx), %al
  cmpb $84, %al
  jne fine_riga_corrotta
  incl %ecx
  movb (%esi, %ecx), %al
  cmpb $45, %al
  jne fine_riga_corrotta
  incl %ecx
  movb (%esi, %ecx), %al
  cmpb $65, %al
  je check_uscita_A
  cmpb $66, %al
  je check_uscita_B
  cmpb $67, %al
  je check_uscita_C
  jmp fine_riga_corrotta
  #controllare da quale settore si vuole uscire
  #je debug_out
  #jmp interrupt_di_sistema

check_uscita_A:
  decl A
  movb $67, (%edi, %edx)
  incl %edx
  movb $79, (%edi, %edx)
  incl %edx
  movb $45, (%edi, %edx)
  incl %edx
itoa_A1_USCITA1:
  movl A, %eax
  movb $10, %bl
  divb %bl #in ah c'è il resto
  addb $48, %ah
  cmpb $0, %al
  je una_cifra_A1_USCITA1
  jmp due_cifre_A1_USCITA1
una_cifra_A1_USCITA1:
  #incl %edx
  movb $48, (%edi, %edx)
  incl %edx
  movb %ah, (%edi, %edx)
  incl %edx
  movb $45, (%edi, %edx)
  jmp itoa_B1_USCITA1
due_cifre_A1_USCITA1:
  #incl %edx
  addb $48, %al
  movb %al, (%edi, %edx)
  incl %edx
  movb %ah, (%edi, %edx)
  incl %edx
  movb $45, (%edi, %edx)
itoa_B1_USCITA1:
  movl B, %eax
  movb $10, %bl
  divb %bl #in ah c'è il resto
  addb $48, %ah
  cmpb $0, %al
  je una_cifra_B1_USCITA1
  jmp due_cifre_B1_USCITA1
una_cifra_B1_USCITA1:
  incl %edx
  movb $48, (%edi, %edx)
  incl %edx
  movb %ah, (%edi, %edx)
  incl %edx
  movb $45, (%edi, %edx)
  jmp itoa_C_USCITA1
due_cifre_B1_USCITA1:
  incl %edx
  addb $48, %al
  movb %al, (%edi, %edx)
  incl %edx
  movb %ah, (%edi, %edx)
  incl %edx
  movb $45, (%edi, %edx)
itoa_C1_USCITA1:
  movl C, %eax
  movb $10, %bl
  divb %bl #in ah c'è il resto
  addb $48, %ah
  cmpb $0, %al
  je una_cifra_C1_USCITA1
  jmp due_cifre_C1_USCITA1
una_cifra_C1_USCITA1:
  incl %edx
  movb $48, (%edi, %edx)
  incl %edx
  movb %ah, (%edi, %edx)
  incl %edx
  movb $45, (%edi, %edx)
  jmp semafori
due_cifre_C1_USCITA1:
  incl %edx
  addb $48, %al
  movb %al, (%edi, %edx)
  incl %edx
  movb %ah, (%edi, %edx)
  incl %edx
  movb $45, (%edi, %edx)
  jmp semafori

check_uscita_B:
  decl B
  movb $67, (%edi, %edx)
  incl %edx
  movb $79, (%edi, %edx)
  incl %edx
  movb $45, (%edi, %edx)
  incl %edx
itoa_A_USCITA1:
  movl A, %eax
  movb $10, %bl
  divb %bl #in ah c'è il resto
  addb $48, %ah
  cmpb $0, %al
  je una_cifra_A_USCITA1
  jmp due_cifre_A_USCITA1
una_cifra_A_USCITA1:
  #incl %edx
  movb $48, (%edi, %edx)
  incl %edx
  movb %ah, (%edi, %edx)
  incl %edx
  movb $45, (%edi, %edx)
  jmp itoa_B_USCITA1
due_cifre_A_USCITA1:
  #incl %edx
  addb $48, %al
  movb %al, (%edi, %edx)
  incl %edx
  movb %ah, (%edi, %edx)
  incl %edx
  movb $45, (%edi, %edx)
itoa_B_USCITA1:
  movl B, %eax
  movb $10, %bl
  divb %bl #in ah c'è il resto
  addb $48, %ah
  cmpb $0, %al
  je una_cifra_B_USCITA1
  jmp due_cifre_B_USCITA1
una_cifra_B_USCITA1:
  incl %edx
  movb $48, (%edi, %edx)
  incl %edx
  movb %ah, (%edi, %edx)
  incl %edx
  movb $45, (%edi, %edx)
  jmp itoa_C_USCITA1
due_cifre_B_USCITA1:
  incl %edx
  addb $48, %al
  movb %al, (%edi, %edx)
  incl %edx
  movb %ah, (%edi, %edx)
  incl %edx
  movb $45, (%edi, %edx)
itoa_C_USCITA1:
  movl C, %eax
  movb $10, %bl
  divb %bl #in ah c'è il resto
  addb $48, %ah
  cmpb $0, %al
  je una_cifra_C_USCITA1
  jmp due_cifre_C_USCITA1
una_cifra_C_USCITA1:
  incl %edx
  movb $48, (%edi, %edx)
  incl %edx
  movb %ah, (%edi, %edx)
  incl %edx
  movb $45, (%edi, %edx)
  jmp semafori
due_cifre_C_USCITA1:
  incl %edx
  addb $48, %al
  movb %al, (%edi, %edx)
  incl %edx
  movb %ah, (%edi, %edx)
  incl %edx
  movb $45, (%edi, %edx)
  jmp semafori

check_uscita_C:
  decl C
  movb $67, (%edi, %edx)
  incl %edx
  movb $79, (%edi, %edx)
  incl %edx
  movb $45, (%edi, %edx)
  incl %edx
itoa_A_uscita:
  movl A, %eax
  movb $10, %bl
  divb %bl #in ah c'è il resto
  addb $48, %ah
  cmpb $0, %al
  je una_cifra_A_USCITA
  jmp due_cifre_A_USCITA
una_cifra_A_USCITA:
  #incl %edx
  movb $48, (%edi, %edx)
  incl %edx
  movb %ah, (%edi, %edx)
  incl %edx
  movb $45, (%edi, %edx)
  jmp itoa_B_USCITA
due_cifre_A_USCITA:
  #incl %edx
  addb $48, %al
  movb %al, (%edi, %edx)
  incl %edx
  movb %ah, (%edi, %edx)
  incl %edx
  movb $45, (%edi, %edx)
itoa_B_USCITA:
  movl B, %eax
  movb $10, %bl
  divb %bl #in ah c'è il resto
  addb $48, %ah
  cmpb $0, %al
  je una_cifra_B_USCITA
  jmp due_cifre_B_USCITA
una_cifra_B_USCITA:
  incl %edx
  movb $48, (%edi, %edx)
  incl %edx
  movb %ah, (%edi, %edx)
  incl %edx
  movb $45, (%edi, %edx)
  jmp itoa_C_USCITA
due_cifre_B_USCITA:
  incl %edx
  addb $48, %al
  movb %al, (%edi, %edx)
  incl %edx
  movb %ah, (%edi, %edx)
  incl %edx
  movb $45, (%edi, %edx)
itoa_C_USCITA:
  movl C, %eax
  movb $10, %bl
  divb %bl #in ah c'è il resto
  addb $48, %ah
  cmpb $0, %al
  je una_cifra_C_USCITA
  jmp due_cifre_C_USCITA
una_cifra_C_USCITA:
  incl %edx
  movb $48, (%edi, %edx)
  incl %edx
  movb %ah, (%edi, %edx)
  incl %edx
  movb $45, (%edi, %edx)
  jmp semafori
due_cifre_C_USCITA:
  incl %edx
  addb $48, %al
  movb %al, (%edi, %edx)
  incl %edx
  movb %ah, (%edi, %edx)
  incl %edx
  movb $45, (%edi, %edx)

semafori:
semaforo_A:
  incl %edx
  cmpb $31, A
  je A_1
  jne A_0
A_1:
  movb $49, (%edi, %edx)
  jmp semaforo_B
A_0:
  movb $48, (%edi, %edx)
semaforo_B:
  incl %edx
  cmpb $31, B
  je B_1
  jne B_0
B_1:
  movb $49, (%edi, %edx)
  jmp semaforo_C
B_0:
  movb $48, (%edi, %edx)
semaforo_C:
  incl %edx
  cmpb $24, C
  je C_1
  jne C_0
C_1:
  movb $49, (%edi, %edx)
  jmp a_capo
C_0:
  movb $48, (%edi, %edx)
  jmp a_capo

a_capo:
  incl %edx
  movb $10, (%edi, %edx)
  incl %edx

fine_riga:
  incl %ecx
  movb (%esi, %ecx), %al
  cmpb newline, %al
  je accensione_parcheggio
  jmp fine_riga

fine_riga_corrotta:
  movb $67, (%edi, %edx)
  incl %edx
  movb $67, (%edi, %edx)
  incl %edx
  movb $45, (%edi, %edx)
  incl %edx
itoa_A_CORROTTA:
  movl A, %eax
  movb $10, %bl
  divb %bl #in ah c'è il resto
  addb $48, %ah
  cmpb $0, %al
  je una_cifra_a_corrotta
  jmp due_cifre_a_corrotta
una_cifra_a_corrotta:
  #incl %edx
  movb $48, (%edi, %edx)
  incl %edx
  movb %ah, (%edi, %edx)
  incl %edx
  movb $45, (%edi, %edx)
  jmp itoa_B_CORROTTA
due_cifre_a_corrotta:
  #incl %edx
  addb $48, %al
  movb %al, (%edi, %edx)
  incl %edx
  movb %ah, (%edi, %edx)
  incl %edx
  movb $45, (%edi, %edx)
itoa_B_CORROTTA:
  movl B, %eax
  movb $10, %bl
  divb %bl #in ah c'è il resto
  addb $48, %ah
  cmpb $0, %al
  je una_cifra_B_corrotta
  jmp due_cifre_B_corrotta
una_cifra_B_corrotta:
  incl %edx
  movb $48, (%edi, %edx)
  incl %edx
  movb %ah, (%edi, %edx)
  incl %edx
  movb $45, (%edi, %edx)
  jmp itoa_C_CORROTTA
due_cifre_B_corrotta:
  incl %edx
  addb $48, %al
  movb %al, (%edi, %edx)
  incl %edx
  movb %ah, (%edi, %edx)
  incl %edx
  movb $45, (%edi, %edx)
itoa_C_CORROTTA:
  movl C, %eax
  movb $10, %bl
  divb %bl #in ah c'è il resto
  addb $48, %ah
  cmpb $0, %al
  je una_cifra_C_corrotta
  jmp due_cifre_C_corrotta
una_cifra_C_corrotta:
  incl %edx
  movb $48, (%edi, %edx)
  incl %edx
  movb %ah, (%edi, %edx)
  incl %edx
  movb $45, (%edi, %edx)
  jmp semafori
due_cifre_C_corrotta:
  incl %edx
  addb $48, %al
  movb %al, (%edi, %edx)
  incl %edx
  movb %ah, (%edi, %edx)
  incl %edx
  movb $45, (%edi, %edx)
  jmp semafori

interrupt_di_sistema:
  popl %ebx
  popl %ebp
  ret
