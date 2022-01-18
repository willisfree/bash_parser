#ifndef POST_H
#define POST_H

#include <string>
#include <iostream>

class Post {
public:

	// Post's describing literals; add: read them from file and suport utf8
	struct DescrLit {

		static const std::string url;
		static const std::string title;
		static const std::string body;
		static const std::string price;
	};

	Post(const std::string& url, const std::string& title, const std::string& body, const std::string& price, const std::string& prev_url)
		: url{url}, title{title}, body{body}, price{price}, preview_url{prev_url} { }

	//friend std::ostream& operator<<(std::ostream& os, const Post& post);

	std::string url;
	std::string title;
	std::string body;
	std::string price;
	std::string preview_url;
};

std::ostream& operator<<(std::ostream& os, const Post& post);
#endif
