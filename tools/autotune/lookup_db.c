/*
 * lookup_db - program to print MIOpen sqlite3 db entries.
 * 
 * This program takes the same command line arguments as
 *    /opt/rocm/miopen/bin/MIOpenDriver
 * However, rather than running MIOpen routines, it dumps contents of
 * the MIOpen sqlite database entries given as command line arguments.
 *
 *    lookup_db <args> <database>...
 */

#include <stdio.h>
#include <stdarg.h>
#include <stdlib.h>
#include <string.h>
#include <sqlite3.h>
#include <sys/stat.h>
#include <unistd.h>

extern char *get_architecture(void);

int verbose=2;
char *label = NULL;

// name:value pairs used for db lookups
struct name_value {
  char *name;
  char *value;
};

#define DBFILE "/opt/rocm/miopen/share/miopen/db/gfx906_60.db"

static sqlite3 *db_handle = NULL;

void db_error(char *format,...){
  va_list ap;
  va_start(ap,format);
  vfprintf(stderr,format,ap);
  va_end(ap);
}


int callback(void *cmd, int argc, char **argv, char **colname){
  int i;
  for (i=0;i<argc;i++){
    printf("\t%s = %s\n",colname[i],argv[i]? argv[i]:"NULL");
  }
  printf("\n");
  return 0;
}

int last_id;
int callback_config(void *cmd, int argc, char **argv, char **colname){
  int i;
  int save_id = 0;
  for (i=0;i<argc;i++){
    if (!strcmp(colname[i],"id")){
      last_id = atoi(argv[i]);
      if ((verbose == 0) || (verbose == 1)){
	if (label != NULL) printf("%s",label);
	printf("config = %s\n",argv[i]?argv[i]:"NULL");
      } else {
	printf("\t%s = %s\n",colname[i],argv[i]?argv[i]:"NULL");
      }
    }
  }
  for (i=0;i<argc;i++){
    if (!strcmp(colname[i],"id")) continue;
    if (verbose >= 1){
      printf("\t%s = %s\n",colname[i],argv[i]? argv[i]:"NULL");
    }
  }
  if (verbose >= 1) printf("\n");
  return 0;
}

int callback_perfdb(void *cmd, int argc, char **argv, char **colname){
  int i;
  char *solver=NULL;
  char *params=NULL;
  if (verbose == 0){
    for (i=0;i<argc;i++){
      if (!strcmp(colname[i],"solver")) solver = argv[i];
      if (!strcmp(colname[i],"params")) params = argv[i];
    }
    if ((solver != NULL) && (params != NULL)){
      printf("\t%s : %s\n",solver,params);
    }
  } else {
    for (i=0;i<argc;i++){
      printf("\t%s = %s\n",colname[i],argv[i]? argv[i]:"NULL");
    }
    printf("\n");
  }
  return 0;
}

struct name_value
db_defaults[] = {
		 { "layout","NCHW" },
		 { "data_type", "FP32" },
		 { "direction", "F" },
		 { "spatial_dim", "2" },
		 { "in_channels", "3" },
		 { "in_h", "32" },
		 { "in_w", "32" },
		 { "in_d", "1" },
		 { "fil_h","3" },
		 { "fil_w","3" },
		 { "fil_d","1" },
		 { "out_channels", "32" },
		 { "batchsize", "1" },
		 { "pad_h","0" },
		 { "pad_w","0" },
		 { "pad_d","0" },
		 { "conv_stride_h","1" },
		 { "conv_stride_w","1" },
		 { "conv_stride_d","0" },
		 { "dilation_h","1" },
		 { "dilation_w","1" },
		 { "dilation_d","0" },
		 { "bias", "0" },
		 { "group_count","1" },
};

void db_lookup(int nfield,struct name_value **fieldlist){
  int i,j;
  int count = 0;
  int found;
  int numargs;
  char sql_buffer[1024];
  char buffer[1200];
  char clause[1024];
  int len = sizeof(sql_buffer);
  char *p = sql_buffer;
  va_list ap;
  int result;
  char *arg,*value;
  char *err_msg;
  sqlite3_stmt *res;
  int num_fields = sizeof(db_defaults)/sizeof(db_defaults[i]);
  struct name_value *sql_query_values = calloc(num_fields,sizeof(struct name_value));
  for (i=0;i<num_fields;i++){
    sql_query_values[i].name = db_defaults[i].name;
    sql_query_values[i].value = strdup(db_defaults[i].value);
  }
  
  *p = '\0';
  for (i=0;i<nfield;i++){
    found = 0;
    for (j=0;j<num_fields;j++){
      if (!strcmp(fieldlist[i]->name,db_defaults[j].name)){
	found = 1;
	break;
      }
    }
    if (!found){
      printf("unknown database field: %s\n",fieldlist[i]->name);
      return;
    }
    free(sql_query_values[j].value);
    sql_query_values[j].value = strdup(fieldlist[i]->value);
  }

  for (i=0;i<num_fields;i++){
    if (i!= 0){
      strncat(p," AND ",len);
      len -= 5;
    }
    strncat(p,sql_query_values[i].name,len);
    len -= strlen(sql_query_values[i].name);

    strncat(p," = '",len);
    len -= 4;

    strncat(p,sql_query_values[i].value,len);
    len -= strlen(sql_query_values[i].value);
    free(sql_query_values[i].value);

    strncat(p,"'",len);
    len -= 1;
  }
  free(sql_query_values);

  strcpy(buffer,"SELECT COUNT(*) FROM config WHERE ");
  strcat(buffer,sql_buffer);
  if (verbose >= 2)
    printf("sql = %s\n",buffer);
  result = sqlite3_prepare_v2(db_handle,buffer,-1,&res,0);
  if (result != SQLITE_OK){
    db_error("Unable to query database:\n\tsql = %s\n\terror = %s\n",buffer,sqlite3_errmsg(db_handle));
    return;
  }
  result = sqlite3_step(res);
  if (result = SQLITE_ROW){
    if (verbose >= 2)
      printf("\t%s config entries\n",sqlite3_column_text(res,0));
    count = atoi(sqlite3_column_text(res,0));
  }
  sqlite3_finalize(res);
  if (count == 0){
    return;
  } else if (count != 1){
    printf("not found\n");
  }
  strcpy(buffer,"SELECT * FROM config WHERE ");
  strcat(buffer,sql_buffer);
  if (verbose >=2 )
    printf("sql = %s\n",buffer);
  result = sqlite3_exec(db_handle,buffer,callback_config,0,&err_msg);
  if (result != SQLITE_OK){
    db_error("Unable to query database:\n\tsql=%s\n\terror = %s\n",buffer,sqlite3_errmsg(db_handle));
    return;
  }
  sprintf(buffer,"SELECT * FROM perf_db WHERE config = '%d' ORDER BY solver",last_id);
  if (verbose >= 2)
    printf("sql = %s\n",buffer);
  result = sqlite3_exec(db_handle,buffer,callback_perfdb,0,&err_msg);
  if (result != SQLITE_OK){
    db_error("Unable to query database:\n\tsql=%s\n\terror = %s\n",buffer,sqlite3_errmsg(db_handle));
    return;
  }  
}

void db_open(char *dbfile){
  int result;
  if (verbose >= 1)
    printf("Opening %s\n",dbfile);
  if ((result = sqlite3_open_v2(dbfile,&db_handle,SQLITE_OPEN_READONLY,NULL)) != SQLITE_OK){
    db_error("Unable to open database: %s\n\terror = %s\n",dbfile,sqlite3_errmsg(db_handle));
  }
}

void db_dump(void){
  int result;
  char *err_msg;
  char *sql = "SELECT * FROM config";
  result = sqlite3_exec(db_handle,sql,callback,"dump",&err_msg);
  if (result != SQLITE_OK){
    db_error("Unable to query database:\n\tsql=%s\n\terror = %s\n",sql,sqlite3_errmsg(db_handle));
    return;
  }
  sql = "SELECT * FROM perf_db";
  result = sqlite3_exec(db_handle,sql,callback,"dump",&err_msg);  
  if (result != SQLITE_OK){
    db_error("Unable to query database:\n\tsql=%s\n\terror = %s\n",sql,sqlite3_errmsg(db_handle));
    return;
  }  
}

void db_info(void){
  int result;
  sqlite3_stmt *res;
  char *sql = "SELECT COUNT(*) FROM config";
  printf("Database information:\n");
  printf("\tsqlite3 version = %s\n",sqlite3_libversion());
  result = sqlite3_prepare_v2(db_handle,sql,-1,&res,0);
  if (result != SQLITE_OK){
    db_error("Unable to query database:\n\tsql = %s\n\terror = %s\n",sql,sqlite3_errmsg(db_handle));
  }
  result = sqlite3_step(res);
  if (result == SQLITE_ROW){
    printf("\t%s config entries\n",sqlite3_column_text(res,0));
  }
  sqlite3_finalize(res);
  
  sql = "SELECT COUNT(*) FROM perf_db";
  result = sqlite3_prepare_v2(db_handle,sql,-1,&res,0);
  if (result != SQLITE_OK){
    db_error("Unable to query database:\n\tsql=%s\n\terror = %s\n",sql,sqlite3_errmsg(db_handle));
  }
  result = sqlite3_step(res);
  if (result == SQLITE_ROW){
    printf("\t%s perf_db entries\n",sqlite3_column_text(res,0));
  }
  sqlite3_finalize(res);  
}

void db_close(void){
  sqlite3_close(db_handle);
}

#if TEST_DRIVER
int main(int argc,char **argv){
  int opt;
  int num;
  int i;
  int len;
  int nfield = 0;
  char *p;
  
  struct stat statbuf;
  struct name_value **field_values = calloc(argc,sizeof(struct name_value *));
  if ((p = getenv("VERBOSE")) != NULL){
    int value;
    if (sscanf(p,"%d",&value) == 1){ verbose = value; }
  }
  if ((p = getenv("LABEL")) != NULL){
    label = strdup(p);
  }
  len = strlen(argv[0]);
  if ((len >= 8) && (!strncmp(&argv[0][len-8],"tuneinfo",8))){
    printf("tuneinfo not implemented\n");
    return 0;
  } else {
    printf("%s\n",argv[0]);
  }
  
  while ((opt = getopt(argc,argv,"c:F:g:H:j:k:l:m:n:p:q:s:S:t:u:v:W:x:y:!:@:$:#:^:")) != -1){
    switch(opt){
    case 'c':
      field_values[nfield] = calloc(1,sizeof(struct name_value));
      field_values[nfield]->name = "in_channels";
      field_values[nfield]->value = strdup(optarg);
      nfield++;
      break;
    case 'F':
      field_values[nfield] = calloc(1,sizeof(struct name_value));
      field_values[nfield]->name = "direction";
      switch(num = atoi(optarg)){
      case 1:
	field_values[nfield]->value = "F";
	break;
      default:
	printf("unexpected value for -F: %d\n",num);
	return 0;
      }
      nfield++;
      break;
    case 'g':
      field_values[nfield] = calloc(1,sizeof(struct name_value));
      field_values[nfield]->name = "group_count";
      field_values[nfield]->value = strdup(optarg);
      nfield++;
      break;
    case 'H':
      field_values[nfield] = calloc(1,sizeof(struct name_value));
      field_values[nfield]->name = "in_h";
      field_values[nfield]->value = strdup(optarg);
      nfield++;
      break;      
    case 'j':
      field_values[nfield] = calloc(1,sizeof(struct name_value));
      field_values[nfield]->name = "dilation_w";
      field_values[nfield]->value = strdup(optarg);
      nfield++;
      break;      
    case 'k':
      field_values[nfield] = calloc(1,sizeof(struct name_value));
      field_values[nfield]->name = "out_channels";
      field_values[nfield]->value = strdup(optarg);
      nfield++;
      break;      
    case 'm':
      // convolution mode (conv, trans) not in db?
      break;
    case 'n':
      field_values[nfield] = calloc(1,sizeof(struct name_value));
      field_values[nfield]->name = "batchsize";
      field_values[nfield]->value = strdup(optarg);
      nfield++;
      break;
    case 'p':
      field_values[nfield] = calloc(1,sizeof(struct name_value));
      field_values[nfield]->name = "pad_h";
      field_values[nfield]->value = strdup(optarg);
      nfield++;
      break;
    case 'q':
      field_values[nfield] = calloc(1,sizeof(struct name_value));
      field_values[nfield]->name = "pad_w";
      field_values[nfield]->value = strdup(optarg);
      nfield++;
      break;      
    case 'W':
      field_values[nfield] = calloc(1,sizeof(struct name_value));
      field_values[nfield]->name = "in_w";
      field_values[nfield]->value = strdup(optarg);
      nfield++;
      break;
    case 's':
      // search
      break;
    case 'S':
      // solution
      break;
    case 't':
      // time each layer
      break;
    case 'u':
      field_values[nfield] = calloc(1,sizeof(struct name_value));
      field_values[nfield]->name = "conv_stride_h";
      field_values[nfield]->value = strdup(optarg);
      nfield++;
      break;
    case 'v':
      field_values[nfield] = calloc(1,sizeof(struct name_value));
      field_values[nfield]->name = "conv_stride_w";
      field_values[nfield]->value = strdup(optarg);
      nfield++;
      break;
    case 'x':
      field_values[nfield] = calloc(1,sizeof(struct name_value));
      field_values[nfield]->name = "fil_w";
      field_values[nfield]->value = strdup(optarg);
      nfield++;
      break;      
    case 'y':
      field_values[nfield] = calloc(1,sizeof(struct name_value));
      field_values[nfield]->name = "fil_h";
      field_values[nfield]->value = strdup(optarg);
      nfield++;
      break;      
    case '!':
      field_values[nfield] = calloc(1,sizeof(struct name_value));
      field_values[nfield]->name = "in_d";
      field_values[nfield]->value = strdup(optarg);
      nfield++;
      break;
    case '@':
      field_values[nfield] = calloc(1,sizeof(struct name_value));
      field_values[nfield]->name = "fil_d";
      field_values[nfield]->value = strdup(optarg);
      nfield++;
      break;
    case '$':
      field_values[nfield] = calloc(1,sizeof(struct name_value));
      field_values[nfield]->name = "pad_d";
      field_values[nfield]->value = strdup(optarg);
      nfield++;
      break;      
    case '#':
      field_values[nfield] = calloc(1,sizeof(struct name_value));
      field_values[nfield]->name = "conv_stride_d";
      field_values[nfield]->value = strdup(optarg);
      nfield++;
      break;
    case '^':
      field_values[nfield] = calloc(1,sizeof(struct name_value));
      field_values[nfield]->name = "dilation_d";
      field_values[nfield]->value = strdup(optarg);
      nfield++;
      break;
    case '?':
      return 0;
    }
    
  }
  if (optind == argc){
    // no db given, see if we can look them up
    char *arch,*p;
    char buffer[1024];
    FILE *fp;
    if ((arch = get_architecture()) != NULL){
      if (p = strchr(arch,':')) *p = '\000';

      sprintf(buffer,"find /opt/rocm/miopen/share/miopen/db -name *%s* -exec file {} \\; | grep SQLite | awk 'BEGIN { FS=\":\" } ; { print $1 }' ",arch);
      if ((fp = popen(buffer,"r")) != NULL){
	while (fgets(buffer,sizeof(buffer),fp)){
	  if (p = strchr(buffer,'\n')) *p = '\000';

	  if (stat(buffer,&statbuf) == 0){
	    db_open(buffer);
	    if (verbose >= 2){
	      db_info();
	    } else {
	      printf("%s\n",buffer);
	    }
	    db_lookup(nfield,field_values);
	    db_close();
	  } else {
	    printf("Unable to open database: %s\n",buffer);
	  }
	}
      }
      sprintf(buffer,"find %s/.config/miopen -name *%s* -exec file {} \\; | grep SQLite | awk 'BEGIN { FS=\":\" } ; { print $1 }' ",getenv("HOME"),arch);
      if ((fp = popen(buffer,"r")) != NULL){
	while (fgets(buffer,sizeof(buffer),fp)){
	  if (p = strchr(buffer,'\n')) *p = '\000';	  
	  if (stat(buffer,&statbuf) == 0){
	    db_open(buffer);
	    if (verbose >= 2){
	      db_info();
	    } else {
	      printf("%s\n",buffer);
	    }
	    db_lookup(nfield,field_values);
	    db_close();
	  } else {
	    printf("Unable to open database: %s\n",buffer);
	  }	
	}
      }
    }
  } else {
    for (i=optind;i<argc;i++){
      if (stat(argv[i],&statbuf) == 0){
	db_open(argv[i]);
	if (verbose >= 2){
	  db_info();
	} else {
	  printf("%s\n",argv[i]);
	}
	db_lookup(nfield,field_values);
	db_close();      
      } else {
	printf("Database %s does not exist\n",argv[i]);
      }
    }
  }
}
#endif

