#include <string>
#include <iostream>
#include <boost/core/demangle.hpp>
#include "include/glc.h"

template <glc::State, glc::Symbol>
struct TransitionTable {};

template<>
struct TransitionTable<1, 0> : glc::transition_entry<glc::halt, 1, glc::Direction::left> {};
template<>
struct TransitionTable<1, 1> : glc::transition_entry<1, 0, glc::Direction::left> {};

using TapeLeft = glc::utils::vector<glc::Symbol, 0, 1>;
using TapeRight = glc::utils::vector<glc::Symbol, 0>;

using Machine0 = glc::machine_state<-1, 1, TapeLeft, TapeRight>;
using Machine1 = glc::next_state<TransitionTable, Machine0>;
using Machine2 = glc::next_state<TransitionTable, Machine1>;
using Machine3 = glc::next_state<TransitionTable, Machine2>;

template <class T>
std::string type_name() {
    return boost::core::demangle(typeid(T).name());
}

int main() {
    std::cout << type_name<Machine0>() << "\n";
    std::cout << type_name<Machine1>() << "\n";
    std::cout << type_name<Machine2>() << "\n";
    std::cout << type_name<Machine3>() << "\n";
}
