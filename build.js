var buildify = require("buildify");
var scriptsPath = "./scripts/";
var fs = require("fs");
var markdown = require("markdown");

buildify.task({
    name:"css-min",
    task:function(){
	console.log("starting css compression....");
	buildify().load("./styles/styles.css").cssmin().save("./styles/styles.min.css");
	console.log("Completed css completion");
    }

});



