const functions = require('@google-cloud/functions-framework');
const escapeHtml = require('escape-html');

function getRandomBool() {
    return Math.floor(Math.random() * 2) !== 0;
}

functions.http('wrapperTest', (req, res) => {
    var mode = escapeHtml(req.query.mode || req.body.mode || 'default (A)');
    var iterations = escapeHtml(req.query.iterations || req.body.iterations || 5);
    var experimentID = process.env.EXPERIMENTID;
    let fun1 = [];
    let fun2 = [];

    for (let i = 0; i < iterations; i++) {
        switch (mode) {
            case "A":
                if (getRandomBool) {
                    start1 = performance.now();
                    function1();
                    end1 = performance.now();

                    start2 = performance.now();
                    function2();
                    end2 = performance.now();
                } else {
                    start2 = performance.now();
                    function2();
                    end2 = performance.now();

                    start1 = performance.now();
                    function1();
                    end1 = performance.now();
                }

                fun1.push((end1 - start1));
                fun2.push((end2 - start2));
                break;
            case "B":
                start1 = performance.now();
                function1();
                end1 = performance.now();

                fun1.push((end1 - start1));
                break;
            case "C":
                start2 = performance.now();
                function2();
                end2 = performance.now();

                fun2.push((end2 - start2));
                break;
            default:
                //threaded
                //web worker approach? needs separate files to work then, which would maybe be possible?
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
