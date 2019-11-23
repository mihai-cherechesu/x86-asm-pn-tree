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
    
    call getAST
    mov [root], eax

    mov ebx, [root]         ; Stocam adresa root-ului in reg general ebx
    xor eax, eax

_rec_:                      ; Functie care da push la root pe stack,
                            ; verifica natura nodurilor (leaf, !leaf) si
                            ; initiaza call-urile recursive in subarborii
                            ; stang, respectiv drept

    push ebx                ; Salvam pe stiva root-ul
    push ebp                ; Salvam base-pointer pentru stack-frame-ul curent
    mov ebp, esp            ; Trecem la next frame
   
        
    mov ecx, [ebx + 4]      ; Node *left    
    mov edx, [ebx + 8]      ; Node *right

    
    test ecx, ecx           ; Verificam daca e frunza: ecx e NULL
    jz _leaf_               ; Jump daca ZF = 1
    
    call _l_adv_            ; Avans in subarborele stang
_b_l_adv_:                  ; eip de retur dupa call-ul _l_adv_

    push eax                ; Rezultatul din atoi salvam pe stiva
    mov ecx, [ebx + 4]      ; Node *left update
    mov edx, [ebx + 8]      ; Node *right update
    
    call _r_adv_            ; Avans in subarborele drept
_b_r_adv_:                  ; eip de retur dupa call-ul _r_adv_

    push eax
    mov ecx, [ebx + 4]      ; Node *left update
    mov edx, [ebx + 8]      ; Node *right update
    
    xor edi, edi            ; Resetarea valorii din subarborele drept
    xor esi, esi            ; Resetarea valorii din subarborele stang
    pop edi                 ; Valoarea de pe subarborele drept
    pop esi                 ; Valoarea de pe subarborele stang
    mov eax, ebx            ; Punem adresa root-ului in eax pentru
                            ; Determinarea operatiei dintre valori
    jmp _op_
    
    
_l_adv_:                    
    mov ebx, ecx            ; root = root->left
    call _rec_              ; Call recursiv backwards
    
_b_l_leaf_:
    mov ebx, [ebp + 4]      ; Actualizam root-ul cu parintele leaf-ului
    ret                     ; Retur la eip de pe stack: _b_l_adv_
    
_r_adv_:
    mov ebx, edx            ; root = root->right
    call _rec_              ; Call recursiv backwards
    
_b_r_leaf_:
    mov ebx, [ebp + 4]      ; Actualizam root-ul cu parintele leaf-ului
    ret                     ; Retur la eip de pe stack: _b_r_adv_
   
   
_leaf_:
    mov eax, [ebx]          ; Salvam in eax adresa de inceput a char*
    call _pre_atoi_         ; Call functiei de transformare in int
    
_b_atoi_:                   ; Eip pentru intoarcerea din _atoi_
    pop ebp                 ; Scoatem de pe stiva stack-frame-ul
    pop ebx                 ; pe care l-am terminat de calculat
                            ; si pentru a ne putea intoarce la eip de pe stack
    
    ret                     ; Ne intoarcem din recursivitate cu int-ul
    
    
_pre_atoi_:                 ; Foloseste ebx, ecx, edx, edi si implicit eax
                            ; Pregatire pentru executia procedurii atoi            
    push ebx                ; Salvam valorile pe stiva din procedura anterioara
    push ecx                ;
    push edx                ;
    push edi                ;   
                          
    xor ebx, ebx            ; Partea lower va stoca byte-ul citit
    xor ecx, ecx            ; Va stoca numarul rezultat pe 4 bytes
    xor edx, edx            ; Auxiliar pentru inmultirea cu 10
    xor edi, edi            ; Trigger pentru numar negativ

_atoi_:                     ; Transforma din string in int
                            ; Functioneaza pt. signed/unsigned                           
    mov bl, byte [eax]      ; Mutam primul char din *data
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
                                                              
    cmp bl, 45              ; Char '-', ASCII: 45
    jz _sub_                
    cmp bl, 43              ; Char '+', ASCII: 43    
    jz _add_
    cmp bl, 42              ; Char '*', ASCII: 42
    jz _mul_
    cmp bl, 47              ; Char '/', ASCII: 47
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
    mov ebx, eax            ; Revenim cu adresa de root in ebx nealterat
    mov eax, esi
    cdq                     ; Sign extend de la double la quad pentru idiv
    idiv edi
    

_ret_rec_:                  ; Return in recursivitate cu expresia evaluata si pusa in eax
    cmp ebx, [root]         ; Comparatie cu root: ultima operatie din arbore
    jz exit
    
    pop ebp
    pop ebx
    ret
   

exit:                       ; Exit-ul final din program
    pop ebp                 
    pop ebx
    PRINT_DEC 4, eax        ; Afisarea rezultatului final
    
    push dword [root]
    call freeAST
    
    xor eax, eax
    leave
    ret