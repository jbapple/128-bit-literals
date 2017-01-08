# 128-bit literals in C++14 #

[g++](http://web.archive.org/web/20170109003102/https://gcc.gnu.org/onlinedocs/gcc/_005f_005fint128.html) and clang++ support the 128-bit integer types `__int128` and `unsigned __int128`, but they do not support [integer literals](http://en.cppreference.com/w/cpp/language/integer_literal)  (`77`, `0644`, `99uLL`, `0b00001101`, `0xa'bad'1dea`) that are 128 bits long on x86-64:

```
$ clang++ -c -std=c++14 fail.cpp || echo "sad trombone."
fail.cpp:1:23: error: integer literal is too large to be represented in any integer type
unsigned __int128 x = 0x10000000000000000;
                      ^
1 error generated.
sad trombone.
```

suffix128.hpp makes this work, as long as you append a particular suffix, just like the standard C++ suffixes `u`, `Ul`, `uLL`, and so on:

```
$ diff -u fail.cpp succeed.cpp
--- fail.cpp    2017-01-08 16:37:51.129264501 -0800
+++ succeed.cpp 2017-01-08 16:42:02.717264478 -0800
@@ -1 +1,2 @@
-unsigned __int128 x = 0x10000000000000000;
+#include "suffix128.hpp"
+unsigned __int128 x = 0x10000000000000000_u128;
```
```
$ clang++ -c -std=c++14 succeed.cpp && echo "Wheee!"
Wheee!
```