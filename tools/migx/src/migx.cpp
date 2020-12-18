/*
 * migx - AMDMIGraphX driver program
 *
 * This driver program provides simple command line options for exercising
 * library calls associated with AMDMIGraphX graph library functions.
 * Included are options for the following stages of processing:
 *
 * 1. Loading saved models
 *
 * 2. Load input data used by the model
 *
 * 3. Quantize the model
 *
 * 4. Compile the program
 *
 * 5. Run program in various configurations
 *
 * More details about each of these options found with usage statement below.
 */
#include <iostream>
#include <fstream>
#include <iomanip>
#include <getopt.h>
#include <unistd.h>
#include <stdlib.h>
#include <fcntl.h>
#include <sys/time.h>
#include <migraphx/onnx.hpp>
#include <migraphx/tf.hpp>
#include <migraphx/gpu/target.hpp>
#include <migraphx/gpu/hip.hpp>
#include <migraphx/ref/target.hpp>
#include <migraphx/generate.hpp>
#include <migraphx/context.hpp>
#include <migraphx/quantization.hpp>
#include <migraphx/verify_args.hpp>
#include "migx.hpp"
#define MIGRAPHX_NO_MULTIPLE 0
using namespace migraphx;
std::string migx_program; // argv[0] of this process
std::string usage_message =
  migx_program + " <options list>\n" + 
  "where <options list> includes options for\n" +
  "    general use\n" +
  "        --help\n" +
  "        --verbose\n" +
  "        --gpu                run GPU mode (default)\n" +  
  "        --cpu                run CPU mode rather than GPU\n" +
  "        --trace_compile      turn on MIGRAPHX_TRACE_COMPILE\n" +
  "        --trace_eval         turn on MIGRAPHX_TRACE_EVAL\n" +
  "    loading saved models (either --onnx or --tfpb are required)\n" + 
  "        --onnx=<filename>\n" +
  "        --tfpb=<filename>\n" +
  "        --nhwc               set the data layout (--tfpb only)\n" +
  "        --nchw               set the data layout (default)\n" +
  "    quantization\n" +
  "        --fp16               quantize operations to float16\n" +
  "        --int8               quantize operations to int8\n" +
  "    input data\n" +
  "        --imagefile=<filename>\n"
  "        --gluefile=<filename> pointer to the glue tab-separated token file, e.g. MRPC.tst\n" +
  "        --random_input       create random input for argument\n"
  "        --zero_input         create zero input for argument\n"
  "        --debugfile=<filename> ASCII file of floating numbers\n" +
  "    running\n" +
  "        --perf_report        run migraphx perf report including times per instruction\n" +
  "        --benchmark          run model repeatedly and time results\n" +
  "        --imageinfo          run model once and report top5 buckets for an image\n" +
  "        --imagenet=<dir>     run model on an imagenet directory\n" +
  "        --glue=<test>        run model using glue test config (CoLA, MNLI, MRPC, QNLI, QQP, RTE, SNLI, SST-2, STS-B, WNLI\n" +
  "        --mnist=<dir>        run model on mnist directory\n"
  "        --print_model        show MIGraphX instructions for model\n" +
  "        --eval               run model and dump output to stdout\n" +
  "        --trim=<n>           trim program to remove last <n> instructions\n" +
  "        --validate           run model in CPU and GPU and see if values are within tolerance\n" +
  "        --tolerance=<fp>     tolerance to use for validation\n" +
  "        --iterations=<n>     set iterations for perf_report and benchmark (default 1000)\n" +
  "        --copyarg            copy arguments in and results back (--benchmark only)\n" +
  "        --argname=<name>     set name of model input argument (default 0)\n";

bool is_verbose = false;
bool is_gpu = true;
enum model_type { model_unknown, model_onnx, model_tfpb } model_type = model_unknown;
std::string model_filename;
bool is_nhwc = true;
bool set_nhwc = false;
enum quantization_type { quantization_none, quantization_fp16, quantization_int8 } quantization_type = quantization_none;
enum run_type { run_none, run_benchmark, run_perfreport, run_imageinfo, run_imagenet, run_glue, run_mnist, run_printmodel, run_eval, run_eval_print, run_validate } run_type = run_none;
enum glue_type glue_type = glue_none;
std::string glue_file;
std::string glue_arg1;
std::string glue_arg2;
std::string glue_arg3;
int glue_batch_size = 1;
int iterations = 1000;
bool copyarg = false;
std::string argname = "0";
enum fileinput { fileinput_none, fileinput_image, fileinput_debug } fileinput_type = fileinput_none;
std::string image_filename;
std::string debug_filename;
std::string imagenet_dir;
std::string mnist_dir;
int mnist_images;
int trim_instructions = 0;
bool trace_eval = false;
std::string trace_eval_var = "MIGRAPHX_TRACE_EVAL=1";
bool trace_compile = false;
std::string trace_compile_var = "MIGRAPHX_TRACE_COMPILE=1";
bool has_random_input = false;
bool has_zero_input = false;
double tolerance = 80;

/* parse_options
 *
 * Parse user options, returning 0 on success
 */
int parse_options(int argc,char *const argv[]){
  int opt;
  static struct option long_options[] = {
    { "help",    no_argument,       0, 1 },
    { "verbose", no_argument,       0, 2 },
    { "gpu",     no_argument,       0, 3 },
    { "cpu",     no_argument,       0, 4 },
    { "trace_eval", no_argument,    0, 5 },
    { "trace_compile", no_argument, 0, 6 },
    { "onnx",    required_argument, 0, 8 },
    { "tfpb",    required_argument, 0, 9 },
    { "nhwc",    no_argument,       0, 10 },
    { "nchw",    no_argument,       0, 11 },
    { "fp16",    no_argument,       0, 12 },
    { "int8",    no_argument,       0, 13 },
    { "imagefile", required_argument, 0, 14 },
    { "gluefile", required_argument, 0, 15 },
    { "random_input", no_argument,  0, 16 },
    { "zero_input", no_argument,    0, 17 },
    { "debugfile", required_argument, 0, 18 },
    { "benchmark", no_argument,     0, 19 },
    { "perf_report", no_argument,   0, 20 },
    { "imageinfo", no_argument,     0, 21 },
    { "imagenet", required_argument, 0, 22 },
    { "glue", required_argument, 0, 23 },
    { "mnist", required_argument, 0, 24 },
    { "print_model", no_argument,   0, 25 },
    { "eval", no_argument, 0, 26 },
    { "validate", no_argument, 0, 27 },
    { "tolerance", required_argument, 0, 28 },
    { "trim", required_argument, 0, 29 },
    { "iterations", required_argument, 0, 30 },
    { "copyarg", no_argument,       0, 31 },
    { "argname", required_argument, 0, 32 },
    { 0,         0,                 0, 0  },
  };
  while ((opt = getopt_long(argc,argv,"",long_options,NULL)) != -1){
    switch (opt){
    case 1:
      return 1;
    case 2:
      is_verbose = true;
      break;
    case 3:
      is_gpu = true;
      break;
    case 4:
      is_gpu = false;
      break;
    case 5:
      trace_eval = true;
      break;
    case 6:
      trace_compile = true;
      break;
    case 8:
      model_type = model_onnx;
      model_filename = optarg;
      break;
    case 9:
      model_type = model_tfpb;
      model_filename = optarg;
      break;
    case 10:
      is_nhwc = true;
      set_nhwc = true;
      break;
    case 11:
      is_nhwc = false;
      break;
    case 12:
      quantization_type = quantization_fp16;
      break;
    case 13:
      quantization_type = quantization_int8;
      break;
    case 14:
      fileinput_type = fileinput_image;
      image_filename = optarg;
      break;
    case 15:
      glue_file = optarg;
      break;
    case 16:
      has_random_input = true;
      break;
    case 17:
      has_zero_input = true;
      break;
    case 18:
      fileinput_type = fileinput_debug;      
      debug_filename = optarg;
      break;
    case 19:
      run_type = run_benchmark;
      break;
    case 20:
      run_type = run_perfreport;
      break;
    case 21:
      run_type = run_imageinfo;
      break;
    case 22:
      imagenet_dir = optarg;
      run_type = run_imagenet;
      break;
    case 23:
      run_type = run_glue;
      if (optarg == std::string("CoLA"))
	glue_type = glue_cola;
      else if (optarg == std::string("MNLI"))
	glue_type = glue_mnli;
      else if (optarg == std::string("MRPC"))
	glue_type = glue_mrpc;
      else if (optarg == std::string("QNLI"))
	glue_type = glue_qnli;
      else if (optarg == std::string("QQP"))
	glue_type = glue_qqp;
      else if (optarg == std::string("RTE"))
	glue_type = glue_rte;
      else if (optarg == std::string("SNLI"))
	glue_type = glue_snli;
      else if (optarg == std::string("SST-2"))
	glue_type = glue_sst;
      else if (optarg == std::string("STS-B"))
	glue_type = glue_sts;
      else if (optarg == std::string("WNLI"))
	glue_type = glue_wnli;
      else {
	std::cerr << migx_program << ": invalid argument to --glue, expecting one of: CoLA, MNLI, MRPC, QNLI, QQP, RTE, SNLI, SST-2, STS-B, WNLI" << std::endl;
	return 1;
      }
      break;
    case 24:
      mnist_dir = optarg;
      run_type = run_mnist;
      break;
    case 25:
      if (run_type == run_eval)
	run_type = run_eval_print;
      else
	run_type = run_printmodel;
      break;
    case 26:
      if (run_type == run_printmodel)
	run_type = run_eval_print;
      else
	run_type = run_eval;
      break;
    case 27:
      run_type = run_validate;
      break;
    case 28:
      if (std::stoi(optarg) < 0){
	std::cerr << migx_program << ": tolerance < 0, ignored" << std::endl;
      } else {
	tolerance = std::stod(optarg);
      }
      break;
    case 29:
      if (std::stoi(optarg) < 0){
	std::cerr << migx_program << ": trim < 0, ignored" << std::endl;	
      } else {
	trim_instructions = std::stoi(optarg);
      }
      break;
    case 30:
      if (std::stoi(optarg) < 0){
	std::cerr << migx_program << ": iterations < 0, ignored" << std::endl;
      } else {
	iterations = std::stoi(optarg);
      }
      break;
    case 31:
      copyarg = true;
      break;
    case 32:
      argname = optarg;
      break;
    default:
      return 1;
    }
  }
  if (model_type == model_unknown){
    std::cerr << migx_program << ": either --onnx or --tfpb must be given" << std::endl;
    return 1;
  }
  if (model_type == model_onnx && set_nhwc && is_nhwc){
    std::cerr << migx_program << ": --onnx is not compatible with --nhwc" << std::endl;
    return 1;
  }  
  if ((run_type == run_imageinfo) && image_filename.empty()){
    std::cerr << migx_program << ": --imageinfo requires --imagefile option" << std::endl;
    return 1;
  }
  if ((glue_type != glue_none) && (glue_file.empty())){
    std::cerr << migx_program << ": --glue= requires --gluefile option" << std::endl;
    return 1;
  }
  if (has_random_input && has_zero_input){
    std::cerr << migx_program << ": --zero_input and --random_input are mutually exclusive" << std::endl;
  }
  return 0;
}

/* get_time
 *
 * return current time in milliseconds
 */
double get_time(){
  struct timeval tv;
  gettimeofday(&tv,NULL);
  return static_cast<double>(tv.tv_usec / 1000) + tv.tv_sec * 1000;
}

template <class T>
auto get_hash(const T& x){
  return std::hash<T>{}(x);
}

int main(int argc,char *const argv[],char *const envp[]){
  migx_program = argv[0];
  if (parse_options(argc,argv)){
    std::cerr << migx_program << ": usage: " << usage_message;
    return 1;
  }

  // load the model file
  if (is_verbose)
    std::cout << "loading model file" << std::endl;
  
  program prog;
  if (model_type == model_onnx){
    try {
      prog = parse_onnx(model_filename);
    } catch(...){
      std::cerr << migx_program << ": unable to load ONNX file " << model_filename << std::endl;
      return 1;
    }
  } else if (model_type == model_tfpb){
    try {
#if MIGRAPHX_NO_MULTIPLE
      prog = parse_tf(model_filename,is_nhwc);
#else
      struct tf_options tf_opt;

      tf_opt.is_nhwc = is_nhwc;
      tf_opt.batch_size = 1;
      prog = parse_tf(model_filename,tf_opt);
#endif
    } catch( std::exception &exc){
      std::cerr << exc.what();
    } catch(...){
      std::cerr << migx_program << ": unable to load TF protobuf file " << model_filename << std::endl;
      return 1;
    }
  }

  // quantize the program
  if (quantization_type == quantization_fp16){
    quantize_fp16(prog)
      ;
  } else if (quantization_type == quantization_int8){
#if 0
    std::vector<migraphx::parameter_map> calibration;
    migraphx::parameter_map *calibration_map = new migraphx::parameter_map;
    // use 100 pieces of randomly generated argument...
    for (int i = 0;i<100;i++){
      for (auto&& x : prog.get_parameter_shapes()){
	(*calibration_map)[x.first] = migraphx::generate_argument(x.second);
	calibration.push_back(*calibration_map);
      }
    }
#else
    // use empty calibration data
    std::vector<migraphx::parameter_map> calibration;
#endif

    if (is_gpu)
      quantize_int8(prog,migraphx::gpu::target{},calibration);      
    else
      quantize_int8(prog,migraphx::ref::target{},calibration);
  } else
    if (quantization_type != quantization_none){
    std::cerr << "quantization not yet implemented" << std::endl;
  }

  // copy the original program for use in validation
  program validate_program = prog;

  // compile the program
  if (trace_compile){
    putenv((char *) trace_compile_var.c_str());
  }
  if (is_verbose)
    std::cout << "compiling model" << std::endl;
  if (is_gpu)
    prog.compile(migraphx::gpu::target{});
  else
    prog.compile(migraphx::ref::target{});

  // remove the last "trim=n" instructions, debugging tool with --eval to print out intermediate results
  if (run_type != run_validate && trim_instructions > 0 && trim_instructions < prog.size()){
    auto prog2 = prog;
    // create shorter program removing "trim" instructions in size
    auto last = std::prev(prog2.end(),trim_instructions);
    prog2.remove_instructions(last,prog2.end());
    prog = prog2;
  }

  // set up the parameter map
  parameter_map pmap;  
  bool argname_found = false;
  shape argshape;
  int batch_size=1, channels=1, height=1, width=1;  
  for (auto&& x: prog.get_parameter_shapes()){
    if (is_verbose){
      std::cout << "parameter: " << x.first;
      std::cout << " shape = [";
      for (int i=0;i<x.second.lens().size();i++){
	if (i!=0) std::cout << ",";
	std::cout << x.second.lens()[i];
      }
      std::cout << "]" << std::endl;
      argument& arg = pmap[x.first];
      if (arg.empty()) std::cout << "empty" << std::endl;
      else std::cout << "not empty" << std::endl;
    }
    if (x.first == argname){
      argshape = x.second;
      argname_found = true;
    }
    if (is_gpu && has_random_input){
      pmap[x.first] = migraphx::gpu::to_gpu(migraphx::generate_argument(x.second));
      auto arg = migraphx::generate_argument(x.second);
    }
    else if (is_gpu && has_zero_input)
      pmap[x.first] = migraphx::gpu::to_gpu(migraphx::fill_argument(x.second));
    else if (is_gpu)
      pmap[x.first] = migraphx::gpu::allocate_gpu(x.second);
    else
      pmap[x.first] = migraphx::generate_argument(x.second,get_hash(x.first));
  }

  // pattern match argument names and types
  enum image_type img_type;
  if (argname_found == false && glue_type == glue_none){
    std::cerr << "input argument: " << argname << " not found, use --argname to pick from following candidates" << std::endl;
    for (auto&& x: prog.get_parameter_shapes()){
      std::cout << "\t" << x.first << std::endl;
    }
    if (run_type != run_printmodel) return 1;
  } else {
    if (is_verbose){
      std::cout << "model input [";
      for (int i=0;i<argshape.lens().size();i++){
	if (i!=0) std::cout << ",";
	std::cout << argshape.lens()[i];
      }
      std::cout << "] " << argshape.elements() << " elements" << std::endl;
    }
    if (argshape.lens().size() == 4){
      batch_size = argshape.lens()[0];
      channels = argshape.lens()[1];
      height = argshape.lens()[2];
      width = argshape.lens()[3];
    } else if (argshape.lens().size() == 3){
      channels = argshape.lens()[0];
      height = argshape.lens()[1];
      width = argshape.lens()[2];
    }
    if (channels == 3 && height == 224 && width == 224) img_type = image_imagenet224;
    else if (channels == 3 && height == 299 && width == 299) img_type = image_imagenet299;
    else if (channels == 1 && height == 28 && width == 28) img_type = image_mnist;
    else img_type = image_unknown;
  }

  // read image data if passed
  //  std::vector<float> image_data(3*height*width);
  std::vector<float> image_data;
  std::vector<float> image_alloc(3*height*width);      
  if (fileinput_type == fileinput_image){
    if (!image_filename.empty()){
      if (is_verbose)
	std::cout << "reading image: " << image_filename << " " << std::endl;
      read_image(image_filename,img_type,image_alloc,false,model_type==model_onnx);
      image_data = image_alloc;
    }
  } else if (fileinput_type == fileinput_debug){
    if (!debug_filename.empty()){
      if (is_verbose)
	std::cout << "reading debug: " << image_filename << " " << std::endl;
      read_float_file(debug_filename,image_data);
    }
    if (image_data.size() < argshape.elements()){
      std::cerr << migx_program << ": model requires " << argshape.elements() << " inputs, only " << image_data.size() << " provided" << std::endl;
      return 1;
    }
  }

  // find the glue batch size and set the parameter names
  if (glue_type != glue_none){
    if (model_type == model_onnx){
      glue_arg1 = "input.1";
      glue_arg2 = "input.3";
      glue_arg3 = "2";
    } else if (model_type == model_tfpb){
      glue_arg1 = "input_ids_1";
      glue_arg3 = "input_mask_1";
      glue_arg2 = "segment_ids_1";      
    }
    
    auto param_shapes = prog.get_parameter_shapes();
    if (param_shapes.count(glue_arg1) > 0){
      glue_batch_size = param_shapes[glue_arg1].lens()[0];
    }

    if (is_verbose){
      std::cout << "glue batch size = " << glue_batch_size << std::endl;      
    }
  }
  // prime glue with data if necessary...
  if (glue_type != glue_none && run_type != run_glue && !has_random_input){
    std::ifstream glue_stream(glue_file);
    if (!glue_stream.is_open()){
      std::cerr << migx_program << ": can not open gluefile: " << glue_file << std::endl;
      return 1;
    }
    std::string line;
    // TODO: parameters hard coded for MRPC for now
    std::getline(glue_stream,line); // skip first line      
    std::unordered_map<std::string, std::vector<int64_t>> input_map;
    input_map[glue_arg1];
    input_map[glue_arg2];
    input_map[glue_arg3];    
    std::unordered_map<std::string, std::vector<int64_t>> sent_tokens;
    sent_tokens["vec_feature"];
    sent_tokens["vec_id"];
    sent_tokens["seg_id"];
    std::vector<int> vec_labels;
    for (std::size_t batch_no = 0; batch_no < glue_batch_size; batch_no++){
      std::getline(glue_stream,line);
      if (line.empty()) break;
      int label = parse_line(line,128,sent_tokens);
      vec_labels.push_back(label);
      input_map[glue_arg1].insert(input_map[glue_arg1].end(),sent_tokens["vec_feature"].begin(),sent_tokens["vec_feature"].end());
      input_map[glue_arg2].insert(input_map[glue_arg2].end(),sent_tokens["vec_id"].begin(),sent_tokens["vec_id"].end());
      input_map[glue_arg3].insert(input_map[glue_arg3].end(),sent_tokens["seg_id"].begin(),sent_tokens["seg_id"].end());      
    }

    if (is_verbose){
      std::cout << "input_map[\"input.1\"] :";
      for (int i=0; i < input_map[glue_arg1].size();i++){
	std::cout << " " << input_map[glue_arg1][i];
      }
      std::cout << std::endl;

      std::cout << "input_map[\"input.3\"] :";
      for (int i=0; i < input_map[glue_arg2].size();i++){
	std::cout << " " << input_map[glue_arg2][i];
      }
      std::cout << std::endl;

      std::cout << "input_map[\"2\"] :";
      for (int i=0; i < input_map[glue_arg3].size();i++){
	std::cout << " " << input_map[glue_arg3][i];
      }
      std::cout << std::endl;
    }
    
    // copy the arguments
    for (auto &&x : prog.get_parameter_shapes()){
      migraphx::argument arg{};
      if (input_map.count(x.first) > 0){
	arg = migraphx::argument(x.second,input_map[x.first].data());
      } else {
	arg = migraphx::generate_argument(x.second,get_hash(x.first));
      }
      if (is_gpu){
	pmap[x.first] = migraphx::gpu::to_gpu(arg);
      } else {
	pmap[x.first] = arg;
      }
    }
  }

  migraphx::argument result;
#if MIGRAPHX_NO_MULTIPLE
  migraphx::argument resarg;
#else
  std::vector<migraphx::argument> resarg;
#endif
  double start_time,finish_time,elapsed_time;
  int top5[5];
  // alternatives for running the program
  if (trace_eval){
    putenv((char *) trace_eval_var.c_str());    
  }
  auto ctx = prog.get_context();
  switch(run_type){
  case run_none:
    // do nothing
    break;
  case run_benchmark:
    int i;
    if (is_verbose && iterations > 1){
      std::cout << "running           " << iterations << " iterations" << std::endl;
    }
    if (glue_batch_size != 1) batch_size = glue_batch_size;
    start_time = get_time();
    for (i = 0;i < iterations;i++){
      if (is_gpu){
	if (copyarg)
	  pmap[argname] = migraphx::gpu::to_gpu(generate_argument(prog.get_parameter_shape(argname)));
	resarg = prog.eval(pmap);
	ctx.finish();
	if (copyarg)
#if MIGRAPHX_NO_MULTIPLE
	  result = migraphx::gpu::from_gpu(resarg);	  
#else
	  result = migraphx::gpu::from_gpu(resarg[0]);
#endif	
      } else {
	resarg = prog.eval(pmap);
	ctx.finish();
      }
    }
    finish_time = get_time();
    elapsed_time = (finish_time - start_time)/1000.0;

    std::cout << "batch size        " << batch_size << std::endl;        
    std::cout << std::setprecision(6) << "Elapsed time(ms): " << elapsed_time << std::endl;
    std::cout << "Images/sec:       " << (iterations*batch_size)/elapsed_time << std::endl;
    break;
  case run_perfreport:
    if (is_verbose && iterations > 1){
      std::cout << "running           " << iterations << " iterations" << std::endl;
    }
    prog.perf_report(std::cout,iterations,pmap);
    break;
  case run_imageinfo:
    if (is_gpu) {
      pmap[argname] = migraphx::gpu::to_gpu(migraphx::argument{
	  pmap[argname].get_shape(),image_data.data()});
    } else {
      pmap[argname] = migraphx::argument{
	pmap[argname].get_shape(),image_data.data()};
    }
    if (is_gpu){
      resarg = prog.eval(pmap);
#if MIGRAPHX_NO_MULTIPLE
      result = migraphx::gpu::from_gpu(resarg);      
#else
      result = migraphx::gpu::from_gpu(resarg[0]);
#endif
    } else {
      resarg = prog.eval(pmap);
#if MIGRAPHX_NO_MULTIPLE
      result = resarg;
#else
      result = resarg[0];
#endif
    }
    if (result.get_shape().elements() == 1001){
      // skip 1st label
      image_top5(((float *) result.data())+1, top5);      
    } else {
      image_top5((float *) result.data(), top5);
    }
    std::cout << "top1 = " << top5[0] << " " << imagenet_labels[top5[0]] << std::endl;
    std::cout << "top2 = " << top5[1] << " " << imagenet_labels[top5[1]] << std::endl;
    std::cout << "top3 = " << top5[2] << " " << imagenet_labels[top5[2]] << std::endl;
    std::cout << "top4 = " << top5[3] << " " << imagenet_labels[top5[3]] << std::endl;
    std::cout << "top5 = " << top5[4] << " " << imagenet_labels[top5[4]] << std::endl;
    break;
  case run_imagenet:
    {
      int count = 0;
      int ntop1 = 0;
      int ntop5 = 0;
      std::string imagefile;
      int expected_result;
      if (chdir(imagenet_dir.c_str()) == -1){
	std::cerr << migx_program << ": can not change to imagenet dir: " << imagenet_dir << std::endl;
	return 1;
      }
      std::fstream index("val.txt");
      if (!index || (index.peek() == EOF)){
	std::cerr << migx_program << ": can not open val.txt: " << imagenet_dir << std::endl;
	return 1;
      }
      while (1){
	index >> imagefile >> expected_result;
	if (index.eof()) break;
	read_image(imagefile,img_type,image_alloc,false,model_type==model_onnx);
	count++;
	if (is_gpu){
	  pmap[argname] = migraphx::gpu::to_gpu(migraphx::argument{
	      pmap[argname].get_shape(),image_alloc.data()});
	  resarg = prog.eval(pmap);
#if MIGRAPHX_NO_MULTIPLE
	  result = migraphx::gpu::from_gpu(resarg);	  
#else
	  result = migraphx::gpu::from_gpu(resarg[0]);
#endif
	} else {
	  pmap[argname] = migraphx::argument{
	    pmap[argname].get_shape(),image_alloc.data()};
	  resarg = prog.eval(pmap);
#if MIGRAPHX_NO_MULTIPLE
	  result = resarg;
#else
	  result = resarg[0];
#endif
	}
	if (result.get_shape().elements() == 1001){
	  image_top5(((float *) result.data())+1, top5);
	} else {
	  image_top5((float *) result.data(), top5);
	}
	if (top5[0] == expected_result) ntop1++;
	if (top5[0] == expected_result ||
	    top5[1] == expected_result ||
	    top5[2] == expected_result || 
	    top5[3] == expected_result || 
	    top5[4] == expected_result) ntop5++;
	if (count % 1000 == 0)
	  std::cout << count << " top1: " << ntop1 << " top5: " << ntop5 << std::endl;
      }
      std::cout << "Overall - top1: " << (double) ntop1/count << " top5: " << (double) ntop5/count << std::endl;
    }
    break;
  case run_glue:
    {
      std::ifstream glue_stream(glue_file);
      if (!glue_stream.is_open()){
	std::cerr << migx_program << ": can not open gluefile: " << glue_file << std::endl;
	return 1;
      }
      std::string line;
      // TODO: parameters hard coded for MRPC for now
      std::getline(glue_stream,line); // skip first line      
      
      int accu_count = 0, total_count = 0;
      while (1){
	std::unordered_map<std::string, std::vector<int64_t>> input_map;
	std::unordered_map<std::string, std::vector<int32_t>> input_map32;
	input_map[glue_arg1];
	input_map[glue_arg2];
	input_map[glue_arg3];
	input_map32[glue_arg1];
	input_map32[glue_arg2];
	input_map32[glue_arg3];	
	std::unordered_map<std::string, std::vector<int64_t>> sent_tokens;
	sent_tokens["vec_feature"];
	sent_tokens["vec_id"];
	sent_tokens["seg_id"];
	std::vector<int> vec_labels;
	
	for (std::size_t batch_no = 0; batch_no < glue_batch_size; batch_no++){
	  std::getline(glue_stream,line);
	  if (line.empty()) break;
	  int label = parse_line(line,128,sent_tokens);
	  vec_labels.push_back(label);
	  input_map[glue_arg1].insert(input_map[glue_arg1].end(),sent_tokens["vec_feature"].begin(),sent_tokens["vec_feature"].end());
	  input_map[glue_arg2].insert(input_map[glue_arg2].end(),sent_tokens["vec_id"].begin(),sent_tokens["vec_id"].end());
	  input_map[glue_arg3].insert(input_map[glue_arg3].end(),sent_tokens["seg_id"].begin(),sent_tokens["seg_id"].end());
	  input_map32[glue_arg1].insert(input_map32[glue_arg1].end(),sent_tokens["vec_feature"].begin(),sent_tokens["vec_feature"].end());
	  input_map32[glue_arg2].insert(input_map32[glue_arg2].end(),sent_tokens["vec_id"].begin(),sent_tokens["vec_id"].end());
	  input_map32[glue_arg3].insert(input_map32[glue_arg3].end(),sent_tokens["seg_id"].begin(),sent_tokens["seg_id"].end());      	  
	}
	if (line.empty()) break;

	// copy the arguments
	for (auto &&x : prog.get_parameter_shapes()){
	  migraphx::argument arg{};
	  if (input_map.count(x.first) > 0){
	    if (model_type == model_onnx)
	      arg = migraphx::argument(x.second,input_map[x.first].data());
	    else if (model_type == model_tfpb)
	      arg = migraphx::argument(x.second,input_map32[x.first].data());	      
	  } else {
	    arg = migraphx::generate_argument(x.second,get_hash(x.first));
	  }
	  if (is_gpu){
	    pmap[x.first] = migraphx::gpu::to_gpu(arg);
	  } else {
	    pmap[x.first] = arg;
	  }
	}
	// evaluate result
	migraphx::argument result{};
	if (is_gpu){
	  resarg = prog.eval(pmap);
#if MIGRAPHX_NO_MULTIPLE
	  result = migraphx::gpu::from_gpu(resarg);	  
#else
	  result = migraphx::gpu::from_gpu(resarg[0]);
#endif
	} else {
	  resarg = prog.eval(pmap);
#if MIGRAPHX_NO_MULTIPLE
	  result = resarg;
#else
	  result = resarg[0];
#endif
	}
	std::vector<float> vec_output;
	result.visit([&](auto output){ vec_output.assign(output.begin(),output.end()); });

	for (std::size_t batch_no = 0; batch_no < glue_batch_size; batch_no++){
	  if (is_verbose)
	    std::cout << "[" << vec_output[2*batch_no] << "," << vec_output[2 * batch_no + 1] << "]" << std::endl;
	  int calc_label = (vec_output[2*batch_no] >= vec_output[2*batch_no + 1]) ? 0 : 1;
	  accu_count += (calc_label == vec_labels[batch_no]) ? 1 : 0;
	  total_count++;
	}
      }
      std::cout << "accuracy rate = " << 1.0 * accu_count / total_count << std::endl;
    }
    break;
  case run_mnist:
    {
      int i,j;
      
      std::vector<float> image_data(28*28);
      int label;
      float *label_result;
      if (img_type != image_mnist){
	std::cerr << migx_program << ": --mnist requires input size [1,28,28]" << std::endl;
	return 1;
      }
      if (initialize_mnist_streams(mnist_dir,mnist_images)){
	std::cerr << migx_program << ": can not read mnist files in dir: " << mnist_dir << std::endl;
	return 1;
      }
      if (is_verbose)
	std::cout << "mnist images = " << mnist_images << std::endl;
      int total_pass = 0;
      for (i=0;i<mnist_images;i++){
	read_mnist(image_data,label);
	if (is_verbose)
	  ascii_mnist(image_data,label);
	if (is_gpu){
	  pmap[argname] = migraphx::gpu::to_gpu(migraphx::argument{
	      pmap[argname].get_shape(),image_data.data()});
	  resarg = prog.eval(pmap);
#if MIGRAPHX_NO_MULTIPLE
	  result = migraphx::gpu::from_gpu(resarg);	  
#else
	  result = migraphx::gpu::from_gpu(resarg[0]);
#endif
	} else {
	  pmap[argname] = migraphx::argument{
	    pmap[argname].get_shape(),image_data.data()};
	  resarg = prog.eval(pmap);
#if MIGRAPHX_NO_MULTIPLE
	  result = resarg;
#else
	  result = resarg[0];
#endif
	}
	label_result = (float *) result.data();
	int maxidx=0;
	for (j=0;j<10;j++){
	  if (label_result[j] > label_result[maxidx])
	    maxidx = j;
	}
	if (maxidx == label) total_pass++;
	    
	if (is_verbose){
	  for (j=0;j<10;j++){
	    std::cout << ((j==maxidx)?"*":"") << label_result[j] << " ";
	  }
	  std::cout << std::endl;
	}
      }
      finish_mnist_streams();
      std::cout << "MNIST results: " << total_pass << " / " << mnist_images << " = " << (double) total_pass / mnist_images << std::endl;
    }
    break;
  case run_printmodel:
    std::cout << "Program with " << prog.size() << " instructions" << std::endl;
    std::cout << prog;
    break;
  case run_eval_print:
    std::cout << "Program with " << prog.size() << " instructions" << std::endl;
    std::cout << prog;
    // fallthru
  case run_eval:
    // load argument
    if (is_verbose){
      std::cout << "Inputs: " << std::endl;
      for (int i=0;i < image_data.size();i++)
	std::cout << "\t" << image_data[i] << std::endl;
    }
    if (image_data.size() == 0){
      std::cerr << migx_program << ": missing image data for eval" << std::endl;
      return 1;
    } else if (is_gpu){
      pmap[argname] = migraphx::gpu::to_gpu(migraphx::argument{
	  pmap[argname].get_shape(),image_data.data()});
    } else {
      pmap[argname] = migraphx::argument{
	pmap[argname].get_shape(),image_data.data()};
    }
    // evaluate
    if (is_gpu){
      resarg = prog.eval(pmap);
#if MIGRAPHX_NO_MULTIPLE
      result = migraphx::gpu::from_gpu(resarg);      
#else
      result = migraphx::gpu::from_gpu(resarg[0]);
#endif

    } else {
      resarg = prog.eval(pmap);
#if MIGRAPHX_NO_MULTIPLE
#else
      result = resarg[0];
#endif
    }
    std::cout << result << std::endl;
  case run_validate:
    migraphx::argument cpu_result;
    migraphx::argument gpu_result;
    
    if (image_data.size() == 0){
      std::cerr << migx_program << ": missing image data for validate" << std::endl;
      return 1;
    }

    if (trim_instructions > 0 && trim_instructions < validate_program.size()){
      auto prog2 = validate_program;
      auto last = std::prev(prog2.end(),trim_instructions);
      prog2.remove_instructions(last,prog2.end());
      validate_program = prog2;
    }

    for(auto&& x: validate_program.get_parameter_shapes()){
      pmap[x.first] = migraphx::gpu::allocate_gpu(x.second);
    }

    program gpu_program = validate_program;
    program cpu_program = validate_program;

    gpu_program.compile(migraphx::gpu::target{});
    pmap[argname] = migraphx::gpu::to_gpu(migraphx::argument{
	pmap[argname].get_shape(),image_data.data()});
    resarg = gpu_program.eval(pmap);
    gpu_result = migraphx::gpu::from_gpu(resarg[0]);
      
    cpu_program.compile(migraphx::ref::target{});
    pmap[argname] = migraphx::argument{
      pmap[argname].get_shape(),image_data.data()};
    resarg = cpu_program.eval(pmap);
    cpu_result = resarg[0];

    std::cout << validate_program << std::endl;
    verify_args("cpu vs. gpu",cpu_result,gpu_result,80);

    break;
  }

  return 0;
}
