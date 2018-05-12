var csv = require('fast-csv');
var request = require('/share/CACHEDEV1_DATA/.qpkg/SolinkConnect/bin/webrtc/node_modules/request');
var fs = require('/share/CACHEDEV1_DATA/.qpkg/SolinkConnect/bin/webrtc/node_modules/fs-extra');
//var request = require('request');
//var fs = require('fs');


var simulate = false;

var file = "./cameraConfig.csv";

addCamera  = function(d, cb) {
	var cameraProfile = null,
        validProfile = false,
        schedule = {},
        motionParams = {};

	if (d.cam_manufacturer === "hik") {
		cameraProfile = {
		    "id": "id_" + Math.random(),
		    "ip": d.cam_ip,
		    "manufacturer": d.cam_manufacturer,
		    "name": d.cam_name,
		    "password": d.cam_pass,
		    "username": d.cam_user,
		        "streams": [
		        {
		          "id": "",
		          "url": "rtsp://" + d.cam_user + ":" + d.cam_pass + "@" + d.cam_ip + "/Streaming/Channels/2",
		          "name": "SD",
		          "rtsp": "rtsp://" + d.cam_user + ":" + d.cam_pass + "@" + d.cam_ip + "/Streaming/Channels/2",
		          "bitrate": d.sd_bitrate,
		          "channel": "2",
		          "quality": d.sd_quality,
		          "framerate": d.sd_framerate,
		          "retention": d.sd_retention,
		          "resolution": d.sd_resolution
		        },
		        {
		          "id": "",
		          "url": "rtsp://" + d.cam_user + ":" + d.cam_pass + "@" + d.cam_ip + "/Streaming/Channels/1",
		          "name": "HD",
		          "rtsp": "rtsp://" + d.cam_user + ":" + d.cam_pass + "@" + d.cam_ip + "/Streaming/Channels/1",
		          "bitrate": d.hd_bitrate,
		          "channel": "1",
		          "quality": d.hd_quality,
		          "framerate": d.hd_framerate,
		          "retention": d.hd_retention,
		          "resolution": d.hd_resolution
		        }
		    ]
		}
		validProfile = true;
	} else 	if (d.cam_manufacturer === "axis") {
		cameraProfile = {
		    "id": "id_" + Math.random(),
		    "ip": d.cam_ip,
		    "manufacturer": d.cam_manufacturer,
		    "name": d.cam_name,
		    "password": d.cam_pass,
		    "username": d.cam_user,
		        "streams": [
		        {
				  "id": "",
				  "name": "SD",
		          "retention": d.sd_retention,
		          "resolution": d.sd_resolution
		        },
		        {
					"id": "",
					"name": "HD",
					"retention": d.hd_retention,
					"resolution": d.hd_resolution
				  }
		    ]
		}
		validProfile = true;
	} else if (d.cam_manufacturer === "unknown") {
		cameraProfile = {
		    "id": "id_" + Math.random(),
		    "ip": d.cam_ip,
		    "manufacturer": d.cam_manufacturer,
		    "name": d.cam_name,
		    "password": d.cam_pass,
		    "username": d.cam_user,
		    "streams": [],
		}	
	        if (d.sd_rtsp_url  && d.sd_rtsp_url !== '' ) {

		        cameraProfile.streams.push({
			          "id": "",
		        	  "url": "rtsp://" + d.cam_user + ":" + d.cam_pass + "@" + d.cam_ip + d.sd_rtsp_url,
			          "name": "SD",
			          "rtsp": "rtsp://" + d.cam_user + ":" + d.cam_pass + "@" + d.cam_ip + d.sd_rtsp_url,
			          "retention": d.sd_retention
		        });
		}

	        if (d.hd_rtsp_url  && d.hd_rtsp_url !== '' ) {
	
		        cameraProfile.streams.push({
			          "id": "",
		        	  "url": "rtsp://" + d.cam_user + ":" + d.cam_pass + "@" + d.cam_ip + d.hd_rtsp_url,
			          "name": "HD",
			          "rtsp": "rtsp://" + d.cam_user + ":" + d.cam_pass + "@" + d.cam_ip + d.hd_rtsp_url,
			          "retention": d.hd_retention
			        });
		}

		validProfile = true;
	} else { 
            console.log('This camera type is not supported', d);
        }


var newSchedule = {
    	"schedule_enabled": ( d.schedule === "true" ? "1" : "0"),
	    	"schedule": {
	        "sunday": {
	            "open": false,
	            "close": false
	        },
	        "monday": {
	            "open": false,
	            "close": false
	        },
	        "tuesday": {
	            "open": false,
	            "close": false
	        },
	        "wednesday": {
	            "open": false,
	            "close": false
	        },
	        "thursday": {
	            "open": false,
	            "close": false
	        },
	        "friday": {
	            "open": false,
	            "close": false
	        },
	        "saturday": {
	            "open": false,
	            "close": false
	        }
	    }
    }


	var daysOfWeek = ["monday","tuesday","wednesday","thursday","friday","saturday","sunday"],
	  open_hour,
	  open_min,
	  close_hour,
	  close_min;

	for (i in daysOfWeek) {
		if (d[daysOfWeek[i].substring(0,3) + '_open']) {
			open_hour = /(\d+):(\d+)/.exec(d[daysOfWeek[i].substring(0,3) + '_open'])[1];
			open_min = /(\d+):(\d+)/.exec(d[daysOfWeek[i].substring(0,3) + '_open'])[2];
			newSchedule['schedule'][daysOfWeek[i]]["open"] = {
				"hour": open_hour,
				"minutes": open_min
			};
		}

		if (d[daysOfWeek[i].substring(0,3) + '_close']) {
			close_hour = /(\d+):(\d+)/.exec(d[daysOfWeek[i].substring(0,3) + '_close'])[1],
			close_min = /(\d+):(\d+)/.exec(d[daysOfWeek[i].substring(0,3) + '_close'])[2];
			newSchedule['schedule'][daysOfWeek[i]]["close"] = {
				"hour": close_hour,
				"minutes": close_min
			};
		}
	}
    


	motionParams = {
		"camera_id": "",
		"camera": {
    		"motion": { 
	    		"enabled": ( d.motion === "true" ? "1" : "0" ),
	    		"threshold":180,
	    		"roi":"0000000000000011000000001100000000110000011111111001111111100000110000000011000000001100000000000000"
	    	}    			
		}
	};

        
    if ( !simulate && validProfile) {
		request.post({
			url: "http://solink-local:__connect__@127.0.0.1:3002/cameras/new/",
			json: cameraProfile,
			headers: {"Content-Type": "application/json"}
		},
		function(error, response, body) {
			if (error) throw error;
			if (body.success) {
				console.log( 'Added Camera ', body.camera.name, ' - ', Date.now() );
			} else {
				console.log( body )
			}
			var cameraID = body.camera['_id'];
			request.put({
				url: "http://solink-local:__connect__@127.0.0.1:3002/cameras/" + cameraID + "/schedule",
				json: newSchedule,
				headers: {"Content-Type": "application/json"}
			},
			function(error1, response1, body1) {
				if (error1) throw error1;
				if (body1.success) {
					console.log( 'Added Camera Schedule to ', body.camera.name, ' - ', Date.now() );
				} else {
					console.log( body1 )
				}
				request.put({
				    url: "http://solink-local:__connect__@127.0.0.1:3002/cameras/" + cameraID + "/motion",
				    json: motionParams,
				    headers: {"Content-Type": "application/json"}
				},
				function(error2, response2, body2) {
				    if (error2) throw error2;
					if (body2.success) {
						console.log( 'Added Camera Motion to ', body.camera.name, ' - ', Date.now() );
					} else {
						console.log( body2 )
					}
					cb();
				});
			});
		});
    } else {
      cb();
    }
};


var readFile = function(file, cb) {
  console.log('Reading file', file);
  var csvStr = csv({headers: true, strictColumnHandling: false, ignoreEmpty: false, discardUnmappedColumns: false, quote: '\"', escape: '\\', trim: true, delimiter: ','})
    .on('data', function(data) {
      //csvStr.pause();
      addCamera(data,  function() {
        //csvStr.resume();        
      });
    })
    .on('error', function(err) {
      console.log('ERROR', err);
      throw err;
    })
    .on('end', function() {
      cb();
    });
  var inputFileStr = fs.createReadStream(file, {encoding:'utf8'}).pipe(csvStr);
};

var auth;
var main = function() {
  console.log( Date.now());
  readFile(file, function(err) {
    console.log( Date.now());
    //fs.renameSync(file, 'processed_'+ file);

  });
};

main();
