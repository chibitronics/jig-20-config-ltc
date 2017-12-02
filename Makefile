CC := $(CROSS_COMPILE)gcc

all: bin/gpiopoll bin/measure-reset bin/pi-blaster/pi-blaster

bin/measure-reset: bin/measure-reset.c
	$(CC) bin/measure-reset.c -o bin/measure-reset -Wall

bin/gpiopoll: bin/gpiopoll.c
	$(CC) bin/gpiopoll.c -o bin/gpiopoll -Wall

bin/pi-blaster/pi-blaster: bin/pi-blaster/mailbox.c bin/pi-blaster/pi-blaster.c bin/pi-blaster/mailbox.h
	make -C bin/pi-blaster

clean:
	rm -f bin/gpiopoll bin/measure-reset
	make -C bin/pi-blaster clean
