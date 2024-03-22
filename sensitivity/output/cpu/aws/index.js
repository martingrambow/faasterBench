const AWS = require('aws-sdk');
var coldStart = true;
function getRandomBool() {
    return Math.floor(Math.random() * 2) !== 0;
}

exports.handler = async (event) => {
    var trials1;
    var trials2;
    //comment for split to replace
    console.log('Event: ', event);
    var markColdStart = false;
    if(coldStart){
        console.log("cold start");
        coldStart = false;
        markColdStart = true;
    }
    let mode = "A";
    let iterations = 1;
    if(event.hasOwnProperty("queryStringParameters")){
        trials1 = event.queryStringParameters.trials1;
        trials2 = event.queryStringParameters.trials2;
        if(event.queryStringParameters.mode){
            mode = event.queryStringParameters.mode;
            console.log("Set mode to "+mode);
        }
        if(event.queryStringParameters.iterations){
            iterations = parseInt(event.queryStringParameters.iterations);
            console.log("Set iterations to "+iterations);
        } 
    }
    let responseMessage = 'Ran mode ' + mode + ' according to passed variable';
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
                fun1.push((end1 - start1 - extTime1Sum));
                fun2.push((end2 - start2 - extTime2Sum));
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
      return {
        statusCode: 200,
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          message: responseMessage,
        }),
      }
}

function function1(trials) {
    var extTime = [];
    //var trials
    var neuronBias = [
        1.9, 0.3, -0.8, -1.7, -1.5, 0.6, -1.4, 1.8, 0.1, 0.4,
        -1.3, -0.5, 1.2, -0.1, -1.9, -0.4, 0.7, -1.2, -0.6, 1.5,
        0.8, -0.9, 1.7, 1.1, -1.8, -1.1, -0.3, 1.4, -1.6, 0.5,
        -0.7, -1.0, -0.2, 0.2, -0.0, 0.9, 1.6, 1.0, 0.0, -0.8,
        1.3, -0.5, -1.4, 1.1, 0.6, -1.7, -1.2, -0.1, 0.8, -0.3,
        -1.6, 0.4, 1.2, 1.9, -0.9, -0.7, -0.4, -1.3, -1.0, 0.1,
        -0.2, 0.3, -1.5, 1.0, 0.5, 1.8, 1.7, -0.6, -0.0, 1.4,
        -1.1, -0.6, 0.7, 0.2, -0.1, -1.8, -0.5, -1.9, 1.6, 1.5,
        0.9, 0.0, 0.3, -1.2, 1.3, -1.4, 0.4, 0.6, 0.8, -1.0,
        -0.4, 1.1, 0.7, -1.3, 1.2, 0.1, 1.3, -0.3, 2.0, -1.4
      ]
    var connectionWeights = [
        0.7, 0.5, -1.2, -0.8, -0.3, 1.6, -0.7, 1.1, 0.9, -1.5,
        1.9, 0.3, -1.1, -0.1, 1.7, -0.4, -0.5, -1.8, -1.3, 1.2,
        -0.2, 0.4, 0.2, 0.0, -1.9, -1.0, 1.0, -1.7, -0.6, 1.8,
        -0.9, -0.8, 1.5, -1.4, 0.8, 0.6, 0.1, -1.6, 1.4, 0.7,
        -1.6, -0.7, 1.6, -0.3, 0.5, 0.9, -0.4, -1.2, 1.3, 0.6,
        0.3, -1.5, -1.0, -0.1, 0.1, 0.8, -0.5, 1.1, 1.3, -1.4,
        -1.9, 1.2, -0.6, 0.4, -0.2, -1.3, -0.9, 1.0, -0.8, 0.2,
        1.7, -1.1, -0.3, 0.7, 0.0, 0.6, -1.8, -0.0, 1.9, -0.4,
        0.5, 1.4, -0.6, -1.7, 1.5, 0.9, 0.4, -1.0, -1.2, 1.8,
        -0.5, 0.7, 1.6, -1.3, -0.8, -0.9, 0.1, 1.1, -1.6, -1.4
      ]  
    var mutationRate = 1.0;
    var mutate = function (gene,mRate){
        if (Math.random() < mRate) {
            var mutateFactor = 1 + ((Math.random() - 0.5) * 3 + (Math.random() - 0.5));
            gene *= mutateFactor;
        }
        
        return gene;
    }
    for(var i =0; i<trials; i++){
        j = i % 100;
        neuronBias[j] = mutate(neuronBias[j], mutationRate);
        // mutate some 'weights' information of the offspring connections
    }
    for(var i =0; i<trials; i++){ 
        j = i % 100;
        connectionWeights[j] = mutate(connectionWeights[j], mutationRate);
    }
    return extTime;
 }
 function function2(trials) {
    var extTime = [];
    //var trials
    var neuronBias = [
        1.9, 0.3, -0.8, -1.7, -1.5, 0.6, -1.4, 1.8, 0.1, 0.4,
        -1.3, -0.5, 1.2, -0.1, -1.9, -0.4, 0.7, -1.2, -0.6, 1.5,
        0.8, -0.9, 1.7, 1.1, -1.8, -1.1, -0.3, 1.4, -1.6, 0.5,
        -0.7, -1.0, -0.2, 0.2, -0.0, 0.9, 1.6, 1.0, 0.0, -0.8,
        1.3, -0.5, -1.4, 1.1, 0.6, -1.7, -1.2, -0.1, 0.8, -0.3,
        -1.6, 0.4, 1.2, 1.9, -0.9, -0.7, -0.4, -1.3, -1.0, 0.1,
        -0.2, 0.3, -1.5, 1.0, 0.5, 1.8, 1.7, -0.6, -0.0, 1.4,
        -1.1, -0.6, 0.7, 0.2, -0.1, -1.8, -0.5, -1.9, 1.6, 1.5,
        0.9, 0.0, 0.3, -1.2, 1.3, -1.4, 0.4, 0.6, 0.8, -1.0,
        -0.4, 1.1, 0.7, -1.3, 1.2, 0.1, 1.3, -0.3, 2.0, -1.4
      ]
    var connectionWeights = [
        0.7, 0.5, -1.2, -0.8, -0.3, 1.6, -0.7, 1.1, 0.9, -1.5,
        1.9, 0.3, -1.1, -0.1, 1.7, -0.4, -0.5, -1.8, -1.3, 1.2,
        -0.2, 0.4, 0.2, 0.0, -1.9, -1.0, 1.0, -1.7, -0.6, 1.8,
        -0.9, -0.8, 1.5, -1.4, 0.8, 0.6, 0.1, -1.6, 1.4, 0.7,
        -1.6, -0.7, 1.6, -0.3, 0.5, 0.9, -0.4, -1.2, 1.3, 0.6,
        0.3, -1.5, -1.0, -0.1, 0.1, 0.8, -0.5, 1.1, 1.3, -1.4,
        -1.9, 1.2, -0.6, 0.4, -0.2, -1.3, -0.9, 1.0, -0.8, 0.2,
        1.7, -1.1, -0.3, 0.7, 0.0, 0.6, -1.8, -0.0, 1.9, -0.4,
        0.5, 1.4, -0.6, -1.7, 1.5, 0.9, 0.4, -1.0, -1.2, 1.8,
        -0.5, 0.7, 1.6, -1.3, -0.8, -0.9, 0.1, 1.1, -1.6, -1.4
      ]  
    var mutationRate = 1.0;
    var mutate = function (gene,mRate){
        if (Math.random() < mRate) {
            var mutateFactor = 1 + ((Math.random() - 0.5) * 3 + (Math.random() - 0.5));
            gene *= mutateFactor;
        }
        
        return gene;
    }
    for(var i =0; i<trials; i++){
        j = i % 100;
        neuronBias[j] = mutate(neuronBias[j], mutationRate);
        // mutate some 'weights' information of the offspring connections
    }
    for(var i =0; i<trials; i++){ 
        j = i % 100;
        connectionWeights[j] = mutate(connectionWeights[j], mutationRate);
    }
    return extTime;
 }