const functions = require('@google-cloud/functions-framework');
const escapeHtml = require('escape-html');

function getRandomBool() {
    return Math.floor(Math.random() * 2) !== 0;
}

functions.http('wrapperTest', (req, res) => {
    //comment for split to replace
    var mode = escapeHtml(req.query.mode || req.body.mode || 'default (A)');
    var iterations = escapeHtml(req.query.iterations || req.body.iterations || 5);
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
                if (getRandomBool) {
                    start1 = Date.now();
                    extTime1 = function1();
                    end1 = Date.now();

                    start2 = Date.now();
                    extTime2 = function2();
                    end2 = Date.now();
                } else {
                    start2 = Date.now();
                    extTime2 = function2();
                    end2 = Date.now();

                    start1 = Date.now();
                    extTime1 = function1();
                    end1 = Date.now();
                }
                extTime1Sum = extTime1.reduce((a, b) => a + b, 0);
                extTime2Sum = extTime2.reduce((a, b) => a + b, 0);
                fun1.push((end1 - start1 - extTime1Sum));
                fun2.push((end2 - start2 - extTime2Sum));
                break;
            case "B":
                start1 = Date.now();
                extTime1 = function1();
                end1 = Date.now();
                extTime1Sum = extTime1.reduce((a, b) => a + b, 0);
                fun1.push((end1 - start1 - extTime1Sum));
                break;
            case "C":
                start2 = Date.now();
                extTime2 = function2();
                end2 = Date.now();
                extTime2Sum = extTime2.reduce((a, b) => a + b, 0);
                fun2.push((end2 - start2 - extTime2Sum));
                break;
            default:
                if (getRandomBool) {
                    start1 = Date.now();
                    extTime1 = function1();
                    end1 = Date.now();

                    start2 = Date.now();
                    extTime2 = function2();
                    end2 = Date.now();
                } else {
                    start2 = Date.now();
                    extTime2 = function2();
                    end2 = Date.now();

                    start1 = Date.now();
                    extTime1 = function1();
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
