/*
 * mnist.cpp - read mnist data files from http://yann.lecun.com/mnist
 *
 * NOTE: uses C file reading operations for binary files since found it easier to set up
 */
#include <stdio.h>
#include <iostream>
#include <fstream>
#include "migx.hpp"

int nimages = -1;
FILE *image_fp;
FILE *label_fp;

int initialize_mnist_streams(std::string dir,int &num_images){
  struct test_image_file_header {
    int magic;
    int num_images;
    int num_rows;
    int num_cols;
  } image_header;
  struct test_label_file_header {
    int magic;
    int num_labels;
  } label_header;
  std::string test_image_filename = dir + "/" + "t10k-images-idx3-ubyte";
  std::string test_label_filename = dir + "/" + "t10k-labels-idx1-ubyte";
  if ((image_fp = fopen(test_image_filename.c_str(),"r")) == 0) return 1;
  if ((label_fp = fopen(test_label_filename.c_str(),"r")) == 0) return 1;
  fread(&image_header,sizeof(image_header),1,image_fp);
  fread(&label_header,sizeof(label_header),1,label_fp);  
#if 0
  fprintf(stdout,"magic = %x, images = %d, rows = %d, cols = %d\n",
	  __builtin_bswap32(image_header.magic),
	  __builtin_bswap32(image_header.num_images),
	  __builtin_bswap32(image_header.num_rows),
	  __builtin_bswap32(image_header.num_cols));
  
  fprintf(stdout,"magic = %x, labels = %d\n",
	  __builtin_bswap32(label_header.magic),
	  __builtin_bswap32(label_header.num_labels));
#endif
  num_images = __builtin_bswap32(image_header.num_images);
  return 0;
}

void read_mnist(std::vector<float> &img_data,int &labelnum){
  int i,j;
  unsigned char pixel;
  for (i=0;i<28;i++){
    for (j=0;j<28;j++){
      pixel = fgetc(image_fp);
      img_data[i*28+j] = pixel / 255.0;
    }
  }
  labelnum = fgetc(label_fp);
}

void ascii_mnist(std::vector<float> &img_data,int labelnum){
  int i,j;
  for (i=0;i<28;i++){
    for (j=0;j<28;j++){
      if (img_data[i*28+j] > 0.5){
	fputc('@',stdout);
      } else {
	fputc('.',stdout);
      }
    }
    fputc('\n',stdout);
  }
  fprintf(stdout,"label = %d\n",labelnum);
}

void debug_mnist(std::vector<float> &img_data){
  int i,j;
  for (i=0;i<28;i++){
    for (j=0;j<28;j++){
      std::cout << img_data[i*28+j] << std::endl;
    }
  }
}

void finish_mnist_streams(){
  fclose(image_fp);
  fclose(label_fp);
}
