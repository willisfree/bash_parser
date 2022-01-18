#include <iostream>
#include <fstream>
//#include <exception>

#include "Csv.h"
#include "Tools.h"

std::ostream& operator<<(std::ostream& os, const Csv& csv)
{
	std::vector<Line> lines = csv.get();
	//std::cerr << "SIZE: " << lines.size() << '\n';
	for (int i=0; i<lines.size(); ++i) {
		os << "line " << i << '\n';
		for (int k=0; k<lines[i].columns.size(); ++k) {
			os << "\tcol: " << k << ' ' << lines[i].columns[k] << '\n';
		}
	}
	return os;
}

Csv::Csv(const std::string& file)
{
	std::ifstream ifs{file};
	if (!ifs) error("failed to open "+file+" for csv parsing");

	while (ifs) {
		Line line;
		parse_line(ifs, line);
		if (line)  {
			lines.push_back(line);
		}
	}
}
/*
Csv::Csv(const std::string& buffer)
{
	for (std::string line; parse_line(ifs, line); ) {
		lines.push_back(line);
	}
}
*/

// reads characters into a buffer till a delim, but not inclusive it
std::istream& read_till(std::istream& is, std::string& buffer, char delim)
{
	for (char ch; is.get(ch); buffer+=ch) {
		if (ch==delim) {
			is.unget();
			return is;
		}
	}
	return is;
}

// read from an istream while a lamda doesn't return true
template<typename Func>
std::istream& read_while(std::istream& is, std::string& buffer, Func pred)
{
	for (char ch; is.get(ch); buffer+=ch) {
		if (pred(ch)) {
			is.unget();
			return is;
		}
	}
	return is;
}

// reads characters into a buffer inclusive a delim
std::istream& read_incl(std::istream& is, std::string& buffer, char delim)	
{
	for (char ch; is.get(ch); ) {
		buffer+=ch;
		if (ch==delim) return is;
	}
	return is;
}

// reads an escaped column; double quotes which wrapped a string will be discarded
void Csv::read_esc_col(std::istream& is, std::string& buffer)
{
	if (is.get() == clit.dquotes) {			// doesn't save a first dquotes; it's right.
		read_incl(is, buffer, clit.dquotes);
		read_esc_col(is, buffer);
		//is.get();				// discard an enclosing double quotes
	}
	else {	// we reach the end of an escaped column
		is.unget();
		buffer.pop_back();		// delete enclosing double quotes
	}
}
// reads a non-escaped column to a comma or an eof
void Csv::read_col(std::istream& is, std::string& buffer)
{
	read_while(is, buffer, [](char ch) {
		return ((ch == clit.comma) || (ch == clit.newline));
	});
}

// doesn't support empty fields; i.e. doesn't adds it
// parse line by fields a.k.a columns
std::istream& Csv::parse_line(std::istream& is, Line& line)
{
	for (char ch = is.peek(); is; ch=is.peek()) {
		//std::cerr << "CHAR: "<< ch << '\n';
		std::string col;
		if (ch == clit.dquotes) {
			read_esc_col(is, col);
			//std::cerr << "BUFFER: " << col << '\n';
			if (is && (is.peek() != clit.comma) && (is.peek() != clit.newline))
				error("invalid csv");
		}
		else if (ch == clit.newline) {	// end of the csv line
			is.get(); 		// discard it
			return is;		// and stop parsing for this line
		}
		else if (ch == clit.comma) {	// discard separating comma
			is.get();
			continue;
		}
		else {
			read_col(is, col);
			//std::cerr << "BUFFER: " << col << '\n';
			if (is && (is.peek() != clit.comma) && (is.peek() != clit.newline))
				error("invalid csv");
			//is.get();		// discard a following comma or new line
		}
		/*if (is && (is.peek() != clit.comma) && (is.peek() != clit.newline))
		  error("invalid csv");
		  */
		if (!col.empty())	// temper hack (i hope)
			line.add_col(col);

		if (!is && !is.eof()) {
			error("broken input stream while csv parsing");
		}
	}
	return is;
}
