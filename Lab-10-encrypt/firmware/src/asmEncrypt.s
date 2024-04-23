/*** asmEncrypt.s   ***/

#include <xc.h>

# Declare the following to be in data memory 
.data  

# Define the globals so that the C code can access them
# (in this lab we return the pointer, so strictly speaking,
# doesn't really need to be defined as global)
# .global cipherText
.type cipherText,%gnu_unique_object

.align
# space allocated for cipherText: 200 bytes, prefilled with 0x2A */
cipherText: .space 200,0x2A  
 testText1: .asciz "ABCXYZ"
 testText2: .asciz "BCXYZA"
# Tell the assembler that what follows is in instruction memory    
.text
.align

# Tell the assembler to allow both 16b and 32b extended Thumb instructions
.syntax unified

    
/********************************************************************
function name: asmEncrypt
function description:
     pointerToCipherText = asmEncrypt ( ptrToInputText , key )
     
where:
     input:
     ptrToInputText: location of first character in null-terminated
                     input string. Per calling convention, passed in via r0.
     key:            shift value (K). Range 0-25. Passed in via r1.
     
     output:
     pointerToCipherText: mem location (address) of first character of
                          encrypted text. Returned in r0
     
     function description: asmEncrypt reads each character of an input
                           string, uses a shifted alphabet to encrypt it,
                           and stores the new character value in memory
                           location beginning at "cipherText". After copying
                           a character to cipherText, a pointer is incremented 
                           so that the next letter is stored in the bext byte.
                           Only encrypt characters in the range [a-zA-Z].
                           Any other characters should just be copied as-is
                           without modifications
                           Stop processing the input string when a NULL (0)
                           byte is reached. Make sure to add the NULL at the
                           end of the cipherText string.
     
     notes:
        The return value will always be the mem location defined by
        the label "cipherText".
     
     
********************************************************************/    
.global asmEncrypt
.type asmEncrypt,%function
asmEncrypt:   

    # save the caller's registers, as required by the ARM calling convention
    push {r4-r11,LR}
    
    /* YOUR asmEncrypt CODE BELOW THIS LINE! VVVVVVVVVVVVVVVVVVVVV  */
    mov r11,0x00
    mov r6,r1
    cmp r6,0
    mov r4,0
    ldr r10,= cipherText
    beq done
    
    loop:
    mov r5,r0
    ldrb r5,[r5,r4]
    
    cmp r5,0x00
    beq reach_null
    cmp r5,'A'
    blt other_char
    cmp r5,'Z'
    ble Upper_enc
    
    cmp r5,'a'
    blt other_char
    cmp r5,'z'
    ble Lower_enc
    
    Upper_enc:
    add r5,r5,r6
    cmp r5,'Z'
    subgt r5,r5,26
    b store
    
    Lower_enc:
    add r5,r5,r6
    cmp r5,'z'
    subgt r5,r5,26
    b store
    
    other_char:
    
    store:
    strb r5,[r10,r4]
    add r4,r4,1
    b loop
    
    reach_null:
    strb r11,[r10,r4]
    ldr	 r0,=cipherText
    done:
    /* YOUR asmEncrypt CODE ABOVE THIS LINE! ^^^^^^^^^^^^^^^^^^^^^  */

    # restore the caller's registers, as required by the ARM calling convention
    pop {r4-r11,LR}

    mov pc, lr	 /* asmEncrypt return to caller */
   

/**********************************************************************/   
.end  /* The assembler will not process anything after this directive!!! */
           




