#
CXX=g++
CXXFLAGS=-g
PROTOLIBS=-L /usr/local/lib -lprotobuf
PROTOC := $(shell command -v protoc 2>/dev/null)
PROTOCVERSION := $(shell expr `protoc --version | cut -f2 -d .` \>= 11)

read_onnx:	read_onnx.cpp cpp-interface/onnx.proto3.pb.h cpp-interface/onnx.proto3.pb.o
	$(CXX) -o read_onnx $(CXXFLAGS) -DTEST_DRIVER=1 read_onnx.cpp cpp-interface/onnx.proto3.pb.o $(PROTOLIBS)

%.proto3:	../onnx/onnx/$@
	cp ../onnx/onnx/$@ .

cpp-interface/%.pb.h cpp-interface/%.pb.cc:	%
ifndef PROTOC
	$(error "protoc is not available")
endif
ifneq "$(PROTOCVERSION)" "1"
	$(error "protoc is older than 3.11")
endif
	protoc --cpp_out=cpp-interface $<

cpp-interface/%.pb.o:	cpp-interface/%.pb.cc
	$(CXX) -o $@ -c $<

clean:
	-rm onnx.proto3 cpp-interface/onnx.proto3.* *.o *~

clobber:	clean
	-rm read_onnx

