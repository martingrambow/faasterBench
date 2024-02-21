const { app } = require('@azure/functions');
var coldStart = true;
var applicationInsights = require("applicationinsights");
function getRandomBool() {
    return Math.floor(Math.random() * 2) !== 0;
}
app.http('faasterbench', {
    methods: ['GET', 'POST'],
    authLevel: 'anonymous',
    handler: async (request, context) => {
        console.log('Event: ', request);
        var markColdStart = false;
        if(coldStart){
            console.log("cold start");
            coldStart = false;
            markColdStart = true;
        }
        let mode = "A";
        let iterations = 1;
        if(request.query.get('mode')){
            mode = request.query.get('mode');
            console.log("Set mode to "+mode);
        }
        if(request.query.get('iterations')){
            iterations = parseInt(request.query.get('iterations'));
            console.log("Set iterations to "+iterations);
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
});
