#pragma once

#include <cstddef>
#include <type_traits>

namespace glc {
    namespace utils {
        template <bool cond, class T = void>
        using constrain = typename std::enable_if<cond, T>::type;

        template <class Vec, size_t i>
        struct vector_at_impl {};

        template <class Vec, size_t n, class Enable = void>
        struct vector_take_impl {};

        template <class Vec, size_t n, class Enable = void>
        struct vector_drop_impl {};

        template <class V, class U>
        struct vector_concat_impl {};

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
            template <size_t n>
            using drop = typename vector_drop_impl<vector, n>::type;

            template <class U>
            using concat = typename vector_concat_impl<vector, U>::type;

            template <T x, size_t i>
            using set = typename take<i>::template push_back<x>::template concat<drop<i+1>>;
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
        struct vector_take_impl<vector<T, x, xs...>, n, constrain<(n > 0)> > {
            using tail = typename vector_take_impl<vector<T, xs...>, n-1>::type;
            using type = typename tail::template push_front<x>;
        };

        template <class T, T... xs>
        struct vector_drop_impl<vector<T, xs...>, 0> {
            using type = vector<T, xs...>;
        };

        template <class T, size_t n, T x, T... xs>
        struct vector_drop_impl<vector<T, x, xs...>, n, constrain<(n > 0)> > {
            using tail = vector<T, xs...>;
            using type = typename vector_drop_impl<tail, n-1>::type;
        };

        template <class T, T... xs, T... ys>
        struct vector_concat_impl<vector<T, xs...>, vector<T, ys...> > {
            using type = vector<T, xs..., ys...>;
        };

        template <bool flag, class T, class U>
        struct ternary_impl {};
        template <class T, class U>
        struct ternary_impl<true, T, U> { using type = T; };
        template <class T, class U>
        struct ternary_impl<false, T, U> { using type = U; };
        template <bool flag, class T, class U>
        using ternary = typename ternary_impl<flag, T, U>::type;
    }
}
