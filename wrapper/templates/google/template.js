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

                fun1.push((end1 - start1 - extTime1));
                fun2.push((end2 - start2 - extTime2));
                break;
            case "B":
                start1 = Date.now();
                extTime1 = function1();
                end1 = Date.now();

                fun1.push((end1 - start1 - extTime1));
                break;
            case "C":
                start2 = Date.now();
                extTime2 = function2();
                end2 = Date.now();

                fun2.push((end2 - start2 - extTime2));
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

                fun1.push((end1 - start1-extTime1));
                fun2.push((end2 - start2-extTime2));
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
