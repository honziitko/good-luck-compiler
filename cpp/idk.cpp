#include <string>
#include <iostream>
#include <boost/core/demangle.hpp>
#include "include/glc.h"
#include "include/randable.h"

#define ZEROS_5  0, 0, 0, 0, 0
#define ZEROS_10 ZEROS_5,  ZEROS_5
#define ZEROS_20 ZEROS_10, ZEROS_10

using TapeLeft = glc::utils::vector<glc::Symbol, ZEROS_20>;
using TapeRight = glc::utils::vector<glc::Symbol, ZEROS_20>;

using Machine0 = glc::machine_state<-1, 1, TapeLeft, TapeRight>;
using MachineN = glc::have_fun<glc::randable, Machine0>;

template <class T>
std::string type_name() {
    return boost::core::demangle(typeid(T).name());
}

int main() {
    std::cout << type_name<Machine0>() << "\n";
    std::cout << type_name<MachineN>() << "\n";
}
