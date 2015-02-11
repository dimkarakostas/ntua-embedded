# Makefile for guest

CC = gcc
CFLAGS = -Wall -g 

all: guest.out

guest.out: guest.s
	$(CC) $(CFLAGS) guest.s -o guest.out

clear:
	rm -f guest.out
