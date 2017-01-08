#!/bin/bash

#clang-3.8 -stdlib=libc++

# TODO: distinguish errors from warnings?

function AsExpected() {
    [[ ($1 == "PASS" && $2 == 0) || ($1 == "FAIL" && $2 != 0) ]]
}

function Expect() {
    NAME=$1
    shift; EXPECTED=$1
    shift; CXX=$1
    shift; STANDARD=$1
    shift; TYPE=$1
    shift; DIGITS=$1
    shift; SUFFIX=$1
    OUTPUT=$(mktemp)
    ${CXX} -c -std=c++${STANDARD} -Werror -W -Wall -Wextra -DTYPE="${TYPE}" \
           -DDIGITS=${DIGITS} -DSUFFIX=${SUFFIX} test.cpp &>"${OUTPUT}"
    ACTUAL=$?
    if AsExpected ${EXPECTED} ${ACTUAL}; then
        printf "TESTING%20s: %s\n" "${NAME}" OK
    else
        IO="$(cat ${OUTPUT})"
        rm "${OUTPUT}"
        printf "TESTING%16s: %s\n%s\n" "${NAME}" NOTOK "${IO}"
        return 1
    fi
}

Expect uHex PASS "clang-3.8 -stdlib=libc++" 14 "unsigned __int128" 0x12 u128
Expect uDecimal PASS "clang-3.8 -stdlib=libc++" 14 "unsigned __int128" 12 u128
Expect Hex PASS "clang-3.8 -stdlib=libc++" 14 __int128 0x12 128
Expect Decimal PASS "clang-3.8 -stdlib=libc++" 14 __int128 12 128

Expect uHexOverflow FAIL "clang-3.8 -stdlib=libc++" 14 "unsigned __int128" \
       "0x1'0000'0000'0000'0000'0000'0000'0000'0000" u128
Expect uHexNoOverflow PASS "clang-3.8 -stdlib=libc++" 14 "unsigned __int128" \
       "0xffff'ffff'ffff'ffff'ffff'ffff'ffff'ffff" u128
Expect uBinOverflow FAIL "clang-3.8 -stdlib=libc++" 14 "unsigned __int128" \
       "0b1'0000'0000'0000'0000'0000'0000'0000'0000'0000'0000'0000'0000'0000'0000'0000'0000'0000'0000'0000'0000'0000'0000'0000'0000'0000'0000'0000'0000'0000'0000'0000'0000" u128
Expect uBinNoOverflow PASS "clang-3.8 -stdlib=libc++" 14 "unsigned __int128" \
       "0b1111'1111'1111'1111'1111'1111'1111'1111'1111'1111'1111'1111'1111'1111'1111'1111'1111'1111'1111'1111'1111'1111'1111'1111'1111'1111'1111'1111'1111'1111'1111'1111" u128
Expect uOctOverflow FAIL "clang-3.8 -stdlib=libc++" 14 "unsigned __int128" \
       "0400'0000'0000'0000'0000'0000'0000'0000'0000'0000'0000" u128
Expect uOctNoOverflow PASS "clang-3.8 -stdlib=libc++" 14 "unsigned __int128" \
       "0377'7777'7777'7777'7777'7777'7777'7777'7777'7777'7777" u128
Expect uDecOverflow FAIL "clang-3.8 -stdlib=libc++" 14 "unsigned __int128" \
       "340282366920938463463374607431768211456" u128
Expect uDecNoOverflow PASS "clang-3.8 -stdlib=libc++" 14 "unsigned __int128" \
       "340282366920938463463374607431768211455" u128

Expect HexOverflow FAIL "clang-3.8 -stdlib=libc++" 14 __int128 \
       "0x8000'0000'0000'0000'0000'0000'0000'0000" 128
Expect HexNoOverflow PASS "clang-3.8 -stdlib=libc++" 14 __int128 \
       "0x0fff'ffff'ffff'ffff'ffff'ffff'ffff'ffff" 128
Expect BinOverflow FAIL "clang-3.8 -stdlib=libc++" 14 __int128 \
       "0b1000'0000'0000'0000'0000'0000'0000'0000'0000'0000'0000'0000'0000'0000'0000'0000'0000'0000'0000'0000'0000'0000'0000'0000'0000'0000'0000'0000'0000'0000'0000'0000" 128
Expect BinNoOverflow PASS "clang-3.8 -stdlib=libc++" 14 __int128 \
       "0b0111'1111'1111'1111'1111'1111'1111'1111'1111'1111'1111'1111'1111'1111'1111'1111'1111'1111'1111'1111'1111'1111'1111'1111'1111'1111'1111'1111'1111'1111'1111'1111" 128
Expect OctOverflow FAIL "clang-3.8 -stdlib=libc++" 14 __int128 \
       "0200'0000'0000'0000'0000'0000'0000'0000'0000'0000'0000" 128
Expect OctNoOverflow PASS "clang-3.8 -stdlib=libc++" 14 __int128 \
       "0177'7777'7777'7777'7777'7777'7777'7777'7777'7777'7777" 128
Expect DecOverflow FAIL "clang-3.8 -stdlib=libc++" 14 __int128 \
       "170141183460469231731687303715884105728" 128
Expect DecNoOverflow PASS "clang-3.8 -stdlib=libc++" 14 __int128 \
       "170141183460469231731687303715884105727" 128

Expect NegHexOverflow FAIL "clang-3.8 -stdlib=libc++" 14 __int128 \
       "-0x8000'0000'0000'0000'0000'0000'0000'0000" 128
Expect NegHexNoOverflow PASS "clang-3.8 -stdlib=libc++" 14 __int128 \
       "-0x0fff'ffff'ffff'ffff'ffff'ffff'ffff'ffff" 128
Expect NegBinOverflow FAIL "clang-3.8 -stdlib=libc++" 14 __int128 \
       "-0b1000'0000'0000'0000'0000'0000'0000'0000'0000'0000'0000'0000'0000'0000'0000'0000'0000'0000'0000'0000'0000'0000'0000'0000'0000'0000'0000'0000'0000'0000'0000'0000" 128
Expect NegBinNoOverflow PASS "clang-3.8 -stdlib=libc++" 14 __int128 \
       "-0b0111'1111'1111'1111'1111'1111'1111'1111'1111'1111'1111'1111'1111'1111'1111'1111'1111'1111'1111'1111'1111'1111'1111'1111'1111'1111'1111'1111'1111'1111'1111'1111" 128
Expect NegOctOverflow FAIL "clang-3.8 -stdlib=libc++" 14 __int128 \
       "-0200'0000'0000'0000'0000'0000'0000'0000'0000'0000'0000" 128
Expect NegOctNoOverflow PASS "clang-3.8 -stdlib=libc++" 14 __int128 \
       "-0177'7777'7777'7777'7777'7777'7777'7777'7777'7777'7777" 128
Expect NegDecOverflow FAIL "clang-3.8 -stdlib=libc++" 14 __int128 \
       "-170141183460469231731687303715884105728" 128
Expect NegDecNoOverflow PASS "clang-3.8 -stdlib=libc++" 14 __int128 \
       "-170141183460469231731687303715884105727" 128

Expect HexLowerLower PASS "clang-3.8 -stdlib=libc++" 14 "unsigned __int128" \
       "0xf" u128
Expect HexUpperLower PASS "clang-3.8 -stdlib=libc++" 14 "unsigned __int128" \
       "0Xf" u128
Expect HexLowerUpper PASS "clang-3.8 -stdlib=libc++" 14 "unsigned __int128" \
       "0xF" u128
Expect HexUpperUpper PASS "clang-3.8 -stdlib=libc++" 14 "unsigned __int128" \
       "0XF" u128
Expect BinLower PASS "clang-3.8 -stdlib=libc++" 14 "unsigned __int128" \
       "0b1" u128
Expect BinUpper PASS "clang-3.8 -stdlib=libc++" 14 "unsigned __int128" \
       "0B1" u128

Expect InvalidBase FAIL "clang-3.8 -stdlib=libc++" 14 "unsigned __int128" \
       "0zF" u128
Expect MissingDigits FAIL "clang-3.8 -stdlib=libc++" 14 "unsigned __int128" \
       "0x" u128
Expect InvalidOctalx FAIL "clang-3.8 -stdlib=libc++" 14 "unsigned __int128" \
       "00x0" u128
Expect InvalidHexG FAIL "clang-3.8 -stdlib=libc++" 14 "unsigned __int128" \
       "0xg" u128
Expect InvalidOctal8 FAIL "clang-3.8 -stdlib=libc++" 14 "unsigned __int128" \
       "0080" u128
Expect InvalidBin2 FAIL "clang-3.8 -stdlib=libc++" 14 "unsigned __int128" \
       "0b2" u128
