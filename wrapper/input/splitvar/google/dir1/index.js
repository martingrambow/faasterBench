const fs = require('fs')
const ini = require('ini')
const url = require('url')
//split authFile
const {Storage} = require('@google-cloud/storage');

const fileName = authFile;
const storage = new Storage();
const myBucket = storage.bucket('extCallBucket');
const file = myBucket.file(fileName);
file.download().then(function(data) {
  content = data[0];
});
const authConf = ini.parse(fs.readFileSync(authFile, 'utf-8'))
if (!(authConf.user && authConf.password)) throw new Error('Malformed Auth File')
const urlObject = new URL(urlToAddAuth)
if (!urlObject.username || !urlObject.password) {
  urlObject.username = authConf.user
  urlObject.password = authConf.password
  urlToAddAuth = url.format(urlObject)
}
return urlToAddAuth;
