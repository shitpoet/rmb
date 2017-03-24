let fs = require('fs')
let ws = require('ws')
let name = 'rmb'
let code = ws.read(name+'.ws').code
fs.writeFileSync(name+'.js', code)
