var uiTap = new Howl({src: ['sounds/press_up.wav'],volume: 0.5});
var uiPhoneSlide = new Howl({src: ['sounds/phone_slide.wav'],volume: 0.2});
var uiNotify = new Howl({src: ['sounds/notify.ogg'],volume: 0.2});

var bIsPhoneOpen = false;
var bIsPhonePeeking = false;

XAngle = 0;
YAngle = 0;
Z = 50;
TransitionIn = 0;
TransitionTranslate = 0;

function openPhone() {
	if (!bIsPhoneOpen) {
		console.log("Open phone?");
		bIsPhoneOpen = true;
		
		if (bIsPhonePeeking){
			bIsPhonePeeking = false;
			clearInterval(window.PhonePeekCheckInterval);	
			window.PhonePeekCheckInterval = 0;
		}
		
		uiPhoneSlide.play();

		$('#phone').css('display', 'block')
		//$('#phone').fadeIn("slow")			
		bIsPhoneOpen = true;
		
		$({ n: -600 }).animate({ n: 20}, {
			duration: 500,
			easing: "easeInOutBack",
			step: function(now, fx) {
				//TransitionTranslate = now;
				//updateView($('#phone'))
				//console.log(TransitionTranslate);
				
				$('#phone').css('bottom', now + 'px')
			}
		});			
		
		
		
		TransitionIn = 500;
		TransitionTranslate = 500;
		window.TransitionInt = window.setInterval(() => {
			if (TransitionIn!=0) {
				TransitionIn--;
				//document.getElementById("phoneWindow").style.borderWidth = TransitionIn+'px';
				$('#phone').css('transition', 'transform '+TransitionIn+'ms')
			}else{
				window.clearInterval(window.TransitionInt);
			}
		}, 0);	
	}
}

function closePhone() {
	if (bIsPhoneOpen) {
		bIsPhoneOpen = false;
		uiPhoneSlide.play();
		
		if (App.Running!="")
			App.Exit()
		
		$({ n: 20 }).animate({ n: -600}, {
			duration: 500,
			easing: "easeInOutBack",
			step: function(now, fx) {
				$('#phone').css('bottom', now + 'px');
			},
			complete: function(now, fx) {
				$('#phone').css('display', 'none');
				$.post('http://wild-trainer/lua_closePhone', JSON.stringify({}));
			}
		});	
	}	
}


function peekPhone() {
	$('#phone').css('display', 'block')
	//$('#phone').fadeIn("slow")			
	
	if (!bIsPhonePeeking) {
		bIsPhonePeeking = true;
		
		$({ n: -500 }).animate({ n: -350}, {
			duration: 500,
			easing: "easeOut",
			step: function(now, fx) {
				$('#phone').css('bottom', now + 'px')
			}
		});
	}
	
	var bSetInterval = false;

	if (typeof window.PhonePeekCheckInterval == "undefined") {
		bSetInterval = true;
	}else if (window.PhonePeekCheckInterval==0) {
		bSetInterval = true;		
	}
	
	console.log("window.PhonePeekCheckInterval:"+window.PhonePeekCheckInterval);
	
	if (bSetInterval) {
		window.PhonePeekCheckInterval = setInterval(() => {
			if (!Notification.bIsRunningQueue) {
				bIsPhonePeeking = false;
				clearInterval(window.PhonePeekCheckInterval);
				window.PhonePeekCheckInterval = 0;
				
				console.log("HIDE PHONE?");
				
				
				$({ n: -350 }).animate({ n: -600}, {
					duration: 500,
					easing: "easeInOutBack",
					step: function(now, fx) {
						$('#phone').css('bottom', now + 'px')
					},
					complete: function(now, fx) {
						$('#phone').css('display', 'none')
					}
				});				
			}

		}, 500);	
	}
}

		
$("body").on("mousemove",function(e){
	if(bIsPhoneOpen) {
		var $this = $(this);
		var XRel = (e.pageX-500) - $this.offset().left;
		var YRel = (e.pageY-500) - $this.offset().top;
		var width = $this.width();
		var height = $this.height();

		YAngle = -(0.5 - (XRel / width)) * 40; 
		XAngle = (0.5 - (YRel / height)) * 20;
		
		//console.log(XAngle)
		update3DView($('#phone'));
	}
});

$("body").on("click",function(e){
	if(bIsPhoneOpen && Notification.bIsRunningQueue) {
		console.log("Notifications are showing");
		Notification._ShowNextInQueue(true);
	}else{
		console.log("Notifications are NOT showing");
	}
});


$( "body" ).contextmenu(function() {
	if(bIsPhoneOpen) {
		closePhone();
	}
});


function update3DView(oLayer)
{
	oLayer.css({"transform":"perspective(600px) translateZ(" + Z + "px) rotateX(" + XAngle + "deg) rotateY(" + YAngle + "deg)"});
	
	var ShineYAngle = YAngle*10;
	ShineYAngle = ShineYAngle-ShineYAngle-ShineYAngle
	
	var ShineXAngle = XAngle*10;
	$("#lcdOverlay").css({"background":"radial-gradient(at "+ShineYAngle+"% "+ShineXAngle+"%, white,black)"});
}

var Notification = new Object();
Notification.Queue = [];
Notification.bIsRunningQueue = false;
Notification.RunningTimeout = 0;
Notification.StandardTimeout = 7;
Notification.Icon = new Object();
Notification.Icon.Generic = "icon-notify-generic.png";
Notification.Icon.MorsMutual = "icon-notify-mors-mutual.png";
Notification.Icon.Car = "icon-notify-car.png";
Notification.Icon.Message = "icon-notify-message.png";




Notification.Show = function(icon, title, message, timeout) {
	Notification.Queue.push({icon, title, message, timeout});
	
	if(!bIsPhoneOpen) {
		peekPhone();
	}
	
	setTimeout(function(){		
		if (!Notification.bIsRunningQueue) {
			//Notification.bIsRunningQueue = true;
			Notification._ShowNextInQueue();
		}		
	},0)
};
Notification._ShowNextInQueue = function(bForce){
		
		if (bForce === undefined) bForce = false;
		
		if(bForce && Notification.RunningTimeout!=0) {
			clearTimeout(Notification.RunningTimeout);
		}		
		
		if (Notification.Queue.length==0) {
			// There is no one next in line...
			$('#notification').fadeOut(200);
			Notification.bIsRunningQueue = false;
			return;
		}
		
		uiNotify.play();
		
		document.getElementById("notificationTitle").innerHTML = Notification.Queue[0].title;
		document.getElementById("notificationSubtitle").innerHTML = Notification.Queue[0].message;		
		document.getElementById("notificationIcon").src = "img/"+Notification.Queue[0].icon;		
		
		
		
		if (Notification.bIsRunningQueue==false) {
			Notification.bIsRunningQueue = true;
		}
		
		var timeOut = Notification.Queue[0].timeout * 1000;
		
		Notification.Queue.shift()
		
		Notification.RunningTimeout = setTimeout(function(){
			Notification._ShowNextInQueue();
		}, timeOut);		
		
		
		
		
		
		$('#notification').fadeIn(200, function(){
			// Hide or show next one
		});	
};

var App = new Object();
App.Collection = new Object();
App.Running = "";
App.LastMenu = "";

App.Register = function( appObj ){
	App.Collection[appObj.id] = appObj;
};

App.Run = function(appId){
	if (App.Running!="") return;
	
	uiTap.play();
	
	if (typeof App.Collection[appId] == "undefined") {
		Notification.Show(Notification.Icon.Generic, "System", "The requested app is not installed. Please try contacting your system administrator.", Notification.StandardTimeout);
		return;
	}
	
	App.Running = appId;
	App.Collection[appId].onStart();
	
	$('#phoneAppWorkspace').fadeIn(200, function(){
		
	});
	$('#phoneAppWorkspace').css('transform', 'scale(1)')
	//Menu.Selected = "";
	// So we can go back when quitting
	//App.LastMenu = Menu.Opened;
	// Program will "draw" here
	//Menu.Open("workspace");
};

App.Exit = function(){
	if (App.Running=="") return;
	
	if (typeof App.Collection[App.Running].onExit == "function") App.Collection[App.Running].onExit();
	
	$('#phoneAppWorkspace').css('transform', 'scale(0)')
	$('#phoneAppWorkspace').fadeOut(200, function() {
		App.GetWorkspace().innerHTML = '';
		App.Running = '';
	});
};

App.GetWorkspace = function(){		
	return document.getElementById("phoneAppWorkspace");
};

App.ExecuteCmd = function( cmd ) {
	cmd = App.Collection[App.Running][cmd];
	cmd();
}


function GoBack() {
	uiTap.play();
	
	if (App.Running=="") return;
	
	if (typeof App.Collection[App.Running].onGoBack == "function")
		App.Collection[App.Running].onGoBack();
	else
		App.Exit()
}

function GoHome() {
	uiTap.play();
	
	if (App.Running=="") return;
	
	App.Exit()
}

function GoRecent() {
	uiTap.play();
}


$(function() {
	
	
	window.addEventListener('message', function(event) {
		
		if (typeof event.data.notificationText != "undefined") {
			Notification.Show(event.data.notificationIcon, event.data.notificationTitle, event.data.notificationText, Notification.StandardTimeout);
		}
		
		if (event.data.type == "setPlayerID"){		
			console.log("Player is " + event.data.playerID);
		}
		
	});
});


