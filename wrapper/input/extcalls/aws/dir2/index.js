// Imports the Google Cloud client library
const {Translate} = require('@google-cloud/translate');
const textToSpeech = require('@google-cloud/text-to-speech');
const fs = require('fs');
// Creates a client
var AWS=require('aws-sdk');

//entry textInput
//split inputLanguage

var language = inputLanguage;
var content = textInput;
console.log(content)
var apiKey = fs.readFileSync("apikey.txt","utf-8");
//translate if necessary
if(language != "en"){
  const translate = new Translate({
   projectId: 'csbws2223',
   key: apiKey
  });
  const target = language;
  const [translation] = await translate.translate(content, target);
  content = translation;
}
//Construct the request for TTS
const request = {
  input: {text: content},
  // Select the language and SSML voice gender (optional)
  voice: {languageCode: language, ssmlGender: 'NEUTRAL'},
  // select the type of audio encoding
  audioConfig: {audioEncoding: 'MP3'},
};

// Performs the text-to-speech request
const client = new textToSpeech.TextToSpeechClient({
 projectId: 'csbws2223',
 key: apiKey
});

const [response] = await client.synthesizeSpeech(request);
return extTime;