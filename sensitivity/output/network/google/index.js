import { createRequire } from "module";
const require = createRequire(import.meta.url);
const functions = require('@google-cloud/functions-framework');
const escapeHtml = require('escape-html');
import translate from "translate";
var coldStart = true;
function getRandomBool() {
    return Math.floor(Math.random() * 2) !== 0;
}

functions.http('wrapperTest', async (req, res) => {
    var textInput1;
    var textInput2;
    //comment for split to replace
    var markColdStart = false;
    if(coldStart){
        console.log("cold start");
        coldStart = false;
        markColdStart = true;
    }
    var mode = escapeHtml(req.query.mode || req.body.mode || 'default (A)');
    var iterations = escapeHtml(req.query.iterations || req.body.iterations || 5);
    textInput1 = escapeHtml(req.query.textInput1 || req.body.textInput1);
    textInput2 = escapeHtml(req.query.textInput2 || req.body.textInput2);
    const baseline= 10000;
    const multiplied = (textInput2/textInput1)*baseline;
    const words = [
        "apple", "apron", "arrow", "audio", "audit",
        "bacon", "badge", "baker", "balmy", "banjo",
        "barge", "basic", "basin", "basso", "baste",
        "batch", "bayed", "beach", "beady", "beard",
        "beast", "beats", "beech", "beefy", "begin",
        "being", "belay", "belch", "belle", "berry",
        "berth", "beryl", "beset", "bight", "bigot",
        "biked", "biker", "biped", "birch", "birth",
        "bison", "bitch", "blame", "blanc", "bland",
        "blank", "blast", "blaze", "bleak", "blend",
        "bless", "blimp", "blink", "bliss", "blitz",
        "block", "bloat", "bloke", "blond", "blood",
        "bloom", "blown", "blues", "bluff", "blunt",
        "board", "boast", "boast", "boils", "bolar",
        "bolas", "bolts", "bones", "bonus", "boost",
        "boots", "boozy", "bored", "borel", "borne",
        "botch", "bough", "bound", "bourn", "bouts",
        "boxed", "boxer", "boxes", "brace", "bract",
        "brady", "brake", "brand", "brank", "brash",
        "brass", "brave", "brawl", "brays", "bread",
        "break", "breed", "brews", "briar", "bribe",
        "brick", "bride", "brief", "brisk", "broad",
        "broil", "broke", "bromo", "bronc", "brood",
        "brook", "broom", "broth", "brows", "brume",
        "brunt", "brush", "brusk", "brute", "bucks",
        "budge", "buffy", "build", "built", "bulbs",
        "bulge", "bulgy", "bulks", "bulky", "bulls",
        "bully", "bumps", "bumpy", "bunch", "bundy",
        "bunks", "bunny", "buoys", "buret", "burgh",
        "burns", "burnt", "burps", "burst", "bused",
        "buses", "bushy", "butch", "butte", "butts",
        "buxom", "buyer", "bylaw", "byres", "bytes",
        "cadet", "cagey", "caged", "cages", "cagey",
        "cakes", "calfs", "calix", "camps", "campy",
        "candy", "canoe", "canon", "canst", "canto",
        "cants", "caped", "capes", "capon", "carat",
        "cards", "cared", "cares", "caret", "cargo",
        "carol", "carom", "carpi", "carry", "carts",
        "carve", "cases", "cased", "casks", "casts",
        "catty", "caves", "cavil", "cease", "cecal",
        "cedar", "ceded", "cedes", "celeb", "cello",
        "cells", "cento", "ceres", "chain", "chair",
        "chalk", "champ", "chant", "chaos", "chaps",
        "charm", "chary", "chase", "chasm", "chats",
        "cheap", "cheat", "check", "cheek", "cheer",
        "chefs", "chess", "chest", "chews", "chews",
        "chick", "chide", "chief", "child", "chile",
        "chill", "chimp", "china", "chips", "chive",
        "chock", "choir", "choke", "chomp", "chops",
        "chord", "chore", "chows", "chump", "chunk",
        "churl", "churn", "chute", "cider", "cigar",
        "cilia", "cinch", "circa", "cited", "cites",
        "civil", "clack", "clads", "claim", "clamp",
        "clams", "clans", "clang", "claps", "clash",
        "clasp", "class", "claws", "clays", "clean",
        "clear", "cleat", "cleft", "clerk", "click",
        "cliff", "climb", "cling", "clips", "cloak",
        "clock", "clods", "clogs", "clone", "clops",
        "close", "cloth", "cloud", "clout", "clove",
        "clown", "cloys", "clubs", "cluck", "clued",
        "clues", "clump", "clung", "coach", "coals",
        "coast", "coats", "cobra", "cocci", "cocoa",
        "codas", "coded", "coder", "codes", "codex",
        "coils", "coins", "coirs", "coked", "cokes",
        "colas", "colds", "colon", "color", "comas",
        "combo", "combs", "comer", "comes", "comet",
        "comic", "comps", "conch", "condo", "coned",
        "cones", "coney", "conga", "conic", "conks",
        "cooks", "cooky", "cools", "coops", "coots",
        "coped", "copes", "copra", "copse", "coral",
        "cords", "cored", "cores", "corgi", "corks",
        "corms", "corns", "corny", "corps", "costs",
        "couch", "cough", "could", "count", "court",
        "coven", "cover", "coves", "covet", "cowed",
        "cower", "coyly", "crabs", "crack", "crane", 
        "crazy", "cream", "crept", "cribs", "crime", 
        "crisp", "croak", "crops", "cross", "cupid",
        "croup", "crowd", "crown", "crude", "cruel",
        "crumb", "crush", "crust", "crypt", "cubed",
        "cubes", "cubic", "culls", "cults", "cumin"];
    let text1="";
    let text2="";
    for(let i=0;i<multiplied;i++){
        let index = i%400;
        if(i<baseline){
            text1= text1.concat(" ", words[index]);
        }
        text2= text2.concat(" ", words[index]);
    }
    textInput1=text1;
    textInput2=text2;
    var experimentID = process.env.EXPERIMENTID;
    let fun1 = [];
    let fun2 = [];
    var start1;
    var start2;
    var end1;
    var end2;
    var extTime1;
    var extTime2;
    var extTime1Sum;
    var extTime2Sum;
    for (let i = 0; i < iterations; i++) {
        switch (mode) {
            case "A":
                if (getRandomBool()) {
                    start1 = Date.now();
                    extTime1 = await function1(textInput1);
                    end1 = Date.now();

                    start2 = Date.now();
                    extTime2 = await function2(textInput2);
                    end2 = Date.now();
                } else {
                    start2 = Date.now();
                    extTime2 = await function2(textInput2);
                    end2 = Date.now();

                    start1 = Date.now();
                    extTime1 = await function1(textInput1);
                    end1 = Date.now();
                }
                extTime1Sum = extTime1.reduce((a, b) => a + b, 0);
                extTime2Sum = extTime2.reduce((a, b) => a + b, 0);
                fun1.push((end1 - start1 - extTime1Sum));
                fun2.push((end2 - start2 - extTime2Sum));
                break;
            case "B":
                start1 = Date.now();
                extTime1 = await function1(textInput1);
                end1 = Date.now();
                extTime1Sum = extTime1.reduce((a, b) => a + b, 0);
                fun1.push((end1 - start1 - extTime1Sum));
                break;
            case "C":
                start2 = Date.now();
                extTime2 = await function2(textInput2);
                end2 = Date.now();
                extTime2Sum = extTime2.reduce((a, b) => a + b, 0);
                fun2.push((end2 - start2 - extTime2Sum));
                break;
            default:
                if (getRandomBool()) {
                    start1 = Date.now();
                    extTime1 = await function1(textInput1);
                    end1 = Date.now();

                    start2 = Date.now();
                    extTime2 = await function2(textInput2);
                    end2 = Date.now();
                } else {
                    start2 = Date.now();
                    extTime2 = await function2(textInput2);
                    end2 = Date.now();

                    start1 = Date.now();
                    extTime1 = await function1(textInput1);
                    end1 = Date.now();
                }
                extTime1Sum = extTime1.reduce((a, b) => a + b, 0);
                extTime2Sum = extTime2.reduce((a, b) => a + b, 0);
                fun1.push((end1 - start1-extTime1Sum));
                fun2.push((end2 - start2-extTime2Sum));
                break;
                
        }
    }

    var logText = "faaster_" + experimentID + ": mode" + mode + " ";
    if(markColdStart){
        logText = "cold start "+logText
    }
    logText += "f1 ";
    fun1.forEach(function (value, i) {
        logText += value + " ";
    });

    logText += "f2 ";
    fun2.forEach(function (value, i) {
        logText += value + " ";
    });

    console.log(logText);

    res.send('Ran mode ' + mode + ' according to passed variable');
})

async function function1(textInput) {
   var extTime = [];
   // Imports the translate library
   
   //var textInput
   const language = "de";
   //download the text from the cloud
   var content = textInput;
   //translate the text if required
   if(language != "en"){
     const target = language;
     const translation = await translate(textInput,"de");
     content = translation;
   }
   return extTime;
}
async function function2(textInput) {
   var extTime = [];
   //var textInput
   const language = "de";
   //download the text from the cloud
   var content = textInput;
   //translate the text if required
   if(language != "en"){
     const target = language;
     const translation = await translate(textInput,"de");
     content = translation;
   }
   return extTime;
}