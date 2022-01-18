#include <csignal>
#include <cstdio>
#include <cstdlib>
#include <string>
#include <exception>
#include <stdexcept>

#include <tgbot/tgbot.h>

using namespace std;
using namespace TgBot;

// sends post in html format
template<typename T>
void make_post(const T& bot, long chat_id, const std::string& html_msg)
{
	//bot.getApi().sendMessage(chat_id, msg);
	bot.getApi().sendMessage(chat_id, html_msg, false, 0, nullptr, "HTML");
}

// add: preview url like argument
int main(int argc, char* argv[]) {

	if (argc != 3) {
		std::cout << "usage: " << argv[0] << " \"msg\" \"preview-url\"\n";
		exit(1);
	}

	string token(getenv("TOKEN"));
	printf("Token: %s\n", token.c_str());
/*
	std::string post = argv[1];
	post += "<a href=\"https://codex.so/upload/editor/o_5f254690d42854ebd26d699c192295f1.jpg\">&#8288</a>"; // preview image
*/

	if (std::string{argv[1]}.empty())
		throw std::runtime_error("post's message is empty");

	if (std::string{argv[2]}.empty())
		throw std::runtime_error("preview's url is empty");

	// preview image
	//std::string post = "<a href=\"https://codex.so/upload/editor/o_5f254690d42854ebd26d699c192295f1.jpg\">&#8288</a>"; 
	std::string post;
	std::string message = argv[1];
	std::string preview = "<a href=\"";
	preview += argv[2];
	preview += "\">&#8288</a>";
	post += preview;
	post += message;

	std::cerr << post << '\n';

	Bot bot(token);
	const long my_channel_id = -your_id;
	make_post(bot, my_channel_id, post);	// bot's self id

	bot.getEvents().onCommand("start", [&bot, &post](Message::Ptr message) {
		//bot.getApi().sendMessage(message->chat->id, "Hi!");
		make_post(bot, message->chat->id, post);
	});

	signal(SIGINT, [](int s) {
		printf("SIGINT got\n");
		exit(0);
	});
	return 0;
}


/*
   const string photoFilePath = "image.jpg";
   const string photoMimeType = "image/jpeg";

   bot.getEvents().onCommand("photo", [&bot, &photoFilePath, &photoMimeType](Message::Ptr message) {
   bot.getApi().sendPhoto(message->chat->id, InputFile::fromFile(photoFilePath, photoMimeType));
   });
*/
