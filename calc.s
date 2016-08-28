STACK_SIZE EQU 5

section .data
	num1 dd '2'

section .rodata
	LC0:
        	DB "%s",10, 0
	LC1:
        	DB "calc: ",0
	LC2:
        	DB "%d",10, 0
	LC4:
        	DB "%02x", 0
	LC6:
        	DB "%x", 0
	LC7:
        	DB "A new element was pushed into the stack: ",0
	LC5:
        	DB "%02x",10,0
	LC9:
        	DB "%x",10

	newline:
		DB "",10,0

        Illegal_Input_Error:
                DB "Error: Illegal Input",0

        Insufficient_Number_of_Arguments:
                DB "Error: Insufficient Number of Arguments on Stack",0

        Stack_Overflow_Error:
                DB "Error: Operand Stack Overflow",0
       
	LC3:
        	DB "debug mode" ,10,0

	debug:
        	DB "-d",10, 0

section .bss
        STACK_AS_ARRAY:
                RESB STACK_SIZE*4

	INPUT:
        	RESB 80

	INPUT_PTR:
		RESB 4

        DEBUG_MODE:
 		RESB 4

	POP_AND_PRINT:
        	RESB 80

	NUM_OF_OPERATIONS:
                RESB 4

        INPUT_PART:
                RESB 4

        CURRENT_SIZE:
                RESB 4

        ADDRESS_NODE:
		RESB 4

        TOP_STACK:
                RESB 4

        FORMER_ADDRESS:
 		RESB 4

        FORMER_DUPLICATE_ADDRESS:
 		RESB 4

        CURRENT_NUMBER_SIZE:
                RESB 4

	CURRENT_MALLOC_ADDRESS:
		RESB 4
	
	FIRST_NODE_FLAG:	
		RESB 4

	DUPLICATE_TYPE:
		RESB 4

	ODD_CASE:
		RESB 4

	ODD_CASE_DONE:
		RESB 4

	TEMP:
		RESB 4
	A:
		RESB 4
	B: 
		RESB 4
	C:
		RESB 4

	C_FIRST_CHAIN_ANSWER:
		RESB 4

	CARRY_STATUS:
		RESB 4

	MALLOC_ADDRESS:
		RESB 4

	FORMER_MALLOC_ADDRESS:
		RESB 4

	CURRENT_BYTE:
		RESB 4
        QUIT:
                RESB 1

section .text
        align 16
        global main
        extern printf
        extern fprintf
        extern malloc
        extern free
        extern gets
        extern stderr
        extern stdin
        extern stdout
	extern fflush


main:   ;initialize all vars
        mov byte [QUIT],0
        mov dword [ODD_CASE],0
        mov dword [ODD_CASE_DONE],0
        mov dword [ADDRESS_NODE],0
        mov dword [NUM_OF_OPERATIONS],0
        mov dword [CURRENT_SIZE],0
	mov dword [FORMER_DUPLICATE_ADDRESS],0
	mov dword [FIRST_NODE_FLAG],0
	mov dword [CARRY_STATUS],0
	mov dword [DUPLICATE_TYPE],0
        mov dword eax, STACK_AS_ARRAY
        sub eax,4
        mov dword [TOP_STACK], eax

        call    my_calc
        call printNUMOFOPERATIONS
        ret


	my_calc:   push    ebp             ; Save caller state
                   mov     ebp, esp
                   sub     esp, 4          ; Leave space for local var on stack
                   pushad                  ; Save some more caller state

		   debugCHECK:	cmp dword [ebp+12],1
				je main_loop
				mov eax, dword [ebp+16]
				mov ebx, dword [eax+4]
				cmp byte [ebx], '-'
				jne main_loop
				cmp byte [ebx+1],'d'
				jne main_loop
				cmp byte [ebx + 2],0
				jne main_loop
				mov dword [DEBUG_MODE],1
				

                   main_loop:         ; printing "calc: "
                                      call printCALC
                                  
				      ;get new input to INPUT
        			      call  readINPUT   
                                    
                                      ;evaluating the input
       				      call evaluateINPUT

                                      postEvaluation: mov DL,[QUIT]
                                                      cmp DL,1
                                                      jne main_loop

                   mov     [ebp-4], eax    ; Save returned value...
    		   popad                   ; Restore caller state (registers)
    		   mov     eax, [ebp-4]    ; place returned value where caller can see it
   		   add     esp, 4          ; Restore caller state
   		   pop     ebp             ; Restore caller state
    		   ret                     ; Back to caller


                   printCALC:   push  LC1
        		        call printf
       				add  esp,4
                                ret

		   readINPUT:   push INPUT
                           	call gets            
                          	add   esp, 4          
                          	ret

                   evaluateINPUT: 	mov ecx,[INPUT]
        				shl ecx,24
       					shr ecx,24
        				cmp ecx,43
       				 	je addition
       					cmp ecx,38
       				        je bitwiseAND
      				        cmp ecx,113
      				        je quit
      					cmp ecx,100
      					je duplicate
       					cmp ecx,112
       				        je popANDprint
       				        cmp ecx,48
       				        jae range
                                        jb illegal_input
       					range:   cmp ecx,57
              					 jbe number
                                                 ja illegal_input

					; we are performing C = A + B
       				        addition:     cmp dword [CURRENT_SIZE],2
						      jb printADDITIONERROR
						      mov eax, [TOP_STACK]
						      mov ebx,eax
						      sub ebx,4
						      mov ecx, [eax] ;first element to add (it's address)
						      mov edx, [ebx] ;second element to add (it's address)
						      mov dword [FIRST_NODE_FLAG],0
						      additionLOOP:    add dword [FIRST_NODE_FLAG],1
								       mov [A], ecx
								       mov [B], edx
								       mov ecx,[A]
								       cmp ecx,0
								       je setAZero
								       jne setANotZero  

								       setAZero:               mov edx,0
											       mov ecx, [B]
										       	       mov eax, [ecx]
										       	       and eax,255 ;B itself
											       jmp CONT_AFTER_SET

								       setANotZero:	       mov edx, [ecx]	
								      			       and edx,255 ;A itself 
											       mov ecx, [B]
										               cmp ecx, 0
											       je setBZero
										       	       mov eax, [ecx]
										       	       and eax,255 ;B itself
											       jmp CONT_AFTER_SET

								       setBZero:  	       mov eax,0 
   
								       CONT_AFTER_SET:         mov [TEMP],edx
											       mov DL, byte [TEMP] ;DL <- A
											       mov [TEMP],eax
											       mov AL, byte [TEMP] ;AL <- B
										               cmp dword [CARRY_STATUS],0
											       je dontADD
											       add AL,1
										 dontADD:      add AL,DL
											       daa
											       mov esi, 0
											       adc esi, 0 
											       mov dword [CARRY_STATUS],esi
											       mov [C],AL
											       push 5
											       call malloc
											       add esp, 4
											       mov edx,[MALLOC_ADDRESS]
											       mov [FORMER_MALLOC_ADDRESS],edx
											       mov [MALLOC_ADDRESS],eax
											       mov edx, [C]
											       mov [eax],edx
											       mov dword [eax+1],0
											       cmp dword [FIRST_NODE_FLAG],1
											       jne notFirstNodeCase
											       mov [C_FIRST_CHAIN_ANSWER],eax
											       jmp firstNodeCont
										       notFirstNodeCase:       mov esi, [FORMER_MALLOC_ADDRESS]
													       mov [esi+1],eax
 										       firstNodeCont:	       cmp dword [A],0
													       je doneA
													       mov edx, [A]
													       cmp dword [edx+1],0 ;are we done with A?
													       je doneA
													       mov ecx,[edx+1]     ;if not, get ready with the next A in the addition
													       cmp dword [B],0
													       je gohere
													       mov edx, [B]
													       cmp dword [edx+1],0 ;are we done with B?
													       jne prepareANDjump
												   gohere:     mov edx,0
													       jmp additionLOOP

													       doneA:           mov ecx,0 
																mov edx, [B]
																cmp edx,0
																je doneADDITION
																cmp dword [edx+1],0
																je doneADDITION
		 														mov ebx,[edx+1] ;the next B in the addition
																mov edx,ebx
																jmp additionLOOP
													       prepareANDjump:	mov ebx,[edx+1] ;the next B in the addition
																mov edx,ebx
													       			jmp additionLOOP
	
								      doneADDITION: cmp  dword [CARRY_STATUS],1   ;if we had carry that was not calculated.
										    je setZerosAndJump
										    call freeANDremoveTwoElements
									            mov edx, [TOP_STACK]
										    add edx,4
										    mov [TOP_STACK],edx
										    mov edx, [TOP_STACK]
										    mov ebx, [C_FIRST_CHAIN_ANSWER]
										    mov [edx],ebx
                                             					    mov ebx,[CURRENT_SIZE]
 										    add ebx,1
 									            mov [CURRENT_SIZE],ebx 
									            cmp dword [DEBUG_MODE],1
										    jne not_debug_mode
										    call printDEBUGMODE
										    call CorrectNUMOFOPERATIONS
										    mov dword [DUPLICATE_TYPE],1
										    call IncreaseNUMOFOPERATIONS
										    jmp duplicate
										    not_debug_mode: ret
										    call IncreaseNUMOFOPERATIONS ;if performed!!!
				 				  		    ret

								      setZerosAndJump:         mov eax,0
											       mov edx,0
											       add dword [FIRST_NODE_FLAG],1
											       jmp CONT_AFTER_SET

								      printADDITIONERROR:      call insufficient_num_of_args
											       ret






       					number:      mov ebx, [CURRENT_SIZE]
                                                     cmp ebx, STACK_SIZE
                                                     jae stack_overflow
                                                     jb insertNUMBER
                                                     ret

                                        insertNUMBER:   call removeLeadingZeros
                                                        call countNUMBER
                                                        call addNUMBER
                                                        ret 

							removeLeadingZeros:     mov dword [CURRENT_NUMBER_SIZE],0
										mov ecx,INPUT
										removeLOOP: mov eax,[ecx]
											    and eax, 255
											    cmp eax,48   ; if it is zero - we should ignore it
											    je removeANDcont
											    jne finishREMOVE

											    removeANDcont:  mov eax,[ecx+1]
													    cmp eax,0
													    je finishREMOVE  ;its just a zero!!!
													    mov dword ebx, [ecx]
													    and ebx,4294967040
													    mov dword [ecx],ebx
													    add ecx,1
													    jmp removeLOOP

											    finishREMOVE:   mov dword [INPUT_PTR],ecx
													    ret



                                                        countNUMBER:    mov edi,0 ;declares which part of INPUT we gonna check
                                                                        mov ebx,0 ;counts how many chars did we check
                                                                        iterateNUMBER:   mov ecx,[INPUT_PTR]
                                                                                         add ecx,edi
                                                                                         
                                                                                         bytes_loop:     mov eax,[ecx]
													 mov edx,ebx
													 cmp edx,0	
													 je no_shifting
												         shift:             shr eax,8
														            sub edx,1
 												   		            cmp edx,0
														            jnz shift

													 no_shifting:  	    and eax,255		 
 															    cmp eax,0 ;checks if it's the last char - gets() puts null terminated string at the end
                                                                                                       			    je foundLastCharacter
															    add ebx,1
                                                                                                       			    cmp ebx,4
                                                                                        				    jne bytes_loop
                                                                                                               
															    call updateCURRENTNUMBERSIZE
            														    mov ebx,0
															    add edi,4
															    jmp iterateNUMBER

					  								foundLastCharacter: call updateCURRENTNUMBERSIZE
															    ret
													
                                                                                         updateCURRENTNUMBERSIZE:  mov eax,[CURRENT_NUMBER_SIZE]
														   add eax,ebx
                        							 			           mov [CURRENT_NUMBER_SIZE],eax
													           ret
 													 
                                                        addNUMBER:  mov ebx,[CURRENT_NUMBER_SIZE]
                                                                    mov ecx,ebx
                                                                    shr ecx,1
               						            shl ecx,1
 								    cmp ecx,ebx
								    je even
							            jne odd 

        							    odd:       mov dword [ODD_CASE],1  
 									       mov ecx,[INPUT_PTR]
                                                                               mov edi,[ecx]
									       and edi,255	
									       sub edi,48				
									       call buildNODE
									       mov ecx,[INPUT_PTR]	
									       add ecx,1
									       jmp evenAFTERodd

                                                                   	   
						          even:                mov ecx,[INPUT_PTR]
                                                          evenAFTERodd:        mov dword [INPUT_PART],0 ;declares which part of INPUT we gonna check   
                                                                               iterateNUMBER2: mov dword [CURRENT_BYTE],ecx
											       mov ebx,0

                                                                                               bytes_loop2:     mov dword ecx,[CURRENT_BYTE]
                                                                                                                mov dword edi,[ecx] 	
										    		                mov edx,ebx
														cmp ebx,0
														je no_shifting2

												     		shift2:                shr edi,16
														          	       sub edx,1
 												   		                       cmp edx,0
														                       jnz shift2										    
														
													        no_shifting2:       and edi,65535
																    cmp edi,0 ;checks if it's the last char - gets() puts null terminated string at the end
                                                                                                       			            je foundLastCharacter2
															            add ebx,1
	 															    mov esi,edi
                                                                                                                                    shr esi,8
																    and edi,255
															            sub edi,48
																    cmp esi,0
																    jne substract
  																    je cont
														                    		substract: sub esi,48
                                                                                                                              cont: shl edi,4
                                                                                                                                    add edi,esi
				                  									            call buildNODE
                                                                                                       		            chk:        cmp ebx,1
																    je bytes_loop2
            												                            mov ebx,0
																    mov dword edi, [INPUT_PART] ;we pass to edi the current part (number)
																    add dword edi,[INPUT_PTR] ;we move forward with the INPUT_PTR
																    mov dword [edi],0  ;we delete 
         														            add dword [INPUT_PART],4
																    mov dword ecx,[INPUT_PTR] 
																    add dword [CURRENT_BYTE],4
															    	    jmp bytes_loop2
                                                                                                               buildNODE:           push 5
															            call malloc
															            add esp, 4
						                                                                               	    mov edx,[ADDRESS_NODE]
 															            mov [eax],edi  ; the data
															            mov [eax+1], edx ; will set the first 4 bytes of the node to be the address_node      
																    mov [FORMER_ADDRESS],edx
																    mov [ADDRESS_NODE],eax
 														                    ret

					  								       foundLastCharacter2: mov edi, [INPUT_PART] ;delete the data from INPUT so it won't hurt the next number we insert!!!
																    add edi,[INPUT_PTR]
																    mov dword [edi],0
																    mov edi, [INPUT_PART]
																    add edi,INPUT
																    mov dword [edi],0
																    mov ebx,[ADDRESS_NODE]
																    mov edi,[TOP_STACK]
																    add edi,4
																    mov [TOP_STACK],edi  
																    mov edi, [CURRENT_SIZE]
																    shl edi, 2
																    add edi, STACK_AS_ARRAY
                                                                                                                                    mov [edi],ebx
                                             										            mov ebx,[CURRENT_SIZE]
 															            add ebx,1
 															            mov [CURRENT_SIZE],ebx 
																    mov dword [ADDRESS_NODE],0
																    mov dword [ODD_CASE],0  
																    cmp dword [DEBUG_MODE],1
																    jne not_debug_mode2
															            call printDEBUGMODE
																    call CorrectNUMOFOPERATIONS
																    mov dword [DUPLICATE_TYPE],1
																    jmp duplicate
															            not_debug_mode2: ret

							  

       					bitwiseAND:   cmp dword [CURRENT_SIZE],2
						      jb printANDERROR
						      mov eax, [TOP_STACK]
						      mov ebx,eax
						      sub ebx,4
						      mov ecx, [eax] ;first element to and (it's address)
						      mov edx, [ebx] ;second element to and (it's address)
						      mov dword [FIRST_NODE_FLAG],0
						      ANDLOOP:         add dword [FIRST_NODE_FLAG],1
								       mov [A], ecx
								       mov [B], edx
								       mov ecx,[A]
								       cmp ecx,0
								       je setAZeroAND
								       jne setANotZeroAND  

								       setAZeroAND:            mov edx,0
											       mov ecx, [B]
										       	       mov eax, [ecx]
										       	       and eax,255 ;B itself
											       jmp CONT_AFTER_SETAND 

								       setANotZeroAND:	       mov edx, [ecx]	
								      			       and edx,255 ;A itself 
											       mov ecx, [B]
										               cmp ecx, 0
											       je setBZeroAND
										       	       mov eax, [ecx]
										       	       and eax,255 ;B itself
											       jmp CONT_AFTER_SETAND

								       setBZeroAND:  	       mov eax,0 
   
								       CONT_AFTER_SETAND:      mov [TEMP],edx
											       mov DL, byte [TEMP] ;DL <- A
											       mov [TEMP],eax
										               and AL,DL
											       mov [C],AL
											       push 5
											       call malloc
											       add esp, 4
											       mov edx,[MALLOC_ADDRESS]
											       mov [FORMER_MALLOC_ADDRESS],edx
											       mov [MALLOC_ADDRESS],eax
											       mov edx, [C]
											       mov [eax],edx
											       mov dword [eax+1],0
											       cmp dword [FIRST_NODE_FLAG],1
											       jne notFirstNodeCaseAND
											       mov [C_FIRST_CHAIN_ANSWER],eax
											       jmp firstNodeContAND

										       notFirstNodeCaseAND:    mov esi, [FORMER_MALLOC_ADDRESS]
													       mov [esi+1],eax

 										       firstNodeContAND:       cmp dword [A],0
													       je doneAAND
													       mov edx, [A]
													       cmp dword [edx+1],0 ;are we done with A?
													       je doneAAND
													       mov ecx,[edx+1]     ;if not, get ready with the next A in the addition
													       cmp dword [B],0
													       je gohereAND
													       mov edx, [B]
													       cmp dword [edx+1],0 ;are we done with B?
													       jne prepareANDjumpAND
											        gohereAND:     mov edx,0
													       jmp ANDLOOP

													       doneAAND:        mov ecx,0 
																mov edx, [B]
																cmp edx,0
																je doneADDITION
																cmp dword [edx+1],0
																je doneAND
		 														mov ebx,[edx+1] ;the next B in the addition
																mov edx,ebx
																jmp ANDLOOP
													    prepareANDjumpAND:	mov ebx,[edx+1] ;the next B in the addition
																mov edx,ebx
													       			jmp ANDLOOP
	
								      doneAND:      call freeANDremoveTwoElements
									            mov edx, [TOP_STACK]
										    add edx,4
										    mov [TOP_STACK],edx
										    mov edx, [TOP_STACK]
										    mov ebx, [C_FIRST_CHAIN_ANSWER]
										    mov [edx],ebx
                                             					    mov ebx,[CURRENT_SIZE]
 										    add ebx,1
 									            mov [CURRENT_SIZE],ebx 
									            cmp dword [DEBUG_MODE],1
										    jne not_debug_mode1
										    call printDEBUGMODE
										    call CorrectNUMOFOPERATIONS
										    mov dword [DUPLICATE_TYPE],1
										    call IncreaseNUMOFOPERATIONS
										    jmp duplicate
										    not_debug_mode1: ret
										    call IncreaseNUMOFOPERATIONS ;if performed!!!
				 				  		    ret

								      printANDERROR:           call insufficient_num_of_args
											       ret



        				quit:   mov byte [QUIT],1
                                                cmp dword [CURRENT_SIZE],0
						je doneQUIT
  						mov dword edx, [CURRENT_SIZE]
						delete_all_left:        mov ebx, [TOP_STACK]
									mov edx,[ebx]
									mov ebx,edx
									free_loop: 	    mov ecx, [ebx+1] ;next address
						   					    cmp dword ebx,0 ; can we free you?
											    je dont_free_me
 											    pushad
								                            push dword ebx
											    call free
											    add esp,4
            										    popad
											    dont_free_me: cmp ecx,0
												          mov ebx,ecx		
													  jne free_loop

								here:	mov ebx,[TOP_STACK]
									sub ebx,4
									mov [TOP_STACK],ebx
									mov dword edx, [CURRENT_SIZE]
									sub edx,1
									mov dword [CURRENT_SIZE], edx
									cmp edx,0
									jne delete_all_left

              					doneQUIT: ret


       					popANDprint:   cmp dword [CURRENT_SIZE],0
						       je printERROR
						       mov ecx, [TOP_STACK]
						       mov edi, [ecx]
						       mov ecx,edi
						       mov edi,0   ; edi counts the number of push's we  are doing
                                                       printLOOP: mov ebx,ecx
								  mov ecx, [ebx+1] ;next address
                                                	          mov eax, [ebx] ;we get the data to print from here
                                                 	          and eax, 255
								  add edi,1
								  push dword eax ;save the data in the stack so we can retrive it later to print in the correct order...
                           					  cmp ebx,0
								  je dont_free
							          pushad
                                                                  push dword ebx
								  call free
								  add esp,4
							          popad

                                                    dont_free:    cmp ecx,0
                                                	          jne printLOOP   ;else we are done pushing! edi holds the number of pushes.
                 						  cmp edi,0       ;start pop so we get the number as we want it! 
               							  je conti
								
 							          ; if we have one element - we just print it (if it is zero - works out well)
								  pop dword eax
								  sub edi,1
								  cmp edi,0
								  push dword eax
								  je print_first_without_leading_zeros
								  pop dword eax
								  ; else - we push back eax and bring back to the state it was
								  push dword eax
								  add edi,1

								  ; now we have more then one element - we may have leading zeros?
   							          mov ebx,0
								  mov esi,0  ; counts the zeros we pulled out
								  pop dword eax
								  cmp eax,0   ;are you a zero?
								  jne popAFTERZEROS2 ; if not, done with zeros

								  ; else: pop the shit out of them!

                                                                  popZeros:       add esi,1
                                                                                  pop dword eax 
										  cmp eax,0 ;is the next one a zero?
										  je popZeros ;if yes, continue poping them out

								  ;if not, push it back. we should keep it.
								 
								  sub edi,esi   ; esi - number of zeros we pulled out, edi - number of elements we pushed into the stack
                   						  ; now edi has the effective number of elements we should work it
							          jmp popAFTERZEROS2

							          popAFTERZEROS:  pop dword eax

            							  popAFTERZEROS2: cmp edi,0
										  jne wasNOTALLzeros
										  push dword eax ;the address for ret - prevents seg fault:)
										  push dword edi
									          jmp print_first_without_leading_zeros

										  wasNOTALLzeros:				  sub edi,1
          															  push dword eax
																  cmp ebx,0  ; if it is the first node we print without leading zeros
												 				  je print_first_without_leading_zeros
													 		 	  jne print_other

									          ; prints the first node without leading zeros
										  print_first_without_leading_zeros:		  push dword LC6
														 	          call printf
																  add esp,8
																  add ebx,1
								 								  cmp edi,0
							       							 		  jne popAFTERZEROS
																  je conti
										  ; prints all but not the first node
										  print_other:  		 		  push dword LC4
											 	                  		  call printf
																  add esp,8
																  add ebx,1
						 										  cmp edi,0
					       							 				  jne popAFTERZEROS


							          conti:          push newline
										  call printf
										  add esp,4
								                  mov ebx,[CURRENT_SIZE]
										  sub ebx,1
										  mov [CURRENT_SIZE],ebx		
										  mov ebx,[TOP_STACK]
										  sub ebx,4
										  mov [TOP_STACK],ebx
										  call IncreaseNUMOFOPERATIONS ;if performed!!!	
										  ret	

						       printERROR: call insufficient_num_of_args
								   ret
				

       					duplicate:    cmp dword [CURRENT_SIZE],0
						      je printDUPLICATEERROR
						      cmp dword [DUPLICATE_TYPE],1
						      je skipSTACKSIZECHECK
					              cmp dword [CURRENT_SIZE], STACK_SIZE 
						      je printDUPLICATESOFError
			      skipSTACKSIZECHECK:     mov edx, [TOP_STACK]  ;get the element in the array
						      mov ecx, [edx]
						      ; preparing the stack for the 1 new element... (we copy only 1 element! the loop that comes next is for each node.)
						      mov edx,[TOP_STACK]
						      add edx,4
						      mov [TOP_STACK],edx
						      mov dword [FIRST_NODE_FLAG],0
						      nextNODEDUPLICATE:        add dword [FIRST_NODE_FLAG],1 ;flag who tells us if it is the first node (then we need it's address for the top_stack, otherwise do nothing with top_stack)
										mov ebx, ecx    ; next element to take care of  
						     				mov ecx, [ebx+1]  ; next address to copy from    
                                                    			        mov edi, [ebx]    ; data
                                                     				and edi, 255 
									        pushad
							      	                push 5
										call malloc
										add esp, 4
										mov [CURRENT_MALLOC_ADDRESS],eax
										popad
										mov eax, [CURRENT_MALLOC_ADDRESS]
									aft:    mov [eax],edi
										
										cmp dword [FIRST_NODE_FLAG],1
										je skip
										mov esi,[FORMER_DUPLICATE_ADDRESS]
										mov [esi+1],eax
									skip:   mov [FORMER_DUPLICATE_ADDRESS],eax
										mov dword [eax+1],0
										cmp dword [FIRST_NODE_FLAG],1
										ja notFirstNode     ;if we got here - then we need the TOP_STACK to point to the first node that we created with malloc.
										mov edx,[TOP_STACK]
										mov [edx],eax
										notFirstNode:     cmp ecx,0
								 	      			  jne nextNODEDUPLICATE

						      mov edx,[CURRENT_SIZE]
						      add edx,1
						      mov [CURRENT_SIZE],edx
						      call IncreaseNUMOFOPERATIONS ;if performed!!!
						      cmp dword [DEBUG_MODE],1
						      jne not_debug
						      cmp dword [DUPLICATE_TYPE],1  ;meaning the duplicate was for the purpose of debugging
						      jne debugAFTERduplicate ;if we came here for normal user request for duplicating, now we wanna -d the operation.
						      mov dword [DUPLICATE_TYPE],0
						      jmp popANDprint
						      debugAFTERduplicate:             call printDEBUGMODE
										       call CorrectNUMOFOPERATIONS
										       mov dword [DUPLICATE_TYPE],1
										       jmp duplicate
						      not_debug: ret	
						         

						      printDUPLICATESOFError:  call stack_overflow
									       ret
						      printDUPLICATEERROR:     call insufficient_num_of_args
								               ret

                                        insufficient_num_of_args:	push	dword Insufficient_Number_of_Arguments ; Call printf with 2 arguments: pointer to str
       							 		push	LC0		; and pointer to format string.
			 				 		call	printf
			 				                add 	esp, 8		; Clean up stack after call
                         				    		ret	

       					illegal_input:      push	Illegal_Input_Error ; Call printf with 2 arguments: pointer to str
       							    push	LC0		; and pointer to format string.
			 				    call	printf
			 				    add 	esp, 8		; Clean up stack after call
                         				    ret

					stack_overflow:     push	Stack_Overflow_Error ; Call printf with 2 arguments: pointer to str
       							    push	LC0		; and pointer to format string.
			 				    call	printf
			 				    add 	esp, 8		; Clean up stack after call
                         				    ret


                                        IncreaseNUMOFOPERATIONS: mov ebx, [NUM_OF_OPERATIONS]
                                                                 add ebx,1
                                                                 mov [NUM_OF_OPERATIONS],ebx
                                                                 ret

                                        CorrectNUMOFOPERATIONS:  mov ebx, [NUM_OF_OPERATIONS]
                                                                 sub ebx,2
                                                                 mov [NUM_OF_OPERATIONS],ebx
                                                                 ret


        printNUMOFOPERATIONS:  push dword [NUM_OF_OPERATIONS]
                               push dword LC2
        		       call printf
       			       add  esp,8
       			       ret
        
	freeANDremoveTwoElements:               mov dword esi, 2
						delete_all_left1:       mov ebx, [TOP_STACK]
									mov edx,[ebx]
									mov ebx,edx
									free_loop1: 	    mov ecx, [ebx+1] ;next address
						   					    cmp dword ebx,0 ; can we free you?
											    je dont_free_me1
 											    pushad
								                            push dword ebx
											    call free
											    add esp,4
            										    popad
											    dont_free_me1: cmp ecx,0
												          mov ebx,ecx		
													  jne free_loop1

									mov ebx,[TOP_STACK]
									sub ebx,4
									mov [TOP_STACK],ebx
									sub esi,1
									cmp esi,0
									jne delete_all_left1
									mov ebx,[CURRENT_SIZE]
 									sub ebx,2
 									mov [CURRENT_SIZE],ebx 
									ret

        printDEBUGMODE:   push  LC7
			  push dword [stderr]
        		  call fprintf
       		          add  esp,8
                          ret







