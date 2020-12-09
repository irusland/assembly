as -o dka.o dka.s
 
ld -o dka dka.o -lSystem

./dka

gcc -O3 -o float float.c fl.s

as -o b.o b.s

ld -o b b.o
