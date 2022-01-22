#
# Makefile for tuning db tools
#
CC=gcc
CFLAGS=-g
LDFLAGS=-lsqlite3

lookup_db:	lookup_db.o
	$(CC) -o lookup_db $(CFLAGS) -DTEST_DRIVER=1 lookup_db.c $(LDFLAGS)

clean:
	-rm *.o *~

clobber:	clean
	-rm lookup_db
