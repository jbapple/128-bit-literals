# 128-bit literals in C++14 #

[g++](http://web.archive.org/web/20170109003102/https://gcc.gnu.org/onlinedocs/gcc/_005f_005fint128.html)
and clang++ support the 128-bit integer types `__int128` and `unsigned
__int128`, but they do not support [integer
literals](http://en.cppreference.com/w/cpp/language/integer_literal)
(`77`, `0644`, `99uLL`, `0b00001101`, `0xa'bad'1dea`) that are 128
bits long on x86-64:

```
$ clang++ -c -std=c++14 fail.cpp || echo "sad trombone."
fail.cpp:1:23: error: integer literal is too large to be represented in any integer type
unsigned __int128 x = 0xf0123456789abcdef;
                      ^
1 error generated.
sad trombone.
```

suffix128.hpp makes this work, as long as you append a particular
suffix, just like the standard C++ suffixes `u`, `Ul`, `uLL`, and so
on:

```
$ diff -u fail.cpp succeed.cpp
--- fail.cpp    2017-01-08 16:37:51.129264501 -0800
+++ succeed.cpp 2017-01-08 16:42:02.717264478 -0800
@@ -1 +1,2 @@
-unsigned __int128 x = 0xf0123456789abcdef;
+#include "suffix128.hpp"
+unsigned __int128 x = 0xf0123456789abcdef_u128;
```
```
$ clang++ -c -std=c++14 succeed.cpp && echo "Wheee!"
Wheee!
```

Only one header needs to be included: suffix128.hpp.

suffix128.hpp works with constexpr, non-type template parameters,
enumerator initializers, C++14's single-quote digit separator, and
signed numbers:

```
constexpr __int128 x = -0x0123456789abcdef'0'12'345'6789'abcde'f_128;
```
```
template<__int128> struct Foo {};
Foo<0x0123456789abcdef'0123456789abcdef_128> bar;
```
```
enum Bar { BAZ = 0x0123456789abcdef'0123456789abcdef_128 };
```

Just like for 64-bit numbers, the minimum value cannot be written as a
128-bit literal. However, the minimu 64-bit signed value can now be
written as a 128-bit literal and it will be converted properly,
according to 4.7, Integral conversions: "If the destination type is
signed, the value is unchanged if it can be represented in the
destination type".

```
static_assert(-0x8000'0000'0000'0000_128 == LLONG_MIN, "Literal min");
```