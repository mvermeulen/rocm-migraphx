#
# Makefile for tuning db tools
#
CC=gcc
HIPCC=/opt/rocm/hip/bin/hipcc
CFLAGS=-g
HIPCCFLAGS=-D__HIP_PLATFORM_AMD__ -fPIC
LDFLAGS=-lsqlite3

tuneinfo:	lookup_db
	ln lookup_db tuneinfo

lookup_db:	lookup_db.o hipinfo.o
	-rm tuneinfo
	$(HIPCC) -o lookup_db lookup_db.o hipinfo.o $(LDFLAGS)

lookup_db.o:	lookup_db.c
	$(CC) -c $(CFLAGS) -DTEST_DRIVER=1 lookup_db.c

hipinfo.o:	hipinfo.c
	$(HIPCC) -c $(CFLAGS) $(HIPCCFLAGS) hipinfo.c	

clean:
	-rm *.o *~

clobber:	clean
	-rm lookup_db tuneinfo
