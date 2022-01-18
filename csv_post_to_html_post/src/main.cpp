#include <iostream>
#include <fstream>
#include <cstdlib>

#include "Csv.h"
#include "Tools.h"
#include "Post.h"
#include "PostGen.h"

// contain number of line with last post
// begin from zero i.e zero is the first post
class PostsCounter {
public:
	PostsCounter() {
		std::string file = "enter_your_path_to_file/next_line";	// must already exist with number
		fs.open(file);//, std::ios_base::in | std::ios_base::out);
		if (!fs)
			error("failed to open "+file);
		fs >> last_csv_line;
	}

	~PostsCounter()
	{
		fs.seekg(0, std::ios::beg);
		fs << last_csv_line;
		fs.close();
	}

	operator int() const { return last_csv_line; }
	PostsCounter& operator++() { last_csv_line++; return *this; } // prefix increment
	PostsCounter& operator=(int num) { last_csv_line=num; return *this; }

private:
	std::fstream fs;
	int last_csv_line = 0;
};

// generates html post from csv posts and prints it on stdout
int main(int argc, char* argv[])
try
{
        if (argc != 2) {
                std::cerr << "usage: " << argv[0] << " \"file with csv_posts\"\n";
		std::exit(1);
        }
	std::string csv_file = argv[1];
/*
	std::string ofile = "html_posts";
	std::ofstream html_posts {ofile};
	if (!html_posts) {
		std::cerr << "failed to open: " << ofile << '\n';
		std::exit(1);
	}
	*/

	Csv csv_posts{csv_file};
	//std::cerr << csv_posts << '\n';

	//std::vector<Post> posts;
	PostsCounter counter;
	int curr = 0; // begin from zero i.e zero is the first post
	for (Line& l : csv_posts) {
		if (curr == counter) {
			Post p{l.columns[0], l.columns[2], l.columns[3], l.columns[4], l.columns[6]};
			std::cout << PostGen{p}.to_html();
			counter = curr+1;
			return 0;
		}
		curr++;
	}

			/*
		std::cerr << l.columns.size() << '\n';
		posts.emplace_back(Post{l.columns[0], l.columns[1], l.columns[2], l.columns[3]});
		curr++;
	}

	for (auto post : posts)
		html_posts << PostGen{post}.to_html() << '\n';
		*/
	return 1; // means error
}
catch(std::exception& e) {
	std::cerr << "exception " << e.what() << '\n';
	return 1;
}
catch(...) {
	std::cerr << "unkown exception\n";
	return 2;
}
