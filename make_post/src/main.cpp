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

int main(int argc, char* argv[]) {

	if (argc != 2) {
		std::cout << "usage: " << argv[0] << " \"msg\"\n";
		exit(1);
	}

	string token(getenv("TOKEN"));
	printf("Token: %s\n", token.c_str());

	if (std::string{argv[1]}.empty())
		throw std::runtime_error("post's message is empty");

	std::string post;
	std::string message = argv[1];
	post += message;

	std::cerr << post << '\n';

	Bot bot(token);
	//const long my_channel_id = -your_id;	// old for dev
	const long my_channel_id = -your_id;	// new for pruduction
	make_post(bot, my_channel_id, post);

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
