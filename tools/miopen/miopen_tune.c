/* Utility program for working with MIOpen tuning */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sqlite3.h>
#include <getopt.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>

const char *prog;
/*
 * usage - display command line accepted
 */
void usage(const char *prog){
  fprintf(stderr,"%s: Usage: %s <mode> <MIOpen base arg> <MIOpenDriver options>\n",prog,prog);
  fprintf(stderr,"\tmode = check|tune\n");
  fprintf(stderr,"\tMIOpen base arg = conv[fp16|int8|bfp16] | CBAInfer[fp16] | pool[fp16] | lrn[fp16] | activ[fp16] | softmax[fp16] | bnorm[fp16] | rnn[fp16] | gemm | ctc | dropout[fp16]\n");
  fprintf(stderr,"\tMIOpenDriver options:\n");
}

const char *miopen_base[] = {
  "conv","convfp16","convint8","convbfp16",
  "CBAInfer","CBAInferfp16",
  "pool","poolfp16",
  "lrn","lrnfp16",
  "activ","activfp16",
  "softmax","softmaxfp16",
  "bnorm","bnormfp16",
  "rnn","rnnfp16",
  "gemm","ctc",
  "dropout","dropoutfp16",
};

// tuning config parameters that are set
char *data_type = "FP32";
int batchsize = 100;
int bias = 0;
int conv_stride_d = 1;
int conv_stride_h = 1;
int conv_stride_w = 1;
int dilation_d = 1;
int dilation_h = 1;
int dilation_w = 1;
char *direction = "F";
int fil_d = 3;
int fil_h = 3;
int fil_w = 3;
int forw = 0;
char *gpu_arch = NULL;
int gpu_cu = 0;
int group_count = 1;
int in_channels = 3;
int in_d = 32;
int in_h = 32;
int in_w = 32;
char *layout = "NCHW";
char *mode = "conv";
int out_channels = 32;
int pad_d = 0;
int pad_h = 0;
int pad_w = 0;
char *tensor_vect = NULL;
int time_layer = 0;
int trans_output_pad_d = 0;
int trans_output_pad_h = 0;
int trans_output_pad_w = 0;

/* parse the command line options
 * Note: Command line options are expected to match what is accepted by MIOpenDriver
 *    In particular if you instrument using MIOPEN_ENABLE_LOGGING_CMD=1 and then take
 *    each of the "./bin/MIOpenDriver conv" command lines and feed to this program.
 */
int parse_miopen_options(int argc,char *const argv[]){
  int opt;
  int i;
  
  static struct option long_options[] = {
    { "batchsize", required_argument, 0, 'n' },
    { "bias", required_argument, 0, 'b' },
    { "conv_stride_d", required_argument, 0, 'u' },    
    { "conv_stride_h", required_argument, 0, 'u' },
    { "conv_stride_w", required_argument, 0, 'v' },
    { "dilation_d", required_argument, 0, '^' },
    { "dilation_h", required_argument, 0, 'l' },
    { "dilation_w", required_argument, 0, 'j' },
    { "fil_d", required_argument, 0, 'y' },
    { "fil_h", required_argument, 0, 'y' },
    { "fil_w", required_argument, 0, 'x' },
    { "forw", required_argument, 0, 'F' },
    { "group_count", required_argument, 0, 'g' },
    { "in_channels", required_argument, 0, 'c' },
    { "in_d", required_argument, 0, '!' },
    { "in_h", required_argument, 0, 'H' },
    { "in_w", required_argument, 0, 'W' },
    { "mode", required_argument, 0, 'm' },
    { "out_channels", required_argument, 0, 'k' },
    { "pad_d", required_argument, 0, '$' },
    { "pad_h", required_argument, 0, 'p' },
    { "pad_q", required_argument, 0, 'q' },
    { "tensor_vect", required_argument, 0, 'Z' },
    { "time", required_argument, 0, 't' },
    { "trans_output_pad_d", required_argument, 0, '%' },
    { "trans_output_pad_h", required_argument, 0, 'Y' },
    { "trans_output_pad_w", required_argument, 0, 'X' },
  };
  
  while ((opt = getopt_long(argc,argv,"+!:#:$:%:@:^:b:c:F:g:H:j:k:l:m:n:p:q:t:u:v:W:x:X:y:Y:",long_options,NULL)) != -1){
    switch(opt){
    case '!':
      in_d = atoi(optarg);
      break;
    case '#':
      conv_stride_d = atoi(optarg);
      break;
    case '$':
      pad_d = atoi(optarg);
      break;
    case '%':
      trans_output_pad_d = atoi(optarg);
      break;
    case '@':
      fil_d = atoi(optarg);
      break;
    case '^':
      dilation_d = atoi(optarg);
      break;
    case 'b':
      bias = atoi(optarg);
      break;
    case 'c':
      in_channels = atoi(optarg);
      break;
    case 'F':
      forw = atoi(optarg);
      direction = "F";
      break;
    case 'g':
      group_count = atoi(optarg);
      break;
    case 'H':
      in_h = atoi(optarg);
      break;
    case 'j':
      dilation_w = atoi(optarg);
      break;
    case 'k':
      out_channels = atoi(optarg);
      break;
    case 'l':
      dilation_h = atoi(optarg);
      break;
    case 'm':
      if (!strcmp(optarg,"conv")){
	mode = "conv";
      }	else if (!strcmp(optarg,"trans")){
	mode = "trans";
	fprintf(stderr,"%s: unknown case --mode = trans\n",prog);
	return 1;
      } else {
	fprintf(stderr,"%s: invalid --mode: %s\n",prog,optarg);
	return 1;
      }
      break;
    case 'n':
      batchsize = atoi(optarg);
      break;
    case 'p':
      pad_h = atoi(optarg);
      break;
    case 'q':
      pad_w = atoi(optarg);
      break;
    case 't':
      time_layer = atoi(optarg);
      break;
    case 'u':
      conv_stride_h = atoi(optarg);
      break;
    case 'v':
      conv_stride_w = atoi(optarg);
      break;
    case 'W':
      in_w = atoi(optarg);
      break;
    case 'x':
      fil_w = atoi(optarg);
      break;
    case 'X':
      trans_output_pad_w = atoi(optarg);
      break;
    case 'y':
      fil_h = atoi(optarg);
      break;
    case 'Y':
      trans_output_pad_h = atoi(optarg);
      break;
    case 'Z':
      tensor_vect = strdup(optarg);
      break;
    default:
      return 1;
    }
  }
  return 0;
}

/*
 * fetch_gpu_architecture - use /opt/rocm/bin/rocminfo to fill out gpu_arch and gpu_cu fields
 */
void fetch_gpu_architecture(){
  char buffer[1024];
  char token[128];
  FILE *gpu_fp = popen("/opt/rocm/bin/rocminfo","r");
  int gpu_found = 0;
  if (gpu_fp == NULL){
    fprintf(stderr,"%s: can not fetch info from /opt/rocm/bin/rocminfo\n",prog);
    exit(-1);
  }
  while (fgets(buffer,sizeof(buffer),gpu_fp) != NULL){
    if (!strncmp(buffer,"  Name:",7)){
      sscanf(&buffer[7],"%s",token);
      if (!strncmp(token,"gfx",3)){
	gpu_arch = strdup(token);
	gpu_found = 1;
	continue;
      }
    }
    if (!gpu_found) continue;
    if (!strncmp(buffer,"  Compute Unit:",15)){
      sscanf(&buffer[15],"%d",&gpu_cu);
      break;
    }
  }
  if (gpu_arch == NULL || gpu_cu == 0){
    fprintf(stderr,"%s: unable to set gpu architecture\n",prog);
    exit(-1);
  }
}

/*
 * check_convolution - look up convolution to see if it exists in the database
 *   return value:
 *     1 if found
 *     0 if not found
 */
char *system_db_path = "/opt/rocm/miopen/share/miopen/db/miopen.db";
char user_db_path[128];
int lookup_convolution(sqlite3 *sqldb);
int check_convolution(){
  struct stat statbuf;
  char system_db[128];
  fetch_gpu_architecture();
  if (stat(system_db_path,&statbuf) != 0){
    fprintf(stderr,"%s: system db not found: %s\n",prog,system_db_path);
    exit(-1);
  }
  sqlite3 *system_sqlite_db;
  if (sqlite3_open(system_db_path,&system_sqlite_db) != SQLITE_OK){
    fprintf(stderr,"%s: unable to open %s database\n",prog,system_db_path);
    exit(-1);
  }
  int found = lookup_convolution(system_sqlite_db);
  sqlite3_close(system_sqlite_db);
  if (found){
    printf("found (%d)\n",found);
    return found;
  }
  
  sprintf(user_db_path,"%s/.config/miopen/miopen.udb",getenv("HOME"));
  if (stat(user_db_path,&statbuf) == 0){
    sqlite3 *user_sqlite_db;    
    if (sqlite3_open(user_db_path,&user_sqlite_db) != SQLITE_OK){
      fprintf(stderr,"%s: unable to open %s database\n",prog,user_db_path);
      exit(-1);
    }
    found = lookup_convolution(user_sqlite_db);
    sqlite3_close(user_sqlite_db);
    if (found){
      printf("found (%d)\n",found);
      return found;
    }
  }
  printf("not found\n");
  return 0;
}

int count = 0;
int callback(void *notused,int argc,char **argv,char **azcolname){
  count++;
  return 0;
}

int lookup_convolution(sqlite3 *sqldb){
  char *err_msg = NULL;
  char sql_stmt[1024];
  sprintf(sql_stmt,"SELECT * FROM config WHERE in_channels = '%d' AND in_h = '%d' AND in_w = '%d' AND filter_h = '%d' AND filter_w = '%d' AND out_channels = '%d' AND batchsize = '%d' AND pad_h = '%d' AND pad_w = '%d' AND conv_stride_1 = '%d' AND conv_stride_0 = '%d' AND dilation_h = '%d' AND dilation_w = '%d' AND bias = '%d' AND layout = '%s' AND data_type = '%s' AND direction = '%s' AND group_count = '%d'",
	  in_channels,
	  in_h,
	  in_w,
	  fil_h,
	  fil_w,
	  out_channels,
	  batchsize,
	  pad_h,
	  pad_w,
	  conv_stride_h,
	  conv_stride_w,
	  dilation_h,
	  dilation_w,
	  bias,
	  layout,
	  data_type,
	  direction,
	  group_count
	  );
  count = 0;
  int rc = sqlite3_exec(sqldb,sql_stmt,callback,0,&err_msg);
  if (rc != SQLITE_OK){
    fprintf(stderr,"Failed to select data\n");
    fprintf(stderr,"SQL error: %s\n",err_msg);
    sqlite3_free(err_msg);
  }
  return count;
}

/*
 * main program
 *
 * Returns:
 *    -1 if an error is found
 *    0  if command line is not found in sqlite3
 *    1  if command line is found in sqlite3
 */
int main(int argc,char *const argv[]){
  prog = argv[0];
  if (argc < 4){
    usage(prog);
    exit(-1);
  }
  // parse the overall mode
  if (!strcmp(argv[1],"check")){
  } else if (!strcmp(argv[1],"tune")){
  } else {
    fprintf(stderr,"%s: invalid mode: %s\n",prog,argv[1]);
    usage(prog);
    exit(-1);
  }
  
  // check to make sure MIOpen base arg is ok
  int miopen_base_idx = -1;
  for (int i=0;i<sizeof(miopen_base)/sizeof(miopen_base[0]);i++){
    if (!strcmp(argv[2],miopen_base[i])){
      miopen_base_idx = i;
      break;
    }
  }
  switch(miopen_base_idx){
  case -1:
    fprintf(stderr,"%s: invalid MIOpenDriver base arg: %s\n",prog,argv[2]);
    usage(prog);
    exit(-1);
  case 0: // conv
    break;
  case 1: // convfp16
    data_type = "FP16";
    break;
  case 6: // pool
  case 7: // poolfp16
  case 8: // lrn
  case 9: // lrnfp16
  case 10: // activ
  case 11: // activfp16
  case 12: // softmax
  case 13: // softmaxfp16
  case 14: // bnorm
  case 15: // bnormfp16
  case 16: // rnn
  case 17: // rnnfp16
  case 20: // dropout
  case 21: // dropoutfp16
    // not in tuning database
    return 0;
  default:
    printf("mode = %s\n",argv[2]);
  }

  // check the MIOpen arguments
  if (parse_miopen_options(argc-2,&argv[2])){
    fprintf(stderr,"%s: invalid miopen arguments\n",prog);
    usage(prog);
    exit(-1);
  }

  if (!strcmp(argv[1],"check")){
    return check_convolution();
  }
  fprintf(stderr,"%s: tune mode not implemented\n",prog);
  return -1;
}
