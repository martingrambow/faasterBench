
const functions = require('@google-cloud/functions-framework');
const escapeHtml = require('escape-html');
functions.http('wrapperTest', (req, res) => {
    var mode = escapeHtml(req.query.mode || req.body.mode || 'default (E)');
    switch(mode){
        case "A":
            function1();
            function2();
            break;
        case "B":
            function2();
            function1();
            break;
        case "C":
            function1();
            break;
        case "D":
            function2();
            break;
        default:
            //threaded
            //web worker approach? needs separate files to work then, which would maybe be possible?
            break;
    }
    res.send('Ran mode ' + mode + ' according to passed variable');
})