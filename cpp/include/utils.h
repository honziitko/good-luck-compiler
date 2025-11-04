#include <cstddef>

namespace glc {
    namespace utils {
        template <class T, T... vals>
        struct vector {};

        template <class Vec, size_t i>
        struct vector_at {};

        template <class T, T x, T... rest>
        struct vector_at<vector<T, x, rest...>, 0>  {
            static constexpr T value = x;
        };

        template <class T, size_t i, T _, T... rest>
        struct vector_at<vector<T, _, rest...>, i> {
            static constexpr T value = vector_at<vector<T, rest...>, i-1>::value;
        };
    }
}
