var Donut = {
 
  buildGradRateDonut: function() {
    var gradRate = $('#grad_donut-container').attr('gradRate'); 
   	var nonGrads = 100 - gradRate

    var ctx = document.getElementById("grad_donut_donut").getContext("2d");
    var data = [
	    {
        value: gradRate,
        color:"#f79548",
        highlight: "#35657b",
        label: "Graduation Rate"
	    },
	    {
        value: nonGrads,
        color: "#fbe0a5",
        highlight: "#79c2df"
	    }
		];
		var options = {
	    segmentShowStroke : false,
	    percentageInnerCutout : 90, // This is 0 for Donut charts
	    animationSteps : 50,
	    animationEasing : "easeOutCirc",
	    animateRotate : true

		};

		var gradDonutChart = new Chart(ctx).Doughnut(data,options);
  },

  buildFourYearSchoolDonut: function() {
    var fourYearSchool = $('#four_year_school-container').attr('fourYearSchool'); 
   	var nonFourYear = 100 - fourYearSchool

    var ctx = document.getElementById("four_year_school_donut").getContext("2d");
    var data = [
	    {
	      value: fourYearSchool,
	      color:"#f79548",
	      highlight: "#35657b",
	      label: "Graduation Rate"
	    },
	    {
	      value: nonFourYear,
	      color: "#fbe0a5",
	      highlight: "#79c2df"
	    }
		];

		var options = {
	    segmentShowStroke : false,
	    percentageInnerCutout : 90, // This is 0 for Donut charts
	    animationSteps : 50,
	    animationEasing : "easeOutCirc",
	    animateRotate : true

		};

		var fourYearDonutChart = new Chart(ctx).Doughnut(data,options);
  },

  buildReducedLunchDonut: function() {
    var reducedLunch = $('#reduced_lunch_donut-container').attr('reducedLunch'); 
   	var lunch = 100 - reducedLunch

    var ctx = document.getElementById("reduced_lunch_donut").getContext("2d");
    var data = [
	    {
	      value: reducedLunch,
	      color:"#f79548",
	      highlight: "#35657b",
	      label: "Graduation Rate"
	    },
	    {
	      value: lunch,
	      color: "#fbe0a5",
	      highlight: "#79c2df"
	    }
		];
		var options = {
	    segmentShowStroke : false,
	    percentageInnerCutout : 90, // This is 0 for Donut charts
	    animationSteps : 50,
	    animationEasing : "easeOutCirc",
	    animateRotate : true

		};

		var lunchDonutChart = new Chart(ctx).Doughnut(data,options);
  }

};

$(document).ready(function(){ 
	if ($('#static-data-container').length > 0){
		Donut.buildGradRateDonut() 
		Donut.buildFourYearSchoolDonut()
		Donut.buildReducedLunchDonut() 
	};
});