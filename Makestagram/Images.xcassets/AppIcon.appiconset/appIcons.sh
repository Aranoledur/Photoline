#!/bin/bash
f=$(pwd)

sips --resampleWidth 512 "${f}/${1}" --out "${f}/iTunesArtwork.png"
sips --resampleWidth 1024 "${f}/${1}" --out "${f}/iTunesArtwork@2x.png"
sips --resampleWidth 120 "${f}/${1}" --out "${f}/Icon_120.png"
sips --resampleWidth 180 "${f}/${1}" --out "${f}/Icon_180.png"
sips --resampleWidth 80 "${f}/${1}" --out "${f}/Icon_80.png"
sips --resampleWidth 60 "${f}/${1}" --out "${f}/Icon_60.png"
sips --resampleWidth 87 "${f}/${1}" --out "${f}/Icon_87.png"
sips --resampleWidth 58 "${f}/${1}" --out "${f}/Icon_58.png"
sips --resampleWidth 29 "${f}/${1}" --out "${f}/Icon_29.png"
sips --resampleWidth 76 "${f}/${1}" --out "${f}/Icon_76.png"
sips --resampleWidth 167 "${f}/${1}" --out "${f}/Icon_167.png"
sips --resampleWidth 152 "${f}/${1}" --out "${f}/Icon_152.png"
sips --resampleWidth 40 "${f}/${1}" --out "${f}/Icon_40.png"
