
const functions = require('@google-cloud/functions-framework');
const escapeHtml = require('escape-html');

functions.http('wrapperTest', (req, res) => {
    var mode = escapeHtml(req.query.mode || req.body.mode || 'default (E)');
	var experimentID = process.env.EXPERIMENTID;
    switch(mode){
        case "A":
            start1 = Date.now();
            function1()
            end1 = Date.now();

            start2 = Date.now();
            function2()
            end2 = Date.now();

            console.log("faaster_" + experimentID + ": modeA, f1 " + (end1-start1) + "ms f2 " + (end2-start2) + "ms");
            break;
        case "B":
            start2 = Date.now();
            function2()
            end2 = Date.now();

            start1 = Date.now();
            function1()
            end1 = Date.now();

            console.log("faaster_" + experimentID + ": modeB, f1 " + (end1-start1) + "ms f2 " + (end2-start2) + "ms");
            break;
        case "C":
            start1 = Date.now();
            function1()
            end1 = Date.now();

            console.log("faaster_" + experimentID + ": mode C, f1 " + (end1-start1) + "ms");
            break;
        case "D":
            start2 = Date.now();
            function2()
            end2 = Date.now();

            console.log("faaster_" + experimentID + ": mode D, f2 " + (end2-start2) + "ms");
            break;
        default:
            //threaded
            //web worker approach? needs separate files to work then, which would maybe be possible?
            break;
    }
    res.send('Ran mode ' + mode + ' according to passed variable');
})