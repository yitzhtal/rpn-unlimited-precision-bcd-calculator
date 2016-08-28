# RPN-Unlimited-Precision-BCD-Calculator
A simple RPN calculator for unlimited-precision unsigned integers, represented in Binary Coded Decimal (BCD). 
note: after running "make", dont forget to run the command "chmod u+x calc.s", before you exec calc.bin.
The operations to be supported by this calculator are:
    Quit (q)
    Addition (unsigned) (+)
    Pop-and-print (p)
    Duplicate (d)
    Bitwise AND (&), on the actual bits
The calculator use a a stack, so for example, the calculation of "2 + 2" is done with the commands: 
1. "2"
2. "2"
3. "+"
4. "p"
