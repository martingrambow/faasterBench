// Imports the translate library
const Translate = require('translate');

//split textInput
const language = inputLanguage;
//download the text from the cloud
var content = textInput;
//translate the text if required
if(language != "en"){
  const target = language;
  const translation = await Translate.translate(content, "de");
  content = translation;
}
console.log(content);
return extTime;