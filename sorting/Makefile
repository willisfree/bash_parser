#g++ main.cpp Post.cpp PostGen.cpp Csv.cpp Tools.cpp

APP=sort
CPP=g++ -std=c++14

RELATIVE_PATH=.
LOCAL_HEADERS= -I $(RELATIVE_PATH)/include/
HEADERS=$(LOCAL_HEADERS)

SRC_PATH=$(RELATIVE_PATH)/src/
SOURCES=$(wildcard $(SRC_PATH)*.cpp)

LD_OPTS=

# % is any non-empty string using for strings substitution
OBJ_PATH=$(RELATIVE_PATH)/obj/
OBJECTS=$(patsubst $(SRC_PATH)%.cpp, $(OBJ_PATH)%.o, $(SOURCES)) # just string
                        # it depend on sources *.cpp files not on real *.o files

all: $(APP)

new: clean $(APP)

$(APP): $(OBJECTS)
	$(CPP) $(LD_OPTS) $(OBJECTS) -o $@

$(OBJ_PATH)%.o: $(SRC_PATH)%.cpp
	$(CPP) $(HEADERS) -g -c $< -o $@

clean:
	rm -f $(OBJ_PATH)*.o && rm -f $(APP)
