const AWS = require('aws-sdk');

function getRandomBool() {
    return Math.floor(Math.random() * 2) !== 0;
}

exports.handler = async (event) => {
    //comment for split to replace
    console.log('Event: ', event);
    let mode = "A";
    let iterations = 1;
    if(event.hasOwnProperty("queryStringParameters")){
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
                    extTime1 = await function1();
                    end1 = Date.now();

                    start2 = Date.now();
                    extTime2 = await function2();
                    end2 = Date.now();
                } else {
                    start2 = Date.now();
                    extTime2 = await function2();
                    end2 = Date.now();

                    start1 = Date.now();
                    extTime1 = await function1();
                    end1 = Date.now();
                }
                extTime1Sum = extTime1.reduce((a, b) => a + b, 0);
                extTime2Sum = extTime2.reduce((a, b) => a + b, 0);
                fun1.push((end1 - start1 - extTime1Sum));
                fun2.push((end2 - start2 - extTime2Sum));
                break;
            case "B":
                start1 = Date.now();
                extTime1 = await function1();
                end1 = Date.now();
                extTime1Sum = extTime1.reduce((a, b) => a + b, 0);
                fun1.push((end1 - start1 - extTime1Sum));
                break;
            case "C":
                start2 = Date.now();
                extTime2 = await function2();
                end2 = Date.now();
                extTime2Sum = extTime2.reduce((a, b) => a + b, 0);
                fun2.push((end2 - start2 - extTime2Sum));
                break;
            default:
                if (getRandomBool()) {
                    start1 = Date.now();
                    extTime1 = await function1();
                    end1 = Date.now();

                    start2 = Date.now();
                    extTime2 = await function2();
                    end2 = Date.now();
                } else {
                    start2 = Date.now();
                    extTime2 = await function2();
                    end2 = Date.now();

                    start1 = Date.now();
                    extTime1 = await function1();
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