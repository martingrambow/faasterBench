
// Imports the Google Cloud client library
const {Translate} = require('@google-cloud/translate').v2;
const fs = require('fs');
var apiKey = fs.readFileSync("apikey.txt","utf-8");
const translate = new Translate({
  projectId: 'csbws2223',
  key: apiKey
});

const textToSpeech = require('@google-cloud/text-to-speech');

// Creates a client

//entry textInput
//split inputLanguage

var language = inputLanguage;
var content = textInput;
console.log(content)

//translate if necessary
extStart0 = Date.now();
if(language != "en"){
  
  const target = language;
  const [translation] = await translate.translate(content, target);
  content = translation;
}
extStop0 = Date.now();
extTime.push(extStop0 - extStart0);
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
console.log("Got an audio response from 1");
return extTime;