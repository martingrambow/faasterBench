
// Imports the Google Cloud client library
const {Translate} = require('@google-cloud/translate').v2;

// Creates a client
const translate = new Translate();
var AWS=require('aws-sdk');
var polly=new AWS.Polly({region: 'europe-west-1'});

var content;
//get file from bucket 
var s3 = new AWS.S3();
var params = {Bucket: 'extCallBucket', Key: 'test'} //,Key:Key.csv;
var s3file = s3.getObject(params);
s3.getObject(params, function(err, data) {
  if (err) console.log(err, err.stack); // an error occurred
  else     content = data.Body.toString('ascii'); // successful response
});
var languages = Process.env.LANGUAGES1;
for(entry in languages){
  switch(entry) {
    case "en": {
      var voice="Amy";
      break;
    }
    case "da": {
      var voice="Naja";
      break;
    }
    case "nl": {
      var voice="Lotte";
      break;
    }
    case "fr": {
      var voice="Celine";
      break;
    }
    case "de": {
      var voice="Marlene";
      break;
    }
    case "es": {
      var voice="Penelope";
      break;
    }
    case "is": {
      var voice="Dora";
      break;
    }
    case "it": {
      var voice="Carla";
      break;
    }
    case "ja": {
      var voice="Mizuki";
      break;
    }
    case "no": {
      var voice="Liv";
      break;
    }
    case "pl": {
      var voice="Ewa";
      break;
    }
    case "pt": {
      var voice="Vitoria";
      break;
    }
    case "ro": {
      var voice="Carmen";
      break;
    }
    case "ru": {
      var voice="Tatyana";
      break;
    }
    case "sp": {
      var voice="Penelope";
      break;
    }
    case "sv": {
      var voice="Astrid";
      break;
    }
    case "tr": {
      var voice="Filiz";
      break;
    }
    default: {
      var voice="Joanna";
    }
  }
  if(entry != "en"){
    //extstart
    const translate = new Translate();
    const text = content;
    const target = entry;

    let translations = await translate.translate(text, target);
    content = translations;
    //extstop
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
}
