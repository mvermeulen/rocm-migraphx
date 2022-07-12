#
CXX=g++
CXXFLAGS=-g
PROTOLIBS=-lprotobuf

read_onnx:	read_onnx.cpp cpp-interface/onnx/onnx.proto3.pb.h
	$(CXX) -o read_onnx $(CXXFLAGS) -DTEST_DRIVER=1 read_onnx.cpp $(PROTOLIBS)

cpp-interface/onnx/onnx.proto3.pb.h cpp-interface/onnx/onnx.proto3.pb.cc:	onnx.proto3
	protoc --cpp_out=cpp-interface onnx.proto3

onnx.proto3:	../onnx/onnx/onnx.proto3
	cp ../onnx/onnx/onnx.proto3 onnx.proto3


#
clean:
	-rm onnx.proto3 cpp-interface/* *~

clobber:	clean
	-rm read_onnx

