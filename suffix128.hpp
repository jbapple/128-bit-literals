constexpr unsigned __int128 CharValue(char c) {
  if (c >= '0' && c <= '9') {
    return c - '0';
  } else if (c >= 'a' && c <= 'f') {
    return 10 + (c - 'a');
  }
  // c >= 'A' && c <= 'F'
  return 10 + (c - 'A');
}

template<int BASE>
constexpr bool ValidateChar(char c) {
  if (BASE <= 10) {
    return c >= '0' && c <= ('0' + (BASE - 1));
  }
  return ((c >= '0') && (c <= '9')) || ((c >= 'a') && (c <= 'f')) ||
         ((c >= 'A') && (c <= 'F'));
}

template<int BASE, char... CS>
constexpr bool ValidateU128() {
  char cs[] = {CS...};
  unsigned __int128 accumulate = 0;
  for (decltype(sizeof...(CS)) i = 0; i < sizeof...(CS); ++i) {
    if (cs[i] == '\'') continue;
    if (!ValidateChar<BASE>(cs[i])) return false;
    constexpr unsigned __int128 MAX128 = ~static_cast<unsigned __int128>(0);
    if (accumulate > MAX128 / BASE) return false;
    accumulate *= BASE;
    unsigned __int128 cval = CharValue(cs[i]);
    if (MAX128 - cval < accumulate) return false;
    accumulate += cval;
  }
  return true;
}

template <int BASE, char... CS>
constexpr unsigned __int128 MakeU128() {
  char cs[] = {CS...};
  unsigned __int128 result = 0;
  for (decltype(sizeof...(CS)) i = 0; i < sizeof...(CS); ++i) {
    if (cs[i] == '\'') continue;
    result *= BASE;
    result += CharValue(cs[i]);
  }
  return result;
}

template<char... CS>
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

template <char... CS>
constexpr unsigned __int128 operator""_u128() {
  static_assert(StaticU128<CS...>::IS_VALID,
                "Invalid characters or number too large");
  return StaticU128<CS...>::PAYLOAD;
}

template <char... CS>
struct Static128 {
  static constexpr bool IS_VALID =
      ValidateU128<10, CS...>() && (MakeU128<10, CS...>() < (1_u128 << 127));
  static constexpr __int128 PAYLOAD =
      static_cast<__int128>(MakeU128<10, CS...>());
};

template <char... CS>
struct Static128<'0', 'x', CS...> {
  static constexpr bool IS_VALID =
      ValidateU128<16, CS...>() && (MakeU128<16, CS...>() < (1_u128 << 127));
  static constexpr __int128 PAYLOAD =
      static_cast<__int128>(MakeU128<16, CS...>());
};

template <char... CS>
struct Static128<'0', 'X', CS...> {
  static constexpr bool IS_VALID =
      ValidateU128<16, CS...>() && (MakeU128<16, CS...>() < (1_u128 << 127));
  static constexpr __int128 PAYLOAD =
      static_cast<__int128>(MakeU128<16, CS...>());
};

template <char... CS>
struct Static128<'0', 'b', CS...> {
  static constexpr bool IS_VALID =
      ValidateU128<2, CS...>() && (MakeU128<2, CS...>() < (1_u128 << 127));
  static constexpr __int128 PAYLOAD =
      static_cast<__int128>(MakeU128<2, CS...>());
};

template <char... CS>
struct Static128<'0', 'B', CS...> {
  static constexpr bool IS_VALID =
      ValidateU128<2, CS...>() && (MakeU128<2, CS...>() < (1_u128 << 127));
  static constexpr __int128 PAYLOAD =
      static_cast<__int128>(MakeU128<2, CS...>());
};

template <char... CS>
struct Static128<'0', CS...> {
  static constexpr bool IS_VALID =
      ValidateU128<8, CS...>() && (MakeU128<8, CS...>() < (1_u128 << 127));
  static constexpr __int128 PAYLOAD =
      static_cast<__int128>(MakeU128<8, CS...>());
};

template <char... CS>
constexpr __int128 operator""_128() {
  static_assert(Static128<CS...>::IS_VALID,
                "Invalid characters or number too large");
  return Static128<CS...>::PAYLOAD;
}
