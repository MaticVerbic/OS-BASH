#!/bin/bash

[ ! -d shramba ]  && mkdir shramba
[ ! -d shramba/.conf ] && mkdir shramba/.conf
[ -f test ] && touch test2 || touch test
cp -f test temp || cp -f test2 temp
mv test temp shramba/.conf

