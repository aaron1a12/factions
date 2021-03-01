var nuke3DSirenSnd = new Howl({src: ['sounds/civil_defense_siren.ogg'],volume: 0.05});
var nukeEASRadio = new Howl({src: ['sounds/eas_missile_message.ogg'],volume: 0.0});
var nukeBlackOutSnd = new Howl({src: ['sounds/blackout.mp3'],volume: 0.5});
var nukeAmbienceMusic = new Howl({src: ['sounds/ambience.ogg'],volume: 0.05});




var bKeepPlayingEAS = true;

var nuke3DSirenSndId = 0;

var bKeepPlayingMusic = false;

// Fires when the sound finishes playing.
nukeEASRadio.on('end', function(){
  $.post('http://wild-trainer/lua_carRadio', JSON.stringify({pauseRadio:false}));
  
  if (bKeepPlayingEAS) {
	  setTimeout(function(){
		  $.post('http://wild-trainer/lua_carRadio', JSON.stringify({pauseRadio:true}));
		  nukeEASRadio.play();
	  },20000);
  }
});

nuke3DSirenSnd.on('end', function(){
  bKeepPlayingEAS = false;
});

nukeAmbienceMusic.on('end', function(){
	if (bKeepPlayingMusic)
		nukeAmbienceMusic.play();
});		


var bIsPlayerInVehicle = false;
var bIsPlayerIndoors = false;

$(function() {


window.addEventListener('message', function(event) {
		
	if (typeof event.data.nukeMission == "undefined")
		return;
	
	if (event.data.nukeMission == "startEAS"){
		console.log("startEAS - js");
		Notification.Show(Notification.Icon.Generic, "Emergency Alert", "BALLISTIC MISSILE THREAT INBOUND TO SAN ANDREAS. SEEK IMMEDIATE SHELTER. THIS IS NOT A DRILL.", 20);
			
		setTimeout(function(){
			$.post('http://wild-trainer/lua_carRadio', JSON.stringify({pauseRadio:true}));
			nukeEASRadio.play();
		}, 5000);
		
		setTimeout(function(){
			nuke3DSirenSndId = nuke3DSirenSnd.play();
			bKeepPlayingEAS = true;
		}, 10000);
	}
	
	if (event.data.nukeMission == "playerLocationStatus"){
		bIsPlayerInVehicle = event.data.isPlayerInVehicle;
		bIsPlayerIndoors = event.data.isPlayerIndoors;
		
		if (bIsPlayerInVehicle)
			nukeEASRadio.volume(0.2);
		else
			nukeEASRadio.volume(0.0);
		
		if (bIsPlayerIndoors)
			nuke3DSirenSnd.volume(0.01);
		else
			nuke3DSirenSnd.volume(0.05);
		
		
		
		//console.log("X:"++",Y:"+event.data.camera.y+"Z:"+event.data.camera.z);
		//Howler.orientation(event.data.camera.x, event.data.camera.y, event.data.camera.z, 0, 1, 0);
		//nuke3DSirenSnd.pos(0, 0,  0, nuke3DSirenSndId);
	}

	if (event.data.nukeMission == "setBlackout"){
		if (event.data.blackOutStatus) {
			$('#blackOut').css('display', 'block');
			nukeBlackOutSnd.play();
		}else{
			$('#blackOut').css('display', 'none');
		}
	}
	
	if (event.data.nukeMission == "setMusic"){
		if (event.data.setMusic) {
			console.log("Play music.");
			bKeepPlayingMusic = true;
			nukeAmbienceMusic.play();
		}else{
			bKeepPlayingMusic = false;
		}
	}	
});	
	
});