BASECFLAGS=-Wall -Wextra -pedantic
CFLAGS=$(BASECFLAGS) -std=c++11

all: idk build

idk: idk.cpp include/utils.h include/glc.h include/randable.h
	g++ $(CFLAGS) -o idk idk.cpp

build: build.c
	gcc $(BASECFLAGS) -std=c89 -o build build.c
