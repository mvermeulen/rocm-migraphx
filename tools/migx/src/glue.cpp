/*
 * glue.cpp - read and return strings for GLUE benchmark data
 *
 */
#include <vector>
#include <string>
#include <unordered_map>

void parse_sentence(const std::string& sent, std::vector<int64_t>& vec_feature)
{
    size_t pos = 0, pos_next;
    size_t index = 0;
    while ((pos_next = sent.find(',', pos)) != std::string::npos)
    {
        auto word_feature = sent.substr(pos, pos_next);
        vec_feature.push_back(std::stoll(word_feature));
        pos = pos_next + 1;
    }
    vec_feature.push_back(std::stoll(sent.substr(pos)));
    vec_feature.push_back(102);
}

int parse_line(std::string& line, std::size_t sent_size, 
        std::unordered_map<std::string, std::vector<int64_t>>& input_map)
{
    auto& vec_feature = input_map["vec_feature"];
    auto& vec_id = input_map["vec_id"];
    auto& seg_id = input_map["seg_id"];
    vec_feature.clear();
    vec_id.clear();
    seg_id.clear();

    size_t pos = line.find('\t');
    int label = std::stoi(line.substr(0, pos));

    ++pos;
    size_t pos_next = line.find('\t', pos);
    vec_feature.push_back(101);
    parse_sentence(line.substr(pos, pos_next), vec_feature);
    vec_id.resize(vec_feature.size(), 0);

    pos = pos_next + 1;
    parse_sentence(line.substr(pos), vec_feature);
    vec_id.resize(vec_feature.size(), 1);
    seg_id.resize(vec_feature.size(), 1);

    vec_feature.resize(sent_size, 0);
    vec_id.resize(sent_size, 0);
    seg_id.resize(sent_size, 0);

    return label;
}
