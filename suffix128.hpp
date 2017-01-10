#pragma once

namespace suffix128 {

constexpr unsigned __int128 CharValue(char c) {
  return (c >= '0' && c <= '9')
             ? (c - '0')
             : ((c >= 'a' && c <= 'f') ? (10 + (c - 'a')) : (10 + (c - 'A')));
}

template <int BASE>
constexpr bool ValidateChar(char c) {
  return (BASE <= 10)
             ? (c >= '0' && c <= ('0' + (BASE - 1)))
             : (((c >= '0') && (c <= '9')) || ((c >= 'a') && (c <= 'f')) ||
                ((c >= 'A') && (c <= 'F')));
}

static constexpr unsigned __int128 MAX128 = ~static_cast<unsigned __int128>(0);

template <int BASE>
constexpr bool ValidateU128Helper(unsigned __int128) {
  return true;
}

template <int BASE, char C, char... CS>
constexpr bool ValidateU128Helper(unsigned __int128 accumulate) {
  return (C == '\'') ? ValidateU128Helper<BASE, CS...>(accumulate)
                     : ((accumulate <= MAX128 / BASE) &&
                        (BASE * accumulate <= MAX128 - CharValue(C)) &&
                        ValidateU128Helper<BASE, CS...>(accumulate * BASE +
                                                        CharValue(C)));
}

template <int BASE, char... CS>
constexpr bool ValidateU128() {
  return ValidateU128Helper<BASE, CS...>(0);
}

template <int BASE>
constexpr unsigned __int128 MakeU128Helper(unsigned __int128 result) {
  return result;
}

template <int BASE, char C, char... CS>
constexpr unsigned __int128 MakeU128Helper(unsigned __int128 result) {
  return MakeU128Helper<BASE, CS...>(
      (C == '\'') ? result : (result * BASE + CharValue(C)));
}

template <int BASE, char... CS>
constexpr unsigned __int128 MakeU128() {
  return MakeU128Helper<BASE, CS...>(0);
}

template <char... CS>
struct StaticU128 {
  static constexpr bool IS_VALID = ValidateU128<10, CS...>();
  static constexpr unsigned __int128 PAYLOAD = MakeU128<10, CS...>();
};

template <char... CS>
struct StaticU128<'0', 'x', CS...> {
  static constexpr bool IS_VALID = ValidateU128<16, CS...>();
  static constexpr unsigned __int128 PAYLOAD = MakeU128<16, CS...>();
};

template <char... CS>
struct StaticU128<'0', 'X', CS...> {
  static constexpr bool IS_VALID = ValidateU128<16, CS...>();
  static constexpr unsigned __int128 PAYLOAD = MakeU128<16, CS...>();
};

template <char... CS>
struct StaticU128<'0', 'b', CS...> {
  static constexpr bool IS_VALID = ValidateU128<2, CS...>();
  static constexpr unsigned __int128 PAYLOAD = MakeU128<2, CS...>();
};

template <char... CS>
struct StaticU128<'0', 'B', CS...> {
  static constexpr bool IS_VALID = ValidateU128<2, CS...>();
  static constexpr unsigned __int128 PAYLOAD = MakeU128<2, CS...>();
};

template <char... CS>
struct StaticU128<'0', CS...> {
  static constexpr bool IS_VALID = ValidateU128<8, CS...>();
  static constexpr unsigned __int128 PAYLOAD = MakeU128<8, CS...>();
};

static constexpr unsigned __int128 SIGNED_LIMIT =
    (static_cast<unsigned __int128>(1) << 127) - 1;

template <char... CS>
struct Static128 {
  static constexpr bool IS_VALID =
      ValidateU128<10, CS...>() && (MakeU128<10, CS...>() <= SIGNED_LIMIT);
  static constexpr __int128 PAYLOAD =
      static_cast<__int128>(MakeU128<10, CS...>());
};

template <char... CS>
struct Static128<'0', 'x', CS...> {
  static constexpr bool IS_VALID =
      ValidateU128<16, CS...>() && (MakeU128<16, CS...>() <= SIGNED_LIMIT);
  static constexpr __int128 PAYLOAD =
      static_cast<__int128>(MakeU128<16, CS...>());
};

template <char... CS>
struct Static128<'0', 'X', CS...> {
  static constexpr bool IS_VALID =
      ValidateU128<16, CS...>() && (MakeU128<16, CS...>() <= SIGNED_LIMIT);
  static constexpr __int128 PAYLOAD =
      static_cast<__int128>(MakeU128<16, CS...>());
};

template <char... CS>
struct Static128<'0', 'b', CS...> {
  static constexpr bool IS_VALID =
      ValidateU128<2, CS...>() && (MakeU128<2, CS...>() <= SIGNED_LIMIT);
  static constexpr __int128 PAYLOAD =
      static_cast<__int128>(MakeU128<2, CS...>());
};

template <char... CS>
struct Static128<'0', 'B', CS...> {
  static constexpr bool IS_VALID =
      ValidateU128<2, CS...>() && (MakeU128<2, CS...>() <= SIGNED_LIMIT);
  static constexpr __int128 PAYLOAD =
      static_cast<__int128>(MakeU128<2, CS...>());
};

template <char... CS>
struct Static128<'0', CS...> {
  static constexpr bool IS_VALID =
      ValidateU128<8, CS...>() && (MakeU128<8, CS...>() <= SIGNED_LIMIT);
  static constexpr __int128 PAYLOAD =
      static_cast<__int128>(MakeU128<8, CS...>());
};

}  // namespace suffix128

template <char... CS>
constexpr unsigned __int128 operator"" _u128() {
  static_assert(suffix128::StaticU128<CS...>::IS_VALID,
                "Invalid characters or number too large");
  return suffix128::StaticU128<CS...>::PAYLOAD;
}

template <char... CS>
constexpr __int128 operator"" _128() {
  static_assert(suffix128::Static128<CS...>::IS_VALID,
                "Invalid characters or number too large");
  return suffix128::Static128<CS...>::PAYLOAD;
}
