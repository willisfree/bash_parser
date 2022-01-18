#include <iostream>
#include <sstream>

#include "PostGen.h"

PostGen::PostGen(const Post& p)
	: post{p} { }

std::string PostGen::to_html() const	// add preview image
{
	const std::string invisible_html_character = "&#8288";

	std::ostringstream os;

	// add preview url
	os << "<a href=\"";
	os << post.preview_url << "\">";
	os << invisible_html_character << "</a>";	// no new line here because then title will be on new line
							// (it is't beautiful)

	os << "<b>" << post.title << "</b>\n\n";
	os << "<b>" << Post::DescrLit::body << "</b>\n";
	os << post.body << '\n' << '\n';
	os << "<b>" << Post::DescrLit::price << "</b>\n";
	os << post.price << '\n' << '\n';
	os << "<b>" << Post::DescrLit::url << "</b>\n";
	os << post.url << '\n';
	return os.str();
}

std::string PostGen::to_md() const
{
	return "";	// not implemented yet
}

std::string PostGen::to_plain() const
{
	std::ostringstream os;
	os << post;
	return os.str();
}
