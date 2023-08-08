const AWS = require('aws-sdk')
exports.handler = async (event) => {
    console.log('Event: ', event);
    let mode = "E";
    if(event.hasOwnProperty("queryStringParameters")){
        mode = event.queryStringParameters.mode;
    }
    let responseMessage = "Ran experiment in mode "+mode;
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