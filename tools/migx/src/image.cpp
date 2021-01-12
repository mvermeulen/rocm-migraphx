/*
 * image.cpp - image processing using OpenCV
 */
#include <stdlib.h>
#include <iostream>
#include "migx.hpp"

#if OPENCV
#include <opencv2/opencv.hpp>
using namespace cv;

void read_image(std::string filename,enum image_type etype,std::vector<float> &image_data,bool is_nhwc,bool is_torchvision){
  Mat img,scaleimg,cropimg;
  int resize_num, image_size;

  switch(etype){
  case image_unknown:
    std::cerr << migx_program << ": unknown image type" << std::endl;
    return;
  case image_imagenet224:
    resize_num = 256;
    image_size = 224;
    break;
  case image_imagenet299:
    resize_num = 299;
    image_size = 299;
    break;
  default:
    std::cout << "imagenet ??? " << etype << std::endl;
    break;
  }
  double mean[3];
  double stdev[3];
  if (is_torchvision){
    mean[0] = 0.485;
    mean[1] = 0.456;
    mean[2] = 0.406;
    stdev[0] = 0.229;
    stdev[1] = 0.224;
    stdev[2] = 0.225;
  } else {
    mean[0] = 0.5;
    mean[1] = 0.5;
    mean[2] = 0.5;
    stdev[0] = 0.5;
    stdev[1] = 0.5;
    stdev[2] = 0.5;
  }
  //  img = imread(filename,CV_LOAD_IMAGE_COLOR);
  img = imread(filename,cv::IMREAD_COLOR);
  Mat_<Vec3b> _img = img;
  int pixel_orig0 = _img(0,0)[0];
  int pixel_orig1 = _img(0,0)[1];
  int pixel_orig2 = _img(0,0)[2];    
  if (!img.data){
    std::cerr << migx_program << ": unable to load image file " << filename << std::endl;
    return;
  }
  // resize the image for imagenet
  double scale = resize_num / (double) min(img.rows,img.cols);
  if (img.cols == img.rows)
    resize(img,scaleimg,Size(resize_num,resize_num));    
  else if (img.cols < img.rows)
    resize(img,scaleimg,Size(resize_num,img.rows*scale));
  else
    resize(img,scaleimg,Size(img.cols*scale,resize_num));    
  // center crop to appropriate size
  //  std::cout << "rows = " << scaleimg.rows << std::endl;
  //  std::cout << "cols = " << scaleimg.cols << std::endl;
  //  std::cout << "orow = " << img.rows << std::endl;
  //  std::cout << "ocol = " << img.cols << std::endl;  
  //  std::cout << "left = " << (scaleimg.cols-image_size)/2 << std::endl;
  //  std::cout << "top  = " << (scaleimg.rows-image_size)/2 << std::endl;
  cropimg = scaleimg(Rect((scaleimg.cols-image_size)/2,
			  (scaleimg.rows-image_size)/2,
			  image_size,image_size));
  // PyTorch image processing
  // normalize to: mean[0.485,0.456,0.406] std[0.229,0.224,0.224]
  // Change from HWC to CHW and convert to float32
  // Also change from BGR to RGB
  Mat_<Vec3b> _image = cropimg;
  int pixel0 = _image(0,0)[0];
  if (is_nhwc){
    for (int i=0;i < image_size;i++)
      for (int j=0;j < image_size;j++){
	image_data[3*((i*image_size)+j)+0] = (_image(i,j)[2]/255.0 - mean[0])/stdev[0];
	image_data[3*((i*image_size)+j)+1] = (_image(i,j)[1]/255.0 - mean[1])/stdev[1];
	image_data[3*((i*image_size)+j)+2] = (_image(i,j)[0]/255.0 - mean[2])/stdev[2];		
      }
  } else {
    for (int i=0;i < image_size;i++)
      for (int j=0;j < image_size;j++){
	image_data[0*image_size*image_size + i*image_size + j] = (_image(i,j)[2]/255.0 - mean[0])/stdev[0];
	image_data[1*image_size*image_size + i*image_size + j] = (_image(i,j)[1]/255.0 - mean[1])/stdev[1];
	image_data[2*image_size*image_size + i*image_size + j] = (_image(i,j)[0]/255.0 - mean[2])/stdev[2];
      }
  }
  //  std::cout << "Orig  0 = " << pixel_orig0 << std::endl;
  //  std::cout << "Orig  1 = " << pixel_orig1 << std::endl;
  //  std::cout << "Orig  2 = " << pixel_orig2 << std::endl;
  //  std::cout << "Pixel 0 = " << pixel0 << std::endl;
  //  std::cout << "Float 0 = " << image_data[0] << std::endl;
}

// return the indices of the top elements, simple iterative algorithm
// quick and dirty implementation, I expect there is a std::sort approach as well...
struct float_idx { float value; int index; };
int compare_float_idx(const void *elt1,const void *elt2){
  if (*((float *) elt1) > *((float *) elt2)) return 1;
  else if (*((float *) elt1) < *((float *) elt2)) return -1;
  else return 0;
}

void image_top5(float* array,int *top5){
  int i;
  struct float_idx sort_array[1000];
  for (int i=0;i<1000;i++){
    sort_array[i].value = array[i];
    sort_array[i].index = i;
  }
  qsort(sort_array,1000,sizeof(struct float_idx),compare_float_idx);
  top5[0] = sort_array[999].index;
  top5[1] = sort_array[998].index;
  top5[2] = sort_array[997].index;
  top5[3] = sort_array[996].index;
  top5[4] = sort_array[995].index;
  if (is_verbose){
    std::cout << "Top5" << std::endl;
    std::cout << "\tlabel=" << sort_array[999].index << " value=" << sort_array[999].value << std::endl;
    std::cout << "\tlabel=" << sort_array[998].index << " value=" << sort_array[998].value << std::endl;
    std::cout << "\tlabel=" << sort_array[997].index << " value=" << sort_array[997].value << std::endl;
    std::cout << "\tlabel=" << sort_array[996].index << " value=" << sort_array[996].value << std::endl;
    std::cout << "\tlabel=" << sort_array[995].index << " value=" << sort_array[995].value << std::endl;
  }
}
#else
void read_image(std::string filename,enum image_type etype,std::vector<float> &image_data,bool is_nhwc,bool is_torchvision){
  std::cout << "OpenCV not installed" << std::endl;
  exit(0);
}

void image_top5(float* array,int *top5){
}
#endif
