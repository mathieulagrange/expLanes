// app.js
angular.module('sortApp', [])

    .controller('mainController', function($scope, $http, $timeout) {

  var context = new AudioContext();
  var source = null;

  $scope.selectedSetting = 0;
  $scope.fileId = 0;
  $scope.playing = false;
  $scope.playRandom = false;
  $scope.audioFileNames = data.audioFileNames;
  $scope.fileName = [];

$scope.hasData = function(indexTable, index=-1) {
  var hasAudio = false
    $scope.selectedTable = indexTable;
    if (index>-1) {
  hasAudio =  $scope.audioFileNames[indexTable][index].length>0;
    }
    else {
      for (var i = 0; i < $scope.audioFileNames[indexTable].length; i++) {
      if ($scope.audioFileNames[indexTable][i].length>0) {
        hasAudio=true;
      }
      }
    }
return hasAudio;
}

$scope.setSetting = function(indexTable, row) {
  $scope.selectedSetting = $scope.tables[indexTable].rows.indexOf(row);
  console.log($scope.selectedSetting);
  $scope.selectedTable = indexTable;
  $scope.fileName[indexTable] = $scope.audioFileNames[indexTable][$scope.selectedSetting][$scope.fileId];
  $scope.playAudio(indexTable);
}

$scope.setRandom = function(indexTable) {
  $scope.playRandom[indexTable] = !$scope.playRandom[indexTable];
}

  $scope.selectAudioFile = function(indexTable, forward=true) {
      $scope.selectedTable = indexTable;
    if ($scope.playRandom) {
$scope.fileId = Math.floor(Math.random()*$scope.audioFileNames[$scope.selectedTable][$scope.selectedSetting].length);
    }
    else {
      if (forward) {
        if ($scope.fileId<$scope.audioFileNames[$scope.selectedTable][$scope.selectedSetting].length-1) {
        $scope.fileId++;
      }
    }
      else {
        if ($scope.fileId>0) {
          $scope.fileId--;
        }
      }
    }
    $scope.fileName[indexTable] = $scope.audioFileNames[$scope.selectedTable][$scope.selectedSetting][$scope.fileId];
  }

  $scope.playAudio = function(tableIndex) {
    $scope.playing[tableIndex] = !$scope.playing[tableIndex];
    if ($scope.playing[tableIndex]) {
      console.log('play audio');

      window.fetch('audio/'+$scope.fileName[tableIndex])
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


	$scope.tables = data.tables;
	$scope.title = data.title;
	document.title = $scope.title;
	$scope.showTex = -1;
	$scope.author = data.author;
        $scope.date = data.date;
	$scope.report = report.split("\n");

  $scope.selectedTable = 0;
  $scope.sortType = [];
  $scope.sortReverse = [];
  $scope.playRandom = [];
  $scope.playing = [];
  for (var i = 0; i < $scope.tables.length; i++) {
    $scope.sortType.push(''); // set the default sort type
    $scope.sortReverse.push(false);  // set the default sort order
    $scope.playRandom.push(false);  // set the default sort order
    $scope.playing.push(false);  // set the default sort order
    $scope.fileName.push($scope.audioFileNames[i][0][0]);  // set the default sort order
  }

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

  $scope.showTables = function(){
    for (var i = 0; i < $scope.tables.length; i++) {
      $scope.showTable(i);
    }
  }

	$scope.showTexFile = function(index) {
	    if ($scope.showTex == -1)
		$scope.showTex = index;
	    else
		$scope.showTex = -1;
	    console.log($scope.showTex);
	}

	$scope.sortCell = function(a) {
    // console.log($scope.sortType);
    // console.log($scope.selectedTable);
    // console.log($scope.sortType[$scope.selectedTable]);
	    na = Number.parseFloat(a[$scope.sortType[$scope.selectedTable]]);

	    if (Number.isNaN(na)) return a[$scope.sortType[$scope.selectedTable]];
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

	$scope.setSortType = function (tableIndex, col) {
      $scope.selectedTable = tableIndex;
	    $scope.sortType[tableIndex] = col;
	    $scope.sortReverse[tableIndex] = !$scope.sortReverse[tableIndex];
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
	$timeout(function(){$scope.showTables();}, 200);

    });
