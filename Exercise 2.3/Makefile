.PHONY: all

all: string_manipulation.out clean

string_manipulation.out: string_manipulation.o
	gcc -g -Wall string_manipulation.o -o string_manipulation.out

string_manipulation.o: strings.s
	gcc -g -Wall strings.s -c string_manipulation.c

clean:
	rm -rf string_manipulation.o strings.o
