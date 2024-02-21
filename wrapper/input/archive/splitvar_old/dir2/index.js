const fs = require('fs')
const ini = require('ini')
const url = require('url')
//split authFile
//split urlToAddAuth
//get file from bucket 

var content = fs.readFileSync(authFile,"utf-8");

const authConf = ini.parse(content)
if (!(authConf.client.user && authConf.client.password)) throw new Error('Malformed Auth File')
const urlObject = new URL(urlToAddAuth)
if (!urlObject.username || !urlObject.password) {
  urlObject.username = authConf.client.user
  urlObject.password = authConf.client.password
  urlToAddAuth = url.format(urlObject)
}
console.log(urlToAddAuth)
return extTime;