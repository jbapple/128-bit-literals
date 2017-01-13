# 128-bit literals in C++11 and C++14 #

In C++, you can store 8-bit integers, 16-bit integers, 32-bit integers, and 64-bit integers:

```
int8_t alice;
int64_t bob;
```

GCC and Clang even have 128-bit integers:

```
__int128 carol;
```

You can ***store*** 128-bit integers, but [you aren't allowed to ***write*** 128-bit integers](http://web.archive.org/web/20170109003102/https://gcc.gnu.org/onlinedocs/gcc/_005f_005fint128.html):

```
__int128 dave = 18446744073709551616;
```

```
error: integer literal is too large to be represented in any integer type
__int128 dave = 18446744073709551616;
                ^
```

This library allows you to write 128-bit integers:

```
#include "suffix128.hpp"
__int128 emily = 18446744073709551616_128;
```

All you have to do is `#include "suffix128.hpp"` and end your integer with the suffix `_128`.

--------------

You can use the suffix `_u128` for unsigned integers:

```
unsigned __int128 frank = 123456789012345678901234567890_u128;
```

128-bit integers you write this way are constants and they can be used as template parameters or enumerator initializers.

```
enum Bar { BAZ = 0_128 };
```

You can use C++14's single-quote digit separator:

```
__int128 gloria = 1'2'3'456'7_128;
```

You can also write them in hexadecimal or octal notation:

```
__int128 hector = 0xfeed'bad'beef'2'dad_128;
__int128 imelda = 0644_128;
```

You can even write 128-bit binary literals:

```
unsigned __int128 jules = 0b00000001000001100001010000111000100100010110001101000111100100110010101001011100110110011101001111101010110101111011011101111111_u128;
```
