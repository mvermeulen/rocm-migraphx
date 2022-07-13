#
CXX=g++
CXXFLAGS=-g
PROTOLIBS=-lprotobuf
PROTOC := $(shell command -v protoc 2>/dev/null)
PROTOCVERSION := $(shell expr `protoc --version | cut -f2 -d .` \>= 11)

read_onnx:	read_onnx.cpp cpp-interface/onnx/onnx.proto3.pb.h
	$(CXX) -o read_onnx $(CXXFLAGS) -DTEST_DRIVER=1 read_onnx.cpp $(PROTOLIBS)

cpp-interface/onnx/onnx.proto3.pb.h cpp-interface/onnx/onnx.proto3.pb.cc:	onnx.proto3
ifndef PROTOC
	$(error "protoc is not available")
endif
ifneq "$(PROTOCVERSION)" "1"
	$(error "protoc is older than 3.11")
endif
	protoc --cpp_out=cpp-interface onnx.proto3

onnx.proto3:	../onnx/onnx/onnx.proto3
	cp ../onnx/onnx/onnx.proto3 onnx.proto3


#
clean:
	-rm onnx.proto3 cpp-interface/* *~

clobber:	clean
	-rm read_onnx

