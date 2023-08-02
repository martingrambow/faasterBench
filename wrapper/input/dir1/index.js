var trials = 10000000;
var inVar = 0;
var out = 0;
var i = 0;
var start = Date.now();
while (i < trials) {
    var x = Math.random();
    var y = Math.random();
    var distance = Math.sqrt((x * x) + (y * y));
    if (distance <= 1) {
        inVar++;
    } else {
        out++;
    }
    i++;
}
var pi = 4.0 * ( inVar / trials);
var end = Date.now();

console.log("in is " + inVar);
console.log("out is " + out);
console.log("Pi is " + pi);
console.log("Duration " + (end-start) + "ms");
