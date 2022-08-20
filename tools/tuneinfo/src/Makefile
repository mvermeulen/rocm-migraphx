# Build for tuneinfo tool
#
CXX=hipcc
CXXFLAGS=-g
PROTOLIBS=-L ../external/lib/ -lprotobuf
PROTOINCLUDE=-I../external/include
PROTOC=../external/bin/protoc

#tuneinfo:	tuneinfo.cpp cpp-interface/onnx.proto3.pb.h cpp-interface/onnx.proto3.pb.o
#	$(CXX) -o tuneinfo $(CXXFLAGS) $(PROTOINCLUDE) tuneinfo.cpp read_onnx.cpp cpp-interface/onnx.proto3.pb.o $(PROTOLIBS)

tuneinfo:	tuneinfo.o read_onnx_file.o cpp-interface/onnx.proto3.pb.o
	$(CXX) -o tuneinfo tuneinfo.o read_onnx_file.o cpp-interface/onnx.proto3.pb.o $(PROTOLIBS)

tuneinfo.o:	tuneinfo.cpp
	$(CXX) -c tuneinfo.cpp $(CXXFLAGS) tuneinfo.cpp

read_onnx_file.o:	read_onnx.cpp cpp-interface/onnx.proto3.pb.h
	$(CXX) -o read_onnx_file.o -c $(CXXFLAGS) $(PROTOINCLUDE) -DTEST_DRIVER=0 read_onnx.cpp

read_onnx:	read_onnx.cpp cpp-interface/onnx.proto3.pb.h cpp-interface/onnx.proto3.pb.o
	g++ -o read_onnx $(CXXFLAGS) $(PROTOINCLUDE) -DTEST_DRIVER=1 read_onnx.cpp cpp-interface/onnx.proto3.pb.o $(PROTOLIBS)

$(PROTOC):
# expects protobuf is checked out at v3.21.5
	cd ../protobuf && ./autogen.sh && ./configure --prefix=`pwd`/../external/ --disable-shared && make && make install

%.proto3:	../onnx/onnx/$@
	cp ../onnx/onnx/$@ .

cpp-interface/%.pb.cc:	% $(PROTOC)
	$(PROTOC) --cpp_out=cpp-interface $<

cpp-interface/%.pb.h:	% $(PROTOC)
	$(PROTOC) --cpp_out=cpp-interface $<

cpp-interface/%.pb.o:	cpp-interface/%.pb.cc
	g++ -o $@ $(PROTOINCLUDE) -c $<

clean:
	-rm onnx.proto3 cpp-interface/onnx.proto3.* *.o *~

clobber:	clean
	-rm read_onnx

