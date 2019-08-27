// app.js
angular.module('sortApp', [])

    .controller('mainController', function($scope, $http, $timeout) {

  var context = new AudioContext();
  var source = null;

  $scope.selectedSetting = 0;
  $scope.fileId = 0;
  $scope.playing = false;
  $scope.playRandom = false;
  $scope.audioFileNames = data.audioFileNames[0];
  $scope.fileName = $scope.audioFileNames[0][0];

$scope.hasData = function(index) {
  return $scope.audioFileNames[index].length>0;
}

$scope.setSetting = function(index) {
  $scope.selectedSetting = index;
  $scope.fileName = $scope.audioFileNames[$scope.selectedSetting][$scope.fileId];
  $scope.playAudio();
}

$scope.setRandom = function() {
  $scope.playRandom = !$scope.playRandom;
}

  $scope.selectAudioFile = function(forward=true) {
    if ($scope.playRandom) {
$scope.fileId = Math.floor(Math.random()*$scope.audioFileNames[$scope.selectedSetting].length);
    }
    else {
      if (forward) {
        if ($scope.fileId<$scope.audioFileNames[$scope.selectedSetting].length-1) {
        $scope.fileId++;
      }
    }
      else {
        if ($scope.fileId>0) {
          $scope.fileId--;
        }
      }
    }
    $scope.fileName = $scope.audioFileNames[$scope.selectedSetting][$scope.fileId];
  }

  $scope.playAudio = function() {
    $scope.playing = !$scope.playing;
    if ($scope.playing) {
      console.log('play audio');

      window.fetch('audio/'+$scope.fileName)
  .then(response => response.arrayBuffer())
  .then(arrayBuffer => context.decodeAudioData(arrayBuffer))
  .then(audioBuffer => {
   source = context.createBufferSource();
   source.buffer = audioBuffer;
   source.connect(context.destination);
   source.start();
  });
    }
    else {
      source.stop();
    }
  }

	$scope.sortType     = ''; // set the default sort type
	$scope.sortReverse  = false;  // set the default sort order

	$scope.tables = data.tables;
	$scope.title = data.title;
	document.title = $scope.title;
	$scope.showTex = -1;
	$scope.author = data.author;
        $scope.date = data.date;
	$scope.report = report.split("\n");
	console.log(data);

	comments.forEach(function(comment, index){
	    if (index < $scope.tables.length)
		$scope.tables[index].comment = comment.split("\n");
	})

	$scope.tables.forEach(function(table) {
	    table.tex = table.tex.join("\n");
	})

	$scope.showTable = function(index) {
	    if (!$scope.tables[index].visibleHeight || $scope.tables[index].visibleHeight=="0px") {
		var content = document.getElementById("table-"+index+"-content");
		$scope.tables[index].visibleHeight = window.getComputedStyle(content).height;
	    } else {
		$scope.tables[index].visibleHeight="0px";
	    }
	    //$scope.tables[index].show = !$scope.tables[index].show;
	}

	$scope.showTexFile = function(index) {
	    if ($scope.showTex == -1)
		$scope.showTex = index;
	    else
		$scope.showTex = -1;
	    console.log($scope.showTex);
	}

	$scope.sortCell = function(a) {
	    na = Number.parseFloat(a[$scope.sortType]);

	    if (Number.isNaN(na)) return a[$scope.sortType];
	    else return na;
	}

	$scope.copyToClipBoard = function(index) {
	    var copyTextarea = document.querySelector('.texData');
	    copyTextarea.select();
	    try {
		var successful = document.execCommand('copy');
		var msg = successful ? 'successful' : 'unsuccessful';
		console.log('Copying text command was ' + msg);
	    } catch (err) {
		console.log('Oops, unable to copy');
	    }
	    $scope.showTex = -1;
	}

	$scope.setSortType = function (col) {
	    $scope.sortType = col;
	    $scope.sortReverse = !$scope.sortReverse;
	}

	var noSortColumns = [""];

	$scope.isBest = function (table, col, val) {
	    var v = Number.parseFloat(val);
	    if (Number.isNaN(v)) return false;
	    if (noSortColumns.find(function(c){return col==c;})) return false;
	    for (var i=0, l=table.rows.length; i<l; i++)
		if (Number.parseFloat(table.rows[i][col]) > v) return false;
	    return true;
	}

	$scope.stopEvent = function(e) {
	    if (e.stopPropagation) e.stopPropagation();
	    else e.cancelBubble = true;
	    if (e.preventDefault) e.preventDefault();
	    }

	//  reportName = location.pathname.substring(1, location.pathname.length-5).replace(/^.*\//, "");
	$timeout(function(){$scope.showTable(0);}, 200);

    });
