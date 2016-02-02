app.controller("DemosController", function($scope) {

    $scope.demos = [
	{title: "Comparison of distances", html:"demo1.html", url:"https://github.com/mathieulagrange/expLanes/blob/master/demo/distanceComputation", pdf:"demo/distanceComputation.pdf"},
	{title: "Clustering", html:"demo2.html", url:"https://github.com/mathieulagrange/expLanes/blob/master/demo/clusteringData", pdf:"demo/clusteringData.pdf"},
	{title: "Classification", html:"demo3.html", url:"https://github.com/mathieulagrange/expLanes/blob/master/demo/classifyData", pdf:"demo/classifyData.pdf"},
	{title: "Audio source separation", html:"demo4.html", url:"https://github.com/mathieulagrange/expLanes/blob/master/demo/denoiseAudio", pdf:"demo/denoiseAudio.pdf"}
    ];

//    $scope.demos.forEach(function(d) {
//	d.pdf = 'web/pdf/'+d.url.replace(/.+\//,'')+".pdf";
//    });

    $scope.currentDemo = 0;
    
});
