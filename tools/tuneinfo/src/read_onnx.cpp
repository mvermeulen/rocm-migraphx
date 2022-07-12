/*
 * read_onnx.cpp - read protobuf file for ONNX definition
 */
#include <iostream>
#include <fstream>
#include <string>
#include "cpp-interface/onnx.proto3.pb.h"

void read_onnx_file(char *file){
}

#if TEST_DRIVER
int main(int argc,char *argv[]){
  //  GOOGLE_PROTOBUF_VERIFY_VERSION;
  if (argc != 2){
    std::cerr << "Usage: " << argv[0] << " <ONNX file>" << std::endl;
    return 1;
  }
  read_onnx_file(argv[1]);
  return 0;
}
#endif
