#!/bin/bash
echo '-------------------------------------------------'
node compile.js
inotifywait -qq -e modify $0 *.ws
. $0
