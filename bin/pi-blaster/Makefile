CC := $(CROSS_COMPILE)gcc

all: pi-blaster

pi-blaster: mailbox.c mailbox.h pi-blaster.c
	$(CC) *.c -o pi-blaster -Wall

clean:
	rm -f pi-blaster
