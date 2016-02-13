#!/bin/bash
f=$(pwd)

x=${1}
y=${x%.*}
sips --resampleWidth 300 "${f}/${1}" --out "${f}/$y@3x.png"
sips --resampleWidth 200 "${f}/${1}" --out "${f}/$y@2x.png"
sips --resampleWidth 100 "${f}/${1}" --out "${f}/$y.png"
