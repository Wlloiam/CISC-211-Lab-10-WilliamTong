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
    
    mov r11,0x00	    /*storing the null point value in r11.This is for checking the string reach the nul point or not*/
    mov r6,r1		    /*storing the input key value in r6 */
    cmp r6,0		    /*comparing the key value with 0. If 0, the output does not change. */
    beq done		    /*If the input equals to zero, the output remain the same, and does not change anything*/
    mov r4,0		    /*storing the 0 in r4 for the index*/
    ldr r10,= cipherText    /*storing the address of cipherText in  r10*/		    
    /*If the input key does not equal 0, we will encrypt the input message. This is the beginng of the loop for the encrypting message
     This loop will perform until the nul point is reached in the string*/
    loop:
    mov r5,r0		    /*storing input text r0 in r5 */
    ldrb r5,[r5,r4]	    /*storing a byte from memory location of [r5+r4] in r5*/
    
    cmp r5,0x00		    /*compare a byte located r5 with 0, which is nul value*/
    beq reach_null	    /*If r5 equals to 0, the loop will stop and direct to the reach_null branch*/
    cmp r5,'A'		    /*comapre the r5 with ASCII code value of A,which is 0x41*/
    blt other_char	    /*If the value in r5 is lower than 0x41, it means it is not in the range of A-Z, a-z, so will direct to other_char branch*/
    cmp r5,'Z'		    /*If the r5 is greater than or equal, will compare r5 with the ASCII code value of Z again*/
    ble Upper_enc	    /*If the r5 is lower than or equal to r5, it is in range of A-Z, so will direct to the Upper_enc branch*/
    /*If the r5 value is greater than the value of Z, check the r5 value is within the range of a-z or not, if not direct to the other_char branch*/
    cmp r5,'a'		    /*compare the r5 value with the ASCII code vaule of a, which is 0x61*/
    blt other_char	    /*If the r5 value is lower than the value of a, will direct to the other_char branch*/
    cmp r5,'z'		    /*If the r5 value is not lower than the value of a, compare the ASCII code value of z to check r5 is within the range of a-z or not*/
    ble Lower_enc	    /*If the r5 value is lower than or equal to the value of z, it is within the range of a-z, and will direct to the Lower_enc branch*/
    b other_char	    /*If the r5 value is greater than the value of z, will direct to the other_char branch*/
    
    /**This is the Upper_enc branch. This is for encrypting the text for the upper case character A-Z**/
    Upper_enc:
    add r5,r5,r6	    /*adding the key value, which is located in r6, to the value in r5, and store the result in r5*/
    cmp r5,'Z'		    /*comparing the result value in r5 with ascii code value of Z*/
    subgt r5,r5,26	    /*If the result value in r5 is greater than the value of Z, substract 26 from r5 and store it in r5*/
    b store		    /*directing to the store branch to store the encrypted char*/
    
    /**This is the Lower_enc branch. This is for encrypting the text for the lower case character a-z**/
    Lower_enc:
    add r5,r5,r6	    /*adding the key value, which is located in r6, to the value in r5, and store the result in r5*/
    cmp r5,'z'		    /*comparing the result value in r5 with the ASCII code value of z*/
    subgt r5,r5,26	    /*If the result value in r5 is greater than the value of z, substract 26 from r5 and store it in r5*/
    b store		    /*directing to the store branch to store the encrypted char*/
    /*Since the other_char, which is not A-Z, a-z, are not required to encrypt, it will just copy the value*/
    other_char:
    /**This is the sotre branch for storing the character in meomry location of the cipherText which is [r10+r4], byte by byte*/
    store:
    strb r5,[r10,r4]	    /*storing encrypted char which is in r5 in the memory location of cipherText,which is [r10+r4] by byte by byte*/
    add r4,r4,1		    /*adding 1 to r4, to increment the memory location of cipherText*/
    b loop		    /*directing to the loop brach*/
    /*This is the reach_null branch, which is for when the input r5 reachs the null point in input string. This will store the null point value in last address in
     memory location of CipherText, which is [r10+r4]*/
    reach_null:
    strb r11,[r10,r4]	    /*storing the ASCII code value of null point char in memory location of of cipherText,which is [r10+r4]*/
    ldr	 r0,=cipherText	    /*store the cipherText value into r0*/
    /*This is the end of the asmEncrypt function*/
    done:
    /* YOUR asmEncrypt CODE ABOVE THIS LINE! ^^^^^^^^^^^^^^^^^^^^^  */

    # restore the caller's registers, as required by the ARM calling convention
    pop {r4-r11,LR}

    mov pc, lr	 /* asmEncrypt return to caller */
   

/**********************************************************************/   
.end  /* The assembler will not process anything after this directive!!! */
           




