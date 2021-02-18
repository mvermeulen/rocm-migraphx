# Makefile to display available memory
#
CXX=/opt/rocm/bin/hipcc

display_memory:	display_memory.cxx
	$(CXX) -o display_memory display_memory.cxx

clean:
	-rm *.o *~

clobber:	clean
	-rm display_memory
