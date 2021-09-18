// definitions for migx driver
#include <string>
#include <vector>
#include <unordered_map>

extern std::string migx_program;
extern const char *imagenet_labels[];
enum image_type { image_unknown=0, image_imagenet224, image_imagenet299, image_mnist };
extern int is_verbose;
enum glue_type { glue_none, glue_cola, glue_mnli, glue_mrpc, glue_qnli, glue_qqp, glue_rte, glue_snli, glue_sst, glue_sts, glue_wnli };

void rimage(std::vector<float> &img_data);

void read_image(std::string filename,enum image_type etype,std::vector<float> &img_data,bool is_nhwc,bool is_torchvision);
void image_top5(float *res,int *top5);

int initialize_mnist_streams(std::string dir,int &num_images);
void read_mnist(std::vector<float> &img_data,int &labelnum);
void ascii_mnist(std::vector<float> &img_data,int labelnum);
void debug_mnist(std::vector<float> &img_data);
void finish_mnist_streams();

void read_float_file(std::string filename,std::vector<float> &img_data);

int parse_line(std::string& line, std::size_t sent_size, 
	       std::unordered_map<std::string, std::vector<int64_t>>& input_map);
