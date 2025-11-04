#include <string>
#include <iostream>
#include <boost/core/demangle.hpp>
#include "include/utils.h"

using Vec = glc::utils::vector<int, 1, 2, 3>;
using Uec = glc::utils::vector<int, 4, 5, 6>;
using Wec = Vec::concat<Uec>;

template <class T>
std::string type_name() {
    return boost::core::demangle(typeid(T).name());
}

int main() {
    std::cout << type_name<Wec>() << "\n";
}
