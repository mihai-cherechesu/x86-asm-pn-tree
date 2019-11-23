%include "/home/learning/Desktop/Anul_2/IOCLA/iocla-tema1-resurse/includes/io.inc"
                                            ; Am pus calea absoluta pentru io.inc
extern getAST
extern freeAST

section .bss
    ; La aceasta adresa, scheletul stocheaza radacina arborelui
    root: resd 1

section .text
global main
main:
    mov ebp, esp; for correct debugging
    ; NU MODIFICATI
    push ebp
    mov ebp, esp
    
    ; Se citeste arborele si se scrie la adresa indicata mai sus
    call getAST
    mov [root], eax
    

            
    ; Implementati rezolvarea aici:

    mov ebx, [root]         ; Stocam adresa root-ului in reg general ebx
    xor eax, eax

_rec_:

    push ebx                ; Salvam pe stiva root-ul
    push ebp
    mov ebp, esp
   
        
    mov ecx, [ebx + 4]      ; Node *left    
    mov edx, [ebx + 8]      ; Node *right
    
    
;;;;;;;;;;;;;;;;;;;;;;;;;
PRINT_STRING "Root: "
PRINT_DEC 4, ebx
;;;;;;;;;;;;;;;;;;;;;;;;;
    NEWLINE
PRINT_STRING "Child LEFT: "
PRINT_DEC 4, ecx
;;;;;;;;;;;;;;;;;;;;;;;;;
    NEWLINE
PRINT_STRING "Child RIGHT: "
PRINT_DEC 4, edx
    NEWLINE
;;;;;;;;;;;;;;;;;;;;;;;;;

    
    test ecx, ecx           ; Verificam daca e frunza: ecx == 0x0
    jz _leaf_
    
    call _l_adv_ 
    
_b_l_adv_:
    push eax                ; Rezultatul din atoi salvam pe stiva
    mov ecx, [ebx + 4]      ; Node *left update
    mov edx, [ebx + 8]      ; Node *right update
    NEWLINE
    PRINT_STRING "LEFT subtree result: "
    PRINT_DEC 4, eax
    NEWLINE
    call _r_adv_            
_b_r_adv_:
    push eax
   
    mov ecx, [ebx + 4]      ; Node *left update
    mov edx, [ebx + 8]      ; Node *right update
    
    xor edi, edi            ; Resetarea valorii din subarborele drept
    xor esi, esi            ; Resetarea valorii din subarborele stang
    pop edi                 ; Valoarea de pe subarborele drept
    pop esi                 ; Valoarea de pe subarborele stang
    NEWLINE
    PRINT_STRING "VALORILE DIN SUBARBORI: "
    NEWLINE
    PRINT_DEC 4, esi
    NEWLINE
    PRINT_DEC 4, edi
    mov eax, ebx            ; Punem adresa root-ului in eax pentru
                            ; Determinarea operatiei dintre valori
    jmp _op_
    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
_l_adv_:
    NEWLINE
    PRINT_STRING "LEFT advance"
    NEWLINE
    mov ebx, ecx          ; root = root->left
    call _rec_
    
_b_l_leaf_:
    mov ebx, [ebp + 4]      ; Actualizam root-ul cu parintele leaf-ului
    NEWLINE
    PRINT_STRING "IESIRE DIN RECURS CU ROOT LEF: "
    PRINT_DEC 4, ebx
    NEWLINE
    ret
    
_r_adv_:
    NEWLINE
    PRINT_STRING "RIGHT advance"
    NEWLINE
    mov ebx, edx
    PRINT_STRING "RIGHT ROOT IN ADV: "
    PRINT_DEC 4, ebx
    NEWLINE
    call _rec_
    
_b_r_leaf_:
    mov ebx, [ebp + 4]
    NEWLINE
    PRINT_STRING "IESIRE DIN RECURS CU ROOT RIG: "
    PRINT_DEC 4, ebx
    NEWLINE
    ret
   
   
_leaf_:
    PRINT_STRING "HERE A LEAF: "
    NEWLINE
    mov eax, [ebx]          ; Salvam in eax adresa de inceput a char*
    call _pre_atoi_
    
_b_atoi_:
    pop ebp
    pop ebx
    
    ret                     ; Ne intoarcem din recursivitate cu int-ul
    
    
_pre_atoi_:                 ; Foloseste ebx, ecx, edx, edi si implicit eax
                            ; Pregatire pentru executia procedurii atoi            
    push ebx                ; Salvam valorile pe stiva din procedura anterioara
    push ecx                ;
    push edx                ;
    push edi
                          
    xor ebx, ebx            ; Partea lower va stoca byte-ul citit
    xor ecx, ecx            ; Va stoca numarul rezultat pe 4 bytes
    xor edx, edx            ; Auxiliar pentru inmultirea cu 10
    xor edi, edi            ; Trigger pentru numar negativ

_atoi_:                     ; Transforma din string in int
                            ; Functioneaza pt. signed/unsigned                           
    mov bl, byte [eax]      ; Mutam primul char din *data
    PRINT_STRING "CHAR-UL: "
    PRINT_DEC 1, bl
    NEWLINE
    
    cmp bl, 0x2d            ; Verificam dac byte-ul e '-'
    jz _mem_neg_            ; Numarul e negativ
    
    test bl, bl             ; Verificam daca byte-ul e '\0'
    jz _is_neg_
    jmp _tran_
            
_mem_neg_:
    mov edi, 0x1            ; Tinem evidenta daca numarul e negativ
    jmp _nx_chr_            ; Trecem la urmatorul char
    
_is_neg_:                   
    cmp edi, 0x1            ; Verifica daca trigger-ul e activ
    jnz _not_neg_
                  
    neg ecx                 ; Neaga intregul final stocat in ecx
    
_not_neg_:
    mov eax, ecx            ; Mutam valoarea de return in eax   

    pop edi                 ; Scoatem de pe stiva vechile valori
    pop edx                 
    pop ecx
    pop ebx
    PRINT_STRING "CU ATOI OBTINEM: "
    PRINT_DEC 4, eax
    ret                     ; Ne intoarcem unde pointeaza eip si cu
                            ; valoarea transformata a nodului in eax
            
_tran_:

    sub bl, 48              ; Transformare din string in int
    mov edx, ecx            ; Pastram acelasi ecx pana la shiftare
                            ; Mul cu 10: (x << 3) + (x << 1)
    shl edx, 1              ;               :     :  x << 1
    shl ecx, 3              ;             x << 3  :    :
    add ecx, edx            ;               :     +    :

    movzx ebx, bl           ; Extindem semnul pentru a opera
    add ecx, ebx            ; Adaugam cifra transformata la numar
    
_nx_chr_:    
    inc eax                 ; Trecem la urmatorul char din string
    jmp _atoi_


_op_:                       ; Stabilim ce tip de operatie se executa
                            ; Intre left child si right child
    mov ecx, [eax]
    mov bl, byte [ecx]   
    NEWLINE
    PRINT_STRING "TIPUL DE OPERATIE: "
    PRINT_DEC 1, bl
    NEWLINE
                                                              
    cmp bl, 45            ; Char '-', ASCII: 45
    jz _sub_                
    cmp bl, 43            ; Char '+', ASCII: 43    
    jz _add_
    cmp bl, 42            ; Char '*', ASCII: 42
    jz _mul_
    cmp bl, 47            ; Char '/', ASCII: 47
    jz _div_

_sub_:
    mov ebx, eax            ; Revenim cu adresa de root in ebx nealterat
    sub esi, edi
    mov eax, esi
    jmp _ret_rec_
    
_add_:
    mov ebx, eax            ; Revenim cu adresa de root in ebx nealterat
    add esi, edi
    mov eax, esi
    jmp _ret_rec_

_mul_:
    mov ebx, eax            ; Revenim cu adresa de root in ebx nealterat
    mov eax, edi
    imul esi
    jmp _ret_rec_
    
_div_: 
    PRINT_STRING "INTRAM IN DIV!"
    NEWLINE 
    mov ebx, eax            ; Revenim cu adresa de root in ebx nealterat
    PRINT_STRING "REVENIREA LA ROOT NEALTERAT: "
    PRINT_DEC 4, ebx
    NEWLINE
    mov eax, esi
    cdq
    idiv edi
    
    PRINT_STRING "REZULTATUL IMPARTIRII: "
    PRINT_DEC 4, eax
    NEWLINE
    
; Return in recursivitate cu expresia evaluata si pusa in eax
_ret_rec_:                  
    cmp ebx, [root]         ; Comparatie cu root: ultima operatie din arbore
    jz exit
    PRINT_STRING "NOT THE LAST OP"
    
    pop ebp
    pop ebx
    ret
   

exit:    
    pop ebp
    pop ebx
    NEWLINE
    PRINT_STRING "LAST RESULT: "
    PRINT_DEC 4, eax        ; Afisarea rezultatului
    
    ; Se elibereaza memoria alocata pentru arbore
    push dword [root]
    call freeAST
    
    xor eax, eax
    leave
    ret