#
all:	cpp-interface/onnx/onnx.proto3.pb.h cpp-interface/onnx/onnx.proto3.pb.cc

cpp-interface/onnx/onnx.proto3.pb.h cpp-interface/onnx/onnx.proto3.pb.cc:	onnx.proto3
	protoc --cpp_out=cpp-interface onnx.proto3

onnx.proto3:	../onnx/onnx/onnx.proto3
	cp ../onnx/onnx/onnx.proto3 onnx.proto3


#
clean:
	-rm onnx.proto3 cpp-interface/*
