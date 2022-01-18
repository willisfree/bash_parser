/*
 *	Post generator
 *	
 *	suported output formats: html.
 *
 */

#ifndef POST_GEN_H
#define POST_GEN_H

#include <string>

#include "Post.h"

class PostGen {
public:
	/*
	enum class Type {
		html, md, pltxt
	};
	*/

	PostGen(const Post& p);

	std::string to_html() const;
	std::string to_md() const;
	std::string to_plain() const;

private:
	const Post post;
	//const Type t;
};

#endif
