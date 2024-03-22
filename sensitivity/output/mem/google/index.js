const functions = require('@google-cloud/functions-framework');
const escapeHtml = require('escape-html');
var coldStart = true;
function getRandomBool() {
    return Math.floor(Math.random() * 2) !== 0;
}

functions.http('wrapperTest', (req, res) => {
    var trials1;
    var trials2;
    //comment for split to replace
    var markColdStart = false;
    if(coldStart){
        console.log("cold start");
        coldStart = false;
        markColdStart = true;
    }
    var mode = escapeHtml(req.query.mode || req.body.mode || 'default (A)');
    var iterations = escapeHtml(req.query.iterations || req.body.iterations || 5);
    trials1 = escapeHtml(req.query.trials1 || req.body.trials1);
    trials2 = escapeHtml(req.query.trials2 || req.body.trials2);
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
                    extTime1 = function1(trials1);
                    end1 = Date.now();

                    start2 = Date.now();
                    extTime2 = function2(trials2);
                    end2 = Date.now();
                } else {
                    start2 = Date.now();
                    extTime2 = function2(trials2);
                    end2 = Date.now();

                    start1 = Date.now();
                    extTime1 = function1(trials1);
                    end1 = Date.now();
                }
                extTime1Sum = extTime1.reduce((a, b) => a + b, 0);
                extTime2Sum = extTime2.reduce((a, b) => a + b, 0);
                fun1.push((end1 - start1 - extTime1Sum));
                fun2.push((end2 - start2 - extTime2Sum));
                break;
            case "B":
                start1 = Date.now();
                extTime1 = function1(trials1);
                end1 = Date.now();
                extTime1Sum = extTime1.reduce((a, b) => a + b, 0);
                fun1.push((end1 - start1 - extTime1Sum));
                break;
            case "C":
                start2 = Date.now();
                extTime2 = function2(trials2);
                end2 = Date.now();
                extTime2Sum = extTime2.reduce((a, b) => a + b, 0);
                fun2.push((end2 - start2 - extTime2Sum));
                break;
            default:
                if (getRandomBool()) {
                    start1 = Date.now();
                    extTime1 = function1(trials1);
                    end1 = Date.now();

                    start2 = Date.now();
                    extTime2 = function2(trials2);
                    end2 = Date.now();
                } else {
                    start2 = Date.now();
                    extTime2 = function2(trials2);
                    end2 = Date.now();

                    start1 = Date.now();
                    extTime1 = function1(trials1);
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

function function1(trials) {
   var extTime = [];
   //var trials
   // Create an array where each element starts as true
   const numsArr = Array.from({ length: trials + 1 }, () => true);
   
   // Loop through numsArr starting from numsArr[2]
   // keep running the loop until i is greater than the input's square root
   for (let i = 2; i <= Math.floor(Math.sqrt(trials)); i++) {
   // Check if numsArr[i] === true
       if (numsArr[i]) {
           /* 
           convert all elements in the numsArr 
           whose indexes are multiples of i 
           to false
           */
           for (let j = i + i; j <= trials; j += i) {
               numsArr[j] = false;
           }
       }
   }
   
   /*
   Using Array.prototype.reduce() method:
   loop through each element in numsArr[]
       if element === true, 
       add the index of that element to result[]
       return result
   */
   const primeNumbers = numsArr.reduce(
   (result, element, index) =>
       element ? (result.push(index), result) : result,
   []
   );
   
   // Return primeNumbers[]
   return extTime;
   
     
   
     
     
   
     
}
function function2(trials) {
   var extTime = [];
   //var trials
   // Create an array where each element starts as true
   const numsArr = Array.from({ length: trials + 1 }, () => true);
   
   // Loop through numsArr starting from numsArr[2]
   // keep running the loop until i is greater than the input's square root
   for (let i = 2; i <= Math.floor(Math.sqrt(trials)); i++) {
   // Check if numsArr[i] === true
       if (numsArr[i]) {
           /* 
           convert all elements in the numsArr 
           whose indexes are multiples of i 
           to false
           */
           for (let j = i + i; j <= trials; j += i) {
               numsArr[j] = false;
           }
       }
   }
   
   /*
   Using Array.prototype.reduce() method:
   loop through each element in numsArr[]
       if element === true, 
       add the index of that element to result[]
       return result
   */
   const primeNumbers = numsArr.reduce(
   (result, element, index) =>
       element ? (result.push(index), result) : result,
   []
   );
   
   // Return primeNumbers[]
   return extTime;
   
     
   
     
     
   
     
}