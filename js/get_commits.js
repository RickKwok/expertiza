var request = require('request');
var fs = require("fs");
var Promise = require('bluebird');
var json2csv = require('json2csv');
var fields = ['commit.author.name', 'commit.author.date'];
// var parse = require('parse-link-header');
// var csv = require('csv-parse');
// var transform = require('stream-transform');

var token = "token" + process.env.GITHUB;

var url = fs.readFileSync('pull_requests.csv').toString().split("\n");	

// writeResponse(url);

// function writeResponse(url){
// 	for( var i = 4; i < url.length; i++ ){
// 		console.log(url[i]);
// 		console.log("I m here");
// 		getYourRepos( url[i] );
// 	}
// }

getYourRepos(url[45]);

function getYourRepos(singleUrl)
{

	var options = {
		url: singleUrl + '/commits?per_page=500',
		method: 'GET',
		headers: {
			"User-Agent": "EnableIssues",
			"content-type": "application/json",
			"Authorization": token
		}
	};

	//console.log(singleUrl);

	// Send a http request to url and specify a callback that will be called upon its return.
	request(options, function (error, response, body) 
	{
		var obj = JSON.parse(body);
		var commitNum = obj.length;
		var csv = json2csv({ data: obj, fields: fields });
		fs.writeFile('./commits_data/commits_' + singleUrl.substring(55,58), csv, function(err){
			if(err) throw err;
			console.log("file saved.");
		});
	});

}

function findprop(obj, path) {
    var args = path.split('.'), i, l;

    for (i=0, l=args.length; i<l; i++) {
        if (!obj.hasOwnProperty(args[i]))
            return;
        obj = obj[args[i]];
    }

    return obj;
}


