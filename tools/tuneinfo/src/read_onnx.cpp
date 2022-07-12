/*
 * read_onnx.cpp - read protobuf file for ONNX definition
 */
#include <iostream>
#include <fstream>
#include <string>
#include "cpp-interface/onnx.proto3.pb.h"

int read_onnx_file(char *file){
  onnx::ModelProto model;
  std::fstream input(file,std::ios::in | std::ios::binary);
  if (!model.ParseFromIstream(&input)){
    std::cerr << "Failed to parse ONNX model" << std::endl;
    return 1;
  }
  return 0;
}

#if TEST_DRIVER
int main(int argc,char *argv[]){
  int result;
  GOOGLE_PROTOBUF_VERIFY_VERSION;
  if (argc != 2){
    std::cerr << "Usage: " << argv[0] << " <ONNX file>" << std::endl;
    return 1;
  }
  result = read_onnx_file(argv[1]);
  return result;
}
#endif
