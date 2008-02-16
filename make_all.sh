#!/bin/sh
rm iComic.zip
mkdir ./1.1.1
mkdir ./1.1.3
make clean
make
cp -pr iComic.app 1.1.1/.
make -f Make.mobile clean
make -f Make.mobile
cp -pr ./iComic.app 1.1.3/.
zip -r iComic.zip 1.1.1 1.1.3 ReadMe.txt
rm -r 1.1.1
rm -r 1.1.3
