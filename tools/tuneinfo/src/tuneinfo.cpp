/*
 * tuneinfo.cpp - look up tuning information from an ONNX file
 */
#include <iostream>
#include <string>
#include <stdlib.h>
#include <unistd.h>
#include <getopt.h>
#include <hip/hip_runtime.h>
#include <sys/types.h>
#include <dirent.h>


std::string system_db_location = "/opt/rocm/share/miopen/db";
std::string user_db_location = "";
std::string system_db;
std::string user_db;
std::string onnx_filename;
int dump_onnx = 0;

std::string tuneinfo_program;
std::string usage_message =
  tuneinfo_program + " <options list> <ONNX file>\n" +
  "    where <options list> includes options for\n" +
  "        --systemdb <file>\n" +
  "        --userdb <file>\n" +
  "        --dumponnx\n" +
  "        --help\n"
  ;

int parse_options(int argc,char *argv[]){
  int opt;
  static struct option long_options[] =
    {
     { "help",     no_argument,       0, 1 },
     { "systemdb", required_argument, 0, 2 },
     { "userdb",   required_argument, 0, 3 },
     { "dumponnx", no_argument,       0, 4 },
     { 0,         0,                0, 0 }
    };
  
  while ((opt = getopt_long(argc,argv,"",long_options,NULL)) != -1){
    switch(opt){
    case 1:
      return 1;
    case 2:
      system_db = optarg;
      break;
    case 3:
      user_db = optarg;
      break;
    case 4:
      if (dump_onnx < 2)
	dump_onnx++;
      break;
    default:
      return 1;
    }
  }
  if (optind < argc){
    onnx_filename = argv[optind];
  } else {
    std::cerr << tuneinfo_program << ": missing ONNX file" << std::endl;
    return 1;
  }
  return 0;
}

int lookup_db_files(){
  std::string home = getenv("HOME");
  user_db_location = home + "/.config/miopen";
  
  int deviceCnt;
  if (hipGetDeviceCount(&deviceCnt) != hipSuccess){
    std::cerr << tuneinfo_program << ": hipGetDeviceCount failed" << std::endl;
    return 1;
  }
  for (int i=0;i<deviceCnt;i++){
    hipDeviceProp_t props = { 0 };
    hipSetDevice(i);
    if ((hipGetDeviceProperties(&props,i)) != hipSuccess){
      std::cerr << tuneinfo_program << ": hipGetDeviceProperties failed" << std::endl;
      return 1;
    }
    std::string arch = props.gcnArchName;
    char arch_prefix[arch.length()+1];
    strcpy(arch_prefix,arch.c_str());
    strtok(arch_prefix,":\n");
    std::string prefix = std::string(arch_prefix) + "_" + std::to_string(props.multiProcessorCount);

    // look for system database
    DIR *dir;
    struct dirent *ent;
    if ((dir = opendir(system_db_location.c_str())) != NULL){
      while ((ent = readdir(dir)) != NULL){
	std::string filename = std::string(ent->d_name);
	if ((filename.length() >= 3) &&
	    (filename.compare(0,prefix.length(),prefix) == 0) &&
	    (filename.compare(filename.length()-3,3,".db") == 0)){
	  if (system_db == "")
	    system_db = system_db_location + "/" + filename;
	  break;
	}	
      }
      closedir(dir);
    }

    // look for user database
    if ((dir = opendir(user_db_location.c_str())) != NULL){
      while ((ent = readdir(dir)) != NULL){
	std::string filename = std::string(ent->d_name);
	if ((filename.length() >= 4) &&
	    (filename.compare(0,prefix.length(),prefix) == 0) &&
	    (filename.compare(filename.length()-4,4,".udb") == 0)){
	  if (user_db == "")
	    user_db = user_db_location + "/" + filename;
	  break;
	}
      }
      closedir(dir);
    }
  }
  
  return 0;
}

int read_onnx_file(const char *file,int dump_onnx_info=0, int conv_info=0);

int main(int argc,char *argv[]){
  tuneinfo_program = argv[0];
  if (parse_options(argc,argv)){
    std::cerr << tuneinfo_program << ": usage: " << usage_message;
    return 1;
  }
  if (user_db == "" || system_db == ""){
    if (lookup_db_files() == 1) return 1;
    if (system_db != ""){
      std::cout << "System database = " << system_db << std::endl;
    }
    if (user_db != ""){
      std::cout << "User database   = " << user_db << std::endl;      
    }
  }
  int result = read_onnx_file(onnx_filename.c_str(),dump_onnx,1);
  return 0;
}
