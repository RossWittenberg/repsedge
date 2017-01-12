var Pie = {
 
  onReady: function() {
    var percentWhite = $('#ethnicity_pie_contanier').attr('percentWhite'); 
    var percentAfricanAm = $('#ethnicity_pie_contanier').attr('percentAfricanAm');
    var percentAsianAm = $('#ethnicity_pie_contanier').attr('percentAsianAm');
    var percentHispanicAm = $('#ethnicity_pie_contanier').attr('percentHispanicAm');
    var percentOther = $('#ethnicity_pie_contanier').attr('percentOther');

    var ctx = document.getElementById("ethnicity_pie-canvas").getContext("2d");
    var data = [
			    {
			        value: percentWhite,
			        color:"#fee2aa",
			        label: "White"                 
			    },
			    {
			        value: percentAfricanAm,
			        color: "#fbba7c",
			        label: "African American"
			    },
			    {
			        value: percentAsianAm,
			        color: "#f8a765",
			        label: "Asian American"
			    },
			    {
			        value: percentHispanicAm,
			        color: "#fdcd82",
			        label: "Hispanic American"
			    },
			    {
			        value: percentOther,
			        color: "#f59651",
			        label: "Other"
			    }
			];
		var options = {

	    segmentShowStroke : false,
	    showTooltips: true,

			tooltipFillColor: "rgba(0,0,0,0)",
			tooltipFontFamily: "'Helvetica Neue', 'Helvetica', 'Arial', sans-serif",
			tooltipFontSize: 14,
			tooltipFontStyle: "normal",
			tooltipFontColor: "#35657b",
			tooltipTitleFontFamily: "'Helvetica Neue', 'Helvetica', 'Arial', sans-serif",
			tooltipTitleFontSize: 14,
			tooltipTitleFontStyle: "normal",
			tooltipTitleFontColor: "#35657b",
			tooltipYPadding: 6,
			tooltipXPadding: 6,
			tooltipCaretSize: 8,
			tooltipCornerRadius: 6,
			tooltipXOffset: 10,
			tooltipTemplate: " <%if (label) { %> <%= label %> : <% } %> <%= value %> % ",
			multiTooltipTemplate: "<%= value %>",
	    percentageInnerCutout : 0, 
	    animationSteps : 50,
	    animationEasing : "easeOutCirc",
	    animateRotate : true,
	    animateScale : false,
	    inGraphDataShow: true,
    	inGraphDataRadiusPosition: 2,
    	inGraphDataFontColor: 'green',
	    legendTemplate : '<ul>'
                  		+'<% for (var i=0; i<segments.length; i++) { %>'
                    	+'<li>'
                    	+'<% if (segments[i].label) { %><p style="font-size:14px;color:#ffab6b"><%= segments[i].label + " " + segments[i].value + "%" %></p><% } %>'
                 		  +'</li>'
                			+'<% } %>'
              				+'</ul>'
		};

		var myPieChart = new Chart(ctx).Pie(data,options);

		var legend = myPieChart.generateLegend()
		$('#ethnicity-legend-container').html(legend)

  }

};

$(document).ready(function(){ 
	if ($('#static-data-container').length > 0){
		Pie.onReady() 
	};
});



