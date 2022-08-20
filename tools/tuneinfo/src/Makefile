# Build for tuneinfo tool
#
CXX=hipcc
CXXFLAGS=-g
PROTOLIBS=-L ../external/lib/ -lprotobuf
PROTOINCLUDE=-I../external/include
PROTOC=../external/bin/protoc

tuneinfo:	tuneinfo.cpp
	$(CXX) -o tuneinfo $(CXXFLAGS) tuneinfo.cpp

read_onnx:	read_onnx.cpp cpp-interface/onnx.proto3.pb.h cpp-interface/onnx.proto3.pb.o
	$(CXX) -o read_onnx $(CXXFLAGS) $(PROTOINCLUDE) -DTEST_DRIVER=1 read_onnx.cpp cpp-interface/onnx.proto3.pb.o $(PROTOLIBS)

$(PROTOC):
# expects protobuf is checked out at v3.21.5
	cd ../protobuf && ./autogen.sh && ./configure --prefix=`pwd`/../external/ --disable-shared && make && make install

%.proto3:	../onnx/onnx/$@
	cp ../onnx/onnx/$@ .

cpp-interface/%.pb.h cpp-interface/%.pb.cc:	% $(PROTOC)
	$(PROTOC) --cpp_out=cpp-interface $<

cpp-interface/%.pb.o:	cpp-interface/%.pb.cc
	$(CXX) -o $@ $(PROTOINCLUDE) -c $<

clean:
	-rm onnx.proto3 cpp-interface/onnx.proto3.* *.o *~

clobber:	clean
	-rm read_onnx

