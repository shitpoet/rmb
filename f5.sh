#!/bin/bash
echo '-------------------------------------------------'
node compile.js
#uglifyjs --compress --mangle -- gest.js > gest.min.js
#node --harmony --debug=6948 --expose_debug_as=v8debug test.js
#node --harmony --harmony_destructuring --debug --expose_debug_as=v8debug include.js
#node --harmony --harmony_destructuring --expose_debug_as=v8debug test.js
#node --harmony --harmony_destructuring_assignment --expose_debug_as=v8debug test.js
#echo '-------------------------------------------------'
#node --harmony_destructuring --strong_mode m2.js
#lessc css/style.less css/style.css
#midori -e Reload
#cat style.css
#xdotool search --name chromium windowactivate --sync
#xdotool search --name --onlyvisible chromium key --clearmodifiers CTRL+R
inotifywait -qq -e modify $0 *.ws
. $0
