#include <cstddef>

namespace glc {
    namespace utils {
        template <class Vec, size_t i>
        struct vector_at_impl {};

        template <class T, T... vals>
        struct vector {
            template <size_t i>
            static constexpr T at() {
                return vector_at_impl<vector, i>::value;
            }
        };

        template <class T, T x, T... rest>
        struct vector_at_impl<vector<T, x, rest...>, 0>  {
            static constexpr T value = x;
        };

        template <class T, size_t i, T _, T... rest>
        struct vector_at_impl<vector<T, _, rest...>, i> {
            static constexpr T value = vector_at_impl<vector<T, rest...>, i-1>::value;
        };
    }
}
