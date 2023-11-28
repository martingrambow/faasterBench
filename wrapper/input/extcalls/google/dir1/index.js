const textToSpeech = require('@google-cloud/text-to-speech');
// Imports The Google Cloud Storage library
const {Storage} = require('@google-cloud/storage');

// Imports the Google Cloud client library
const {Translate} = require('@google-cloud/translate').v2;

// Creates a client

var content;
// Creates a client
const client = new textToSpeech.TextToSpeechClient();

const fileName = process.env.TEXTFILE;
const storage = new Storage();
const myBucket = storage.bucket('extCallBucket');
const file = myBucket.file(fileName);
var language = "en"
file.download().then(function(data) {
  content = data[0];
});
if(language != "en"){
  const translate = new Translate();
  const text = content;
  const target = language;

  let translations = translate.translate(text, target);
  content = translations;
}
// Construct the request
const request = {
  input: {text: content},
  // Select the language and SSML voice gender (optional)
  voice: {languageCode: entry, ssmlGender: 'NEUTRAL'},
  // select the type of audio encoding
  audioConfig: {audioEncoding: 'MP3'},
};

// Performs the text-to-speech request
const [response] = client.synthesizeSpeech(request);
// Write the binary audio content to a local file
const writeFile = util.promisify(fs.writeFile);
writeFile('output.mp3', response.audioContent, 'binary'); //write this to bucket
console.log('Audio content written to file: output.mp3');




