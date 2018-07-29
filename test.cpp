#include <type_traits>

#include "suffix128.hpp"

#define GLUE(lhs, mid, rhs) lhs ## mid ## rhs
#define WITH_SUFFIX(lhs, rhs) GLUE(lhs, _, rhs)

template <typename T, typename U>
struct Wrapper {
  static_assert(std::is_same<T, U>::value, "Type not the same");
};

template struct Wrapper<TYPE, decltype(WITH_SUFFIX(DIGITS, SUFFIX))>;
constexpr decltype(WITH_SUFFIX(DIGITS, SUFFIX)) value =
    WITH_SUFFIX(DIGITS, SUFFIX);
// static_assert(std::is_same<TYPE, decltype(WITH_SUFFIX(DIGITS, SUFFIX))>::value,
//               Wrapper<TYPE, decltype(WITH_SUFFIX(DIGITS, SUFFIX))>::message);
// TODO: static_assert for equality
