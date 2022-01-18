/*
 *	Csv parser
 *	specification https://tools.ietf.org/html/rfc4180
 *
 *	notes:
 *	it doesn't matter if one line contain more columns than another; it's possible
 *	and so it doesn't support empty lines
 *	and this code something messy, but in future i'll be better
 *
 */

#ifndef CSV_PARSER
#define CSV_PARSER

#include <iostream>
#include <string>
#include <vector>

struct Line {
	void add_col(const std::string& col) { columns.push_back(col); }
	operator bool() const { return !columns.empty(); }

	std::vector<std::string> columns;
};

struct csv_literals {
	const char newline = '\n';
	const char comma = ',';
	const char dquotes = '"'; // text inside double quotes can contain commas, new lines and escaped double quotes
};

class Csv {
public:
	Csv(const std::string& file);
	//Csv(const std::string& buffer);

	std::vector<Line>& get() { return lines; }
	const std::vector<Line>& get() const { return lines; }

	auto begin() { return lines.begin(); }
	auto end() { return lines.end(); }

private:

	std::istream& parse_line(std::istream& is, Line& line);		// parses a csv line into columns
	void read_esc_col(std::istream& is, std::string& buffer);
	void read_col(std::istream& s, std::string& buffer);

	std::vector<Line> lines;
	constexpr static csv_literals clit{};
};

std::ostream& operator<<(std::ostream& os, const Csv& csv);

#endif
