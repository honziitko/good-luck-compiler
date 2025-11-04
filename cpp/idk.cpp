#include <string>
#include <iostream>
#include <boost/core/demangle.hpp>
#include "include/utils.h"

using Vec = glc::utils::vector<int, 55, 2, 3, 55, 5>;
using Uec = Vec::set<1, 0>;
using Wec = Uec::set<4, 3>;

template <class T>
std::string type_name() {
    return boost::core::demangle(typeid(T).name());
}

int main() {
    std::cout << type_name<Wec>() << "\n";
}
