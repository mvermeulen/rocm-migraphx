/*
 * fileinput.cpp - read vector of floating point numbers from file
 */
#include <iostream>
#include <fstream>
#include "migx.hpp"
void read_float_file(std::string filename,std::vector<float> &image_data){
  float f;
  std::fstream input(filename);
  if (input.fail()){
    std::cerr << migx_program << ": file open failed: " << filename << std::endl;
    return;
  }
  while (!input.eof()){
    input >> f;
    image_data.push_back(f);
  }
}
