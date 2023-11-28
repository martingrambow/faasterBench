
// Imports the Google Cloud client library
const {Translate} = require('@google-cloud/translate').v2;

// Creates a client
var AWS=require('aws-sdk');
var polly=new AWS.Polly({region: 'europe-west-1'});

var content;
var words;
//get file from bucket 
var s3 = new AWS.S3();
var params = {Bucket: 'extCallBucket', Key: 'test'} //,Key:Key.csv;
var s3file = s3.getObject(params);
s3.getObject(params, function(err, data) {
  if (err) console.log(err, err.stack); // an error occurred
  else     content = data.Body.toString('ascii'); // successful response
});

var voice = "Marlene";
//var voice ="Joanna";
if(voice!= "Joanna"){
  const translate = new Translate();
  const text = content;
  const target = entry;

  let translations = translate.translate(text, target);
  words = translations;
}



params = {
OutputFormat: "mp3", 
SampleRate: "8000", 
Text: words, 
TextType: "text", 
VoiceId: voice
};
polly.synthesizeSpeech(params, function(err, data) {
if (err) console.log(err, err.stack); // an error occurred
else  {
  var fs=require('fs');
  var output= path.join(app.getPath('appData'), "speech_"+entry+".mp3");
  var wstream = fs.createWriteStream(output);
  wstream.write(data.AudioStream);
  wstream.end();
  shell.openPath(output);	
}   
});

