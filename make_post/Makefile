APP=make_post

$(APP): src/main.cpp
	LANG= g++ -o $@ -g src/main.cpp -I../tgbot-cpp/include/ -L../tgbot-cpp/ -lTgBot -lboost_system -lssl -lcrypto -lpthread
