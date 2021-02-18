#include <iostream>
#include <hip/hip_runtime_api.h>

void display_memory(){
  size_t free, total;
  if (hipMemGetInfo(&free,&total) == hipSuccess){
    std::cout << "   Free Memory  " << free << std::endl;
    std::cout << "   Total Memory " << total << std::endl;
    std::cout << "   Net Memory " << total - free << std::endl;
  }
}

int main(){
  display_memory();
}
