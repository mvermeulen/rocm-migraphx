/*
 * routines for looking up MIOpen sqlite3 db entries
 */
#include <stdio.h>
#include <stdarg.h>
#include <stdlib.h>
#include <string.h>
#include <sqlite3.h>

#define DBFILE "/opt/rocm/miopen/share/miopen/db/gfx906_60.db"

static sqlite3 *db_handle = NULL;

void db_error(char *format,...){
  va_list ap;
  va_start(ap,format);
  vfprintf(stderr,format,ap);
  va_end(ap);
}

int last_id;
int callback(void *cmd, int argc, char **argv, char **colname){
  int i;
  int save_id = 0;
  if (!strcmp(cmd,"save_id")) save_id = 1;
  for (i=0;i<argc;i++){
    if (save_id && !strcmp(colname[i],"id")) last_id = atoi(argv[i]);
    printf("\t%s = %s\n",colname[i],argv[i]? argv[i]:"NULL");
  }
  printf("\n");
  return 0;
}

struct field_list {
  char *name; char *value;
} db_fields[] = {
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

void db_lookup(int maxargs,...){
  int i;
  int count = 0;
  int argnum = 0;
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
  int num_fields = sizeof(db_fields)/sizeof(db_fields[i]);
  struct field_list *query_values = calloc(num_fields,sizeof(struct field_list));
  for (i=0;i<num_fields;i++){
    query_values[i].name = db_fields[i].name;
    query_values[i].value = strdup(db_fields[i].value);
  }
  
  *p = '\0';
  va_start(ap,maxargs);
  while (argnum < num_fields){
    arg = strdup(va_arg(ap,char *));
    if (!strcmp(arg,"END")) break;

    found = 0;
    for (i=0;num_fields;i++){
      if (!strncmp(arg,query_values[i].name,strlen(query_values[i].name))){
	found = 1;
	break;
      }
    }
    if (!found){
      printf("unknown database field: %s\n",arg);
      return;
    }
    free(query_values[i].value);
    query_values[i].value = strdup(va_arg(ap,char *));
    argnum++;
  }
  va_end(ap);
  for (i=0;i<num_fields;i++){
    if (i!= 0){
      strncat(p," AND ",len);
      len -= 5;
    }
    strncat(p,query_values[i].name,len);
    len -= strlen(query_values[i].name);

    strncat(p," = '",len);
    len -= 4;

    strncat(p,query_values[i].value,len);
    len -= strlen(query_values[i].value);
    free(query_values[i].value);

    strncat(p,"'",len);
    len -= 1;
  }
  free(query_values);

  strcpy(buffer,"SELECT COUNT(*) FROM config WHERE ");
  strcat(buffer,sql_buffer);
  printf("sql = %s\n",buffer);
  result = sqlite3_prepare_v2(db_handle,buffer,-1,&res,0);
  if (result != SQLITE_OK){
    db_error("Unable to query database:\n\tsql = %s\n\terror = %s\n",buffer,sqlite3_errmsg(db_handle));
    return;
  }
  result = sqlite3_step(res);
  if (result = SQLITE_ROW){
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
  printf("sql = %s\n",buffer);
  result = sqlite3_exec(db_handle,buffer,callback,"save_id",&err_msg);
  if (result != SQLITE_OK){
    db_error("Unable to query database:\n\tsql=%s\n\terror = %s\n",buffer,sqlite3_errmsg(db_handle));
    return;
  }
  sprintf(buffer,"SELECT * FROM perf_db WHERE config = '%d'",last_id);
  printf("sql = %s\n",buffer);
  result = sqlite3_exec(db_handle,buffer,callback,"perf_db",&err_msg);
  if (result != SQLITE_OK){
    db_error("Unable to query database:\n\tsql=%s\n\terror = %s\n",buffer,sqlite3_errmsg(db_handle));
    return;
  }  
}

void db_open(char *dbfile){
  int result;
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
int main(int argc,char *argv){
  db_open(DBFILE);
  db_info();
  db_lookup(0,
	    "layout", "NCHW",
	    //	    "data_type", "FP32",
	    //	    "direction", "F",
	    //	    "spatial_dim", "2",
	    "in_channels", "3",
	    "in_h","224",
	    "in_w","224",
	    //	    "in_d","1",
	    "fil_h","7",
	    "fil_w","7",
	    //	    "fil_d","1",
	    "out_channels", "64",
	    "batchsize", "1",
	    "pad_h", "3",
	    "pad_w", "3",
	    //	    "pad_d", "0",
	    "conv_stride_h", "2",
	    "conv_stride_w", "2",
	    //	    "conv_stride_d", "0",
	    "dilation_h", "1",
	    "dilation_w", "1",
	    //	    "dilation_d", "0",
	    //	    "bias", "0",
	    "group_count", "1",
	    "END"
	    );
  db_close();
}
#endif
