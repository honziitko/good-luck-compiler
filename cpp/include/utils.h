#include <cstddef>
#include <type_traits>

namespace glc {
    namespace utils {
        template <class Vec, size_t i>
        struct vector_at_impl {};

        template <class Vec, size_t n, class Enable = void>
        struct vector_take_impl {};

        template <class T, T... vals>
        struct vector {
            template <size_t i>
            static constexpr T at() {
                return vector_at_impl<vector, i>::value;
            }

            template <T x>
            using push_back = vector<T, vals..., x>;
            template <T x>
            using push_front = vector<T, x, vals...>;

            template <size_t n>
            using take = typename vector_take_impl<vector, n>::type;
        };

        template <class T, T x, T... rest>
        struct vector_at_impl<vector<T, x, rest...>, 0>  {
            static constexpr T value = x;
        };

        template <class T, size_t i, T _, T... rest>
        struct vector_at_impl<vector<T, _, rest...>, i> {
            static constexpr T value = vector_at_impl<vector<T, rest...>, i-1>::value;
        };

        template <class T, T... xs>
        struct vector_take_impl<vector<T, xs...>, 0> {
            using type = vector<T>;
        };

        template <class T, size_t n, T x, T... xs>
        struct vector_take_impl<vector<T, x, xs...>, n, typename std::enable_if_t<(n > 0)> > {
            using tail = typename vector_take_impl<vector<T, xs...>, n-1>::type;
            using type = typename tail::template push_front<x>;
        };
    }
}
