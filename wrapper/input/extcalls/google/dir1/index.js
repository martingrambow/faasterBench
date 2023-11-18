const textToSpeech = require('@google-cloud/text-to-speech');
// Imports The Google Cloud Storage library
const {Storage} = require('@google-cloud/storage');

// Imports the Google Cloud client library
const {Translate} = require('@google-cloud/translate').v2;

// Creates a client
const translate = new Translate();

var trials = process.env.LANGUAGES1;
var content;
// Creates a client
const client = new textToSpeech.TextToSpeechClient();

const fileName = process.env.TEXTFILE;
const storage = new Storage();
const myBucket = storage.bucket('extCallBucket');
const file = myBucket.file(fileName);

file.download().then(function(data) {
  content = data[0];
});

for(entry in languages){
  
    //depending on language, make a call to google translate or don't, if en, do not, if else, do
    if(entry != "en"){
      //extstart
      const translate = new Translate();
      const text = content;
      const target = entry;

      let translations = translate.translate(text, target);
      content = translations;
      //extstop
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
}



