#!/bin/bash

# To run: ./test.sh compiler1 compiler2 compiler3 ...

# TODO: distinguish errors from warnings?

set -o pipefail

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
    OUTPUT="$(mktemp)"
    if [[ "${STANDARD}" -lt 14 ]]; then
        DIGITS="$(echo ${DIGITS} | tr -d "'")"
    fi
    set +e
    ${CXX} -c -std=c++${STANDARD} -Werror -W -Wall -Wextra -Wno-unused-const-variable \
           -DTYPE="${TYPE}" -DDIGITS=${DIGITS} -DSUFFIX=${SUFFIX} test.cpp &>"${OUTPUT}"
    ACTUAL=$?
    if AsExpected ${EXPECTED} ${ACTUAL}; then
        printf "TESTING%20s: %s\n" "${NAME}" OK
        rm "${OUTPUT}"
        set -e
    else
        IO="$(cat ${OUTPUT})"
        rm "${OUTPUT}"
        printf "TESTING%16s: %s\n%s\n" "${NAME}" NOTOK "${IO}"
        set -e
        return 1
    fi
}

function SmokeTestCompiler {
    CXX="$1"
    STANDARD="$2"
    EMPTY="$(mktemp)"
    if ! "${CXX}" -c -std=c++${STANDARD} "${EMPTY}" &>/dev/null; then
        rm "${EMPTY}"
        return 1
    fi
}

for CXX in "$@"; do
    for STANDARD in 11 14; do
        echo "${CXX} ${STANDARD}"
        if SmokeTestCompiler "${CXX}" ${STANDARD}; then
            set -e
            Expect uHex PASS "${CXX}" "${STANDARD}" "unsigned __int128" 0x12 u128
            Expect uDecimal PASS "${CXX}" "${STANDARD}" "unsigned __int128" 12 u128
            Expect Hex PASS "${CXX}" "${STANDARD}" __int128 0x12 128
            Expect Decimal PASS "${CXX}" "${STANDARD}" __int128 12 128

            Expect uHexOverflow FAIL "${CXX}" "${STANDARD}" "unsigned __int128" \
                   "0x1'0000'0000'0000'0000'0000'0000'0000'0000" u128
            Expect uHexNoOverflow PASS "${CXX}" "${STANDARD}" "unsigned __int128" \
                   "0xffff'ffff'ffff'ffff'ffff'ffff'ffff'ffff" u128
            Expect uBinOverflow FAIL "${CXX}" "${STANDARD}" "unsigned __int128" \
                   "0b1'0000'0000'0000'0000'0000'0000'0000'0000'0000'0000'0000'0000'0000'0000'0000'0000'0000'0000'0000'0000'0000'0000'0000'0000'0000'0000'0000'0000'0000'0000'0000'0000" u128
            Expect uBinNoOverflow PASS "${CXX}" "${STANDARD}" "unsigned __int128" \
                   "0b1111'1111'1111'1111'1111'1111'1111'1111'1111'1111'1111'1111'1111'1111'1111'1111'1111'1111'1111'1111'1111'1111'1111'1111'1111'1111'1111'1111'1111'1111'1111'1111" u128
            Expect uOctOverflow FAIL "${CXX}" "${STANDARD}" "unsigned __int128" \
                   "0400'0000'0000'0000'0000'0000'0000'0000'0000'0000'0000" u128
            Expect uOctNoOverflow PASS "${CXX}" "${STANDARD}" "unsigned __int128" \
                   "0377'7777'7777'7777'7777'7777'7777'7777'7777'7777'7777" u128
            Expect uDecOverflow FAIL "${CXX}" "${STANDARD}" "unsigned __int128" \
                   "340282366920938463463374607431768211456" u128
            Expect uDecNoOverflow PASS "${CXX}" "${STANDARD}" "unsigned __int128" \
                   "340282366920938463463374607431768211455" u128

            Expect HexOverflow FAIL "${CXX}" "${STANDARD}" __int128 \
                   "0x8000'0000'0000'0000'0000'0000'0000'0000" 128
            Expect HexNoOverflow PASS "${CXX}" "${STANDARD}" __int128 \
                   "0x0fff'ffff'ffff'ffff'ffff'ffff'ffff'ffff" 128
            Expect BinOverflow FAIL "${CXX}" "${STANDARD}" __int128 \
                   "0b1000'0000'0000'0000'0000'0000'0000'0000'0000'0000'0000'0000'0000'0000'0000'0000'0000'0000'0000'0000'0000'0000'0000'0000'0000'0000'0000'0000'0000'0000'0000'0000" 128
            Expect BinNoOverflow PASS "${CXX}" "${STANDARD}" __int128 \
                   "0b0111'1111'1111'1111'1111'1111'1111'1111'1111'1111'1111'1111'1111'1111'1111'1111'1111'1111'1111'1111'1111'1111'1111'1111'1111'1111'1111'1111'1111'1111'1111'1111" 128
            Expect OctOverflow FAIL "${CXX}" "${STANDARD}" __int128 \
                   "0200'0000'0000'0000'0000'0000'0000'0000'0000'0000'0000" 128
            Expect OctNoOverflow PASS "${CXX}" "${STANDARD}" __int128 \
                   "0177'7777'7777'7777'7777'7777'7777'7777'7777'7777'7777" 128
            Expect DecOverflow FAIL "${CXX}" "${STANDARD}" __int128 \
                   "170141183460469231731687303715884105728" 128
            Expect DecNoOverflow PASS "${CXX}" "${STANDARD}" __int128 \
                   "170141183460469231731687303715884105727" 128

            Expect NegHexOverflow FAIL "${CXX}" "${STANDARD}" __int128 \
                   "-0x8000'0000'0000'0000'0000'0000'0000'0000" 128
            Expect NegHexNoOverflow PASS "${CXX}" "${STANDARD}" __int128 \
                   "-0x0fff'ffff'ffff'ffff'ffff'ffff'ffff'ffff" 128
            Expect NegBinOverflow FAIL "${CXX}" "${STANDARD}" __int128 \
                   "-0b1000'0000'0000'0000'0000'0000'0000'0000'0000'0000'0000'0000'0000'0000'0000'0000'0000'0000'0000'0000'0000'0000'0000'0000'0000'0000'0000'0000'0000'0000'0000'0000" 128
            Expect NegBinNoOverflow PASS "${CXX}" "${STANDARD}" __int128 \
                   "-0b0111'1111'1111'1111'1111'1111'1111'1111'1111'1111'1111'1111'1111'1111'1111'1111'1111'1111'1111'1111'1111'1111'1111'1111'1111'1111'1111'1111'1111'1111'1111'1111" 128
            Expect NegOctOverflow FAIL "${CXX}" "${STANDARD}" __int128 \
                   "-0200'0000'0000'0000'0000'0000'0000'0000'0000'0000'0000" 128
            Expect NegOctNoOverflow PASS "${CXX}" "${STANDARD}" __int128 \
                   "-0177'7777'7777'7777'7777'7777'7777'7777'7777'7777'7777" 128
            Expect NegDecOverflow FAIL "${CXX}" "${STANDARD}" __int128 \
                   "-170141183460469231731687303715884105728" 128
            Expect NegDecNoOverflow PASS "${CXX}" "${STANDARD}" __int128 \
                   "-170141183460469231731687303715884105727" 128

            Expect HexLowerLower PASS "${CXX}" "${STANDARD}" "unsigned __int128" \
                   "0xf" u128
            Expect HexUpperLower PASS "${CXX}" "${STANDARD}" "unsigned __int128" \
                   "0Xf" u128
            Expect HexLowerUpper PASS "${CXX}" "${STANDARD}" "unsigned __int128" \
                   "0xF" u128
            Expect HexUpperUpper PASS "${CXX}" "${STANDARD}" "unsigned __int128" \
                   "0XF" u128
            Expect BinLower PASS "${CXX}" "${STANDARD}" "unsigned __int128" \
                   "0b1" u128
            Expect BinUpper PASS "${CXX}" "${STANDARD}" "unsigned __int128" \
                   "0B1" u128

            Expect InvalidBase FAIL "${CXX}" "${STANDARD}" "unsigned __int128" \
                   "0zF" u128
            Expect MissingDigits FAIL "${CXX}" "${STANDARD}" "unsigned __int128" \
                   "0x" u128
            Expect InvalidOctalx FAIL "${CXX}" "${STANDARD}" "unsigned __int128" \
                   "00x0" u128
            Expect InvalidHexG FAIL "${CXX}" "${STANDARD}" "unsigned __int128" \
                   "0xg" u128
            Expect InvalidOctal8 FAIL "${CXX}" "${STANDARD}" "unsigned __int128" \
                   "0080" u128
            Expect InvalidBin2 FAIL "${CXX}" "${STANDARD}" "unsigned __int128" \
                   "0b2" u128
            set +e
        fi
    done
done
