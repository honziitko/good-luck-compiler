#include <string>
#include <iostream>
#include <boost/core/demangle.hpp>
#include "include/utils.h"

using Vec = glc::utils::vector<int, 20, 30, 40, 50>;

template <class T>
std::string type_name() {
    return boost::core::demangle(typeid(T).name());
}

template <class Vec>
struct Idk {};

template <class T, T... xs>
struct Idk<glc::utils::vector<T, xs...> > {
    static std::string f() {
        return type_name<T>();
    }
};

int main() {
    std::cout << Idk<Vec>::f() << "\n";
    std::cout << glc::utils::vector_at<Vec, 0>::value << "\n";
    std::cout << glc::utils::vector_at<Vec, 2>::value << "\n";
}
