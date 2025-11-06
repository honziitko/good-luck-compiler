#include <string>
#include <iostream>
#include <boost/core/demangle.hpp>
#include "include/glc.h"
#include "include/randable.h"

using EmptyTape = glc::utils::vector<glc::Symbol>;

using Machine0 = glc::machine_state<0, 1, EmptyTape, EmptyTape>;
using MachineN = glc::have_fun<glc::randable, Machine0>;

template <class T>
std::string type_name() {
    return boost::core::demangle(typeid(T).name());
}

int main() {
    std::cout << type_name<Machine0>() << "\n";
    std::cout << type_name<MachineN>() << "\n";
}
