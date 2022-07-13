/*
 * read_onnx.cpp - read protobuf file for ONNX definition
 */
#include <iostream>
#include <fstream>
#include <string>
#include "cpp-interface/onnx.proto3.pb.h"

int read_onnx_file(char *file,int dump_onnx_info=0){
  onnx::ModelProto model;
  std::fstream input(file,std::ios::in | std::ios::binary);
  if (!model.ParseFromIstream(&input)){
    std::cerr << "Failed to parse ONNX model" << std::endl;
    return 1;
  }
  if (dump_onnx_info > 0){
    std::cout << "ONNX file information: " << file << std::endl;
    std::cout << "    Producer Name:    " << model.producer_name() << std::endl;
    std::cout << "    Producer Version: " << model.producer_version() << std::endl;
    std::cout << "    Domain:           " << model.domain() << std::endl;
    std::cout << "    Doc String:       " << model.doc_string() << std::endl;
    std::cout << "    IR version:       " << model.ir_version() << std::endl;
    std::cout << "    Model version:    " << model.model_version() << std::endl;
    std::cout << "    Opset: " << std::endl;
    for (auto&& opset : model.opset_import()){
      std::cout << "\tdomain=" << opset.domain() << " version=" << opset.version() << std::endl;
    }
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
  result = read_onnx_file(argv[1],1);
  return result;
}
#endif
