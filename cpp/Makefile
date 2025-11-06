.PHONY: all

CC=cc
CXX=c++
BASECFLAGS=-Wall -Wextra -pedantic
CXXFLAGS=$(BASECFLAGS) -std=c++11 -Iinclude
CFLAGS=$(BASECFLAGS) -std=c89

all: example

example: example.cpp build
	./build
	$(CXX) $(CXXFLAGS) -o example example.cpp

build: build.c
	$(CC) $(CFLAGS) -o build build.c
