#include <string>
#include <iostream>
#include <boost/core/demangle.hpp>
#include <glc.h>
#include <randable.h>

using MachineN = glc::have_fun<glc::randable>;

template <class T>
std::string type_name() {
    return boost::core::demangle(typeid(T).name());
}

int main() {
    std::cout << type_name<MachineN>() << "\n";
}
