app.controller("SlidesController", function($scope, $timeout, $interval) {

    $scope.slides = [
	{position: 0, text:"Master", photo:"images/slide-master.jpg", thumbnail:"images/thumb-master.png", color:"#eea", textOpacity: 0, bullets:[
	    {text:"First steps in the scientific community"},
	    {text:"Compare your work with existing references"}]
	},
	{position: 1, text:"Ph.D. candidate", photo:"images/slide-phd.jpg", thumbnail:"images/thumb-phd.png", color:"#aae", textOpacity: 0, bullets:[
	    {text:"Keep track of large amount of code and experiments"},
	    {text:"Make your experimental results publishable"},
	    {text:"Stay focused and efficient on the long run"}]
	},
	{position: 2, text:"Postdoctoral fellow", photo:"images/slide-postdoc.jpg", thumbnail:"images/thumb-postdoc.png", color:"#aea", textOpacity: 0, bullets:[
	    {text:"Stay organized, with many different projects to juggle at once"},
	    {text:"Publish!"}]
	},
	{position: 3, text:"Faculty", photo:"images/slide-tenure.jpg", thumbnail:"images/thumb-tenure.png", color:"#eaa", textOpacity: 0, bullets:[
	    {text:"Easily switch between numerous projects"},
	    {text:"Monitor your jobs while you're in meetings"},
	    {text:"Standardize the way your students organize their code and data"}]
	}
    ];

    var showBulletTimeouts = [];

    var hideBullets = function(slide) {
	var nbBullets = slide.bullets.length;
	var startY = -100;
	var endY = 500;
	$timeout(function() {
	    for (var i=0; i<nbBullets; i++)
		slide.bullets[i].style = {left:'810px', top:Math.round(startY+i*(endY-startY)/(nbBullets+1))+'px', opacity: 0, fontSize:'60px', width:'1050px'};
	}, 300);
    }

    var bulletY = [[120], [110, 190], [85, 155, 225]];

    var showBullet = function(slide, i) {
	var nbBullets = slide.bullets.length;
	var y = bulletY[nbBullets-1][i];
	slide.bullets[i].style = {left:'480px', top:y+'px', opacity: 1, fontSize:'18px', width:'300px'};
    }

    var showBullets = function (slide) {
	for (var i=0, l=slide.bullets.length; i<l; i++)
	    showBulletTimeouts.push($timeout(showBullet.curry(slide, i), 800+2500*i/l));
    }
    
    var targetSlide = null;

    $scope.cycleTo = function (slide) {
	targetSlide = slide;
	$scope.cycleSlides();
    }

    $scope.cycleSlides = function(dir) {
	if (targetSlide) {
	    $interval.cancel($scope.profileInterval);
	    if (targetSlide.position == 0) {
		targetSlide = null;
		return;
	    } else {
		dir = targetSlide.position / Math.abs(targetSlide.position);
	    }
	} else if (dir) {
	    if (dir<0) dir = -1;
	    else dir = 1;
	    $interval.cancel($scope.profileInterval);
	} else {
	    dir = 1;
	}
	showBulletTimeouts.forEach(function(t){$timeout.cancel(t);});
	showBulletTimeouts = [];
	for (var s=0, nbSlides = $scope.slides.length; s<nbSlides; s++) {
	    var slide = $scope.slides[s];
	    slide.position -= dir;
	    slide.opacity = (!slide.position || dir*slide.position==-1) ? 1 : 0;
	    if (slide.position == 0)
		showBullets(slide);
	    else
		hideBullets(slide);
	    if (dir*slide.position <= -2)
		slide.position += dir*nbSlides;
	}
	if (targetSlide) $scope.cycleSlides();
    }

    for (var s=0, nbSlides = $scope.slides.length; s<nbSlides; s++)
	hideBullets($scope.slides[s]);
    

    $timeout(showBullets.curry($scope.slides[0]), 1000);
    
    $scope.profileInterval = $interval($scope.cycleSlides.curry(0), 10000);
    
});
