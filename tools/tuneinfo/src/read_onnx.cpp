/*
 * read_onnx.cpp - read protobuf file for ONNX definition
 */
#include <iostream>
#include <fstream>
#include <string>
#include "cpp-interface/onnx.proto3.pb.h"

void print_type(onnx::TypeProto type){
  if (type.has_tensor_type()){
    onnx::TypeProto_Tensor tensor = type.tensor_type();
    switch(tensor.elem_type()){
    case onnx::TensorProto::FLOAT:
      std::cout << "float";
      break;
    case onnx::TensorProto::UINT8:
      std::cout << "uint8";
      break;
    case onnx::TensorProto::INT8:
      std::cout << "int8";
      break;
    case onnx::TensorProto::UINT16:
      std::cout << "uint16";
      break;
    case onnx::TensorProto::INT16:
      std::cout << "int16";
      break;
    case onnx::TensorProto::INT32:
      std::cout << "int32";
      break;
    case onnx::TensorProto::INT64:
      std::cout << "int64";
      break;
    case onnx::TensorProto::STRING:
      std::cout << "string";
      break;
    case onnx::TensorProto::BOOL:
      std::cout << "bool";
      break;
    case onnx::TensorProto::FLOAT16:
      std::cout << "float16";
      break;
    case onnx::TensorProto::DOUBLE:
      std::cout << "double";
      break;
    case onnx::TensorProto::UINT32:
      std::cout << "uint32";
      break;
    case onnx::TensorProto::UINT64:
      std::cout << "uint64";
      break;
    case onnx::TensorProto::COMPLEX64:
      std::cout << "complex64";
      break;
    case onnx::TensorProto::COMPLEX128:
      std::cout << "complex128";
      break;
    case onnx::TensorProto::BFLOAT16:
      std::cout << "bfloat16";
      break;
    default:
      std::cout << "?";
      break;
    }
    onnx::TensorShapeProto shape = tensor.shape();
    std::cout << "[";
    for (int i=0; i < shape.dim_size(); i++){
      onnx::TensorShapeProto::Dimension dim = shape.dim(i);
      if (i!=0) std::cout << ",";
      if (dim.dim_param() != ""){
	std::cout << "\"" << dim.dim_param() << "\"";
      } else {
	std::cout << dim.dim_value();
      }
    }
    std::cout << "]";
  }
}

void print_tensor(onnx::TensorProto tensor){
  if (tensor.name() != "")
    std::cout << tensor.name() << ": ";
  switch(tensor.data_type()){
  case onnx::TensorProto::FLOAT:
    std::cout << "float";
    break;
  case onnx::TensorProto::UINT8:
    std::cout << "uint8";
    break;
  case onnx::TensorProto::INT8:
    std::cout << "int8";
    break;
  case onnx::TensorProto::UINT16:
    std::cout << "uint16";
    break;
  case onnx::TensorProto::INT16:
    std::cout << "int16";
    break;
  case onnx::TensorProto::INT32:
    std::cout << "int32";
    break;
  case onnx::TensorProto::INT64:
    std::cout << "int64";
    break;
  case onnx::TensorProto::STRING:
    std::cout << "string";
    break;
  case onnx::TensorProto::BOOL:
    std::cout << "bool";
    break;
  case onnx::TensorProto::FLOAT16:
    std::cout << "float16";
    break;
  case onnx::TensorProto::DOUBLE:
    std::cout << "double";
    break;
  case onnx::TensorProto::UINT32:
    std::cout << "uint32";
    break;
  case onnx::TensorProto::UINT64:
    std::cout << "uint64";
    break;
  case onnx::TensorProto::COMPLEX64:
    std::cout << "complex64";
    break;
  case onnx::TensorProto::COMPLEX128:
    std::cout << "complex128";
    break;
  case onnx::TensorProto::BFLOAT16:
    std::cout << "bfloat16";
    break;
  default:
    std::cout << "?";
    break;    
  }
  std::cout << "[";
  for (int i=0; i<tensor.dims_size(); i++){
    if (i!=0) std::cout << ",";
    std::cout << tensor.dims(i);
  }
  std::cout << "]"; 
}

void print_attribute(onnx::AttributeProto attribute){
  std::cout << "\t" << attribute.name() << ": ";
  switch(attribute.type()){
  case onnx::AttributeProto::UNDEFINED:
    std::cout << "UNDEFINED";
    break;
  case onnx::AttributeProto::FLOAT:
    std::cout << attribute.f();
    break;
  case onnx::AttributeProto::INT:
    std::cout << attribute.i();
    break;
  case onnx::AttributeProto::STRING:
    std::cout << attribute.s();
    break;
  case onnx::AttributeProto::TENSOR:
    print_tensor(attribute.t());
    break;
  case onnx::AttributeProto::GRAPH:
    std::cout << "GRAPH";
    break;
  case onnx::AttributeProto::FLOATS:
    std::cout << "[";
    for (int i=0;i<attribute.floats_size();i++){
      if (i != 0) std::cout << ",";
      std::cout << attribute.floats(i);
    }
    std::cout << "]";
    break;
  case onnx::AttributeProto::INTS:
    std::cout << "[";    
    for (int i=0;i<attribute.ints_size();i++){
      if (i != 0) std::cout << ",";      
      std::cout << attribute.ints(i);
    }
    std::cout << "]";
    break;
  case onnx::AttributeProto::STRINGS:
    std::cout << "[";
    for (int i=0;i<attribute.strings_size();i++){
      if (i != 0) std::cout << ",";      
      std::cout << attribute.strings(i);
    }
    std::cout << "]";
    break;
  case onnx::AttributeProto::TENSORS:
    std::cout << "TENSORS";
    break;
  case onnx::AttributeProto::GRAPHS:
    std::cout << "GRAPHS";
    break;    
  default:
    std::cout << "ATTRIBUTE";
    break;
  }
  std::cout << std::endl;
}

void print_node(onnx::NodeProto node){
  std::cout << "{" << std::endl;
  std::cout << "\top    : " << node.op_type() << std::endl;
  std::cout << "\tinput :";
  for (auto&& inx : node.input()){
    std::cout << " " << inx;
  }
  std::cout << std::endl;
  std::cout << "\toutput:";
  for (auto&& outx : node.output()){
    std::cout << " " << outx;
  }
  std::cout << std::endl;
  for (auto&& attribute : node.attribute()){
    print_attribute(attribute);
  }
  std::cout << "}" << std::endl;
}

int read_onnx_file(char *file,int dump_onnx_info=0, int conv_ops_only=0){
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
      std::cout << "\tdomain = " << opset.domain() << " version = " << opset.version() << std::endl;
    }
    std::cout << "    Metadata: " << std::endl;
    for (auto&& metadata : model.metadata_props()){
      std::cout << "\t" << metadata.key() << " = " << metadata.value() << std::endl;
    }
    if (model.has_graph()){
      std::cout << "    Graph: " << std::endl;
      onnx::GraphProto graph = model.graph();
      std::cout << "\tname =       " << graph.name() << std::endl;
      std::cout << "\tdoc string = " << graph.doc_string() << std::endl;
      std::cout << "\t# inputs =   " << graph.input_size() << std::endl;
      for (auto&& input : graph.input()){
	std::cout << "\tinput = " << input.name();
	if (input.has_type()){
	  std::cout << "->";
	  print_type(input.type());
	}
	std::cout << std::endl;
      }
      std::cout << "\t# outputs =  " << graph.input_size() << std::endl;
      for (auto&& output : graph.output()){
	std::cout << "\toutput = " << output.name();	
	if (output.has_type()){
	  std::cout << "->";
	  print_type(output.type());
	}
	std::cout << std::endl;
      }
      if (graph.initializer_size() > 0){
	std::cout << "\t# initializers = " << graph.initializer_size() << std::endl;
	for (auto&& initializer : graph.initializer()){
	  std::cout << "\t";
	  print_tensor(initializer);
	  std::cout << std::endl;
	}
      }
      if (graph.value_info_size() > 0){
	std::cout << "    Value Info: " << std::endl;
	for (auto&& value : graph.value_info()){
	  std::cout << "\t" << value.name();
	  if (value.has_type()){
	    std::cout << " ";
	    print_type(value.type());
	  }
	}
      }
      std::cout << "    Nodes: " << std::endl;
      for (auto&& node : graph.node()){
	if ((conv_ops_only) && node.op_type().compare("Conv")) continue;
	print_node(node);
      }
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
  result = read_onnx_file(argv[1],1,0);
  return result;
}
#endif
