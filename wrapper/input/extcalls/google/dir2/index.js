const textToSpeech = require('@google-cloud/text-to-speech');
// Imports the Google Cloud client library
const {Translate} = require('@google-cloud/translate').v2;

// Creates a client and sets up some required variables
const fs = require('fs')
const util =require('util')

const projectId = "csbws2223"
//entry textInput
//split inputLanguage
const language = inputLanguage;
//download the text from the cloud
var content = textInput;
//translate the text if required
if(language != "en"){
  const translate = new Translate({projectId});
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
const client = new textToSpeech.TextToSpeechClient();
const [response] = await client.synthesizeSpeech(request);
return extTime;