#include <iostream>
#include <fstream>
#include <cstdlib>
#include <map>
#include <algorithm>

#include "Csv.h"
#include "Tools.h"
#include "Post.h"
#include "PostGen.h"

enum class Tag {
	development=1,
	seo,
	market,
	text,
	design
};


// for vector like containers
template<typename Cont>
void delete_same(Cont& cont)
{
	Cont unique;
	for (int i=0; i<cont.size(); ++i) {
		if (i == 0 || cont[i] != cont[i-1])
			unique.push_back(cont[i]);
	}
	unique.swap(cont);
}

int main(int argc, char* argv[])
try
{
	 if (argc != 2) {
                std::cerr << "usage: " << argv[0] << " \"file with csv_posts\"\n";
                std::exit(1);
        }
        std::string csv_file = argv[1];

	Csv csv_posts{csv_file};
	//std::cerr << csv_posts << '\n';

	std::map<std::string, int> url_tag;
	std::vector<int> tags;
	for (Line& l : csv_posts) {
		std::string url = l.columns[0];
		int tag = std::stoi(l.columns[1]);

		url_tag[url]=tag;
		tags.push_back(tag);
	}
	std::sort(std::begin(tags), std::end(tags));
	delete_same(tags);

	std::vector<std::string> sorted;
	while (!url_tag.empty()) {
		for (int tid : tags) {
			auto iter = find_if(std::begin(url_tag), std::end(url_tag), [&tid](auto pair) { return pair.second == tid; });
			if (iter == url_tag.end()) {
				//no more url with corrensonding tag id
			}
			else {
				sorted.push_back(iter->first);
				url_tag.erase(iter);
			}
		}
	}

	// print to stdout
	for (auto val : sorted)
		std::cout << val << '\n';
}
catch(std::exception& e) {
	std::cerr << "exception " << e.what() << '\n';
	return 1;
}
catch(...) {
	std::cerr << "unkown exception\n";
	return 2;
}
