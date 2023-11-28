const fs = require('fs')
const ini = require('ini')
const url = require('url')
//split authFile
//get file from bucket 
var s3 = new AWS.S3();
var params = {Bucket: 'splitVarBucket', Key: authFile} //,Key:Key.csv;
var s3file = s3.getObject(params);
s3.getObject(params, function(err, data) {
  if (err) console.log(err, err.stack); // an error occurred
  else     content = data.Body.toString('ascii'); // successful response
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
