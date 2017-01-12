function addGenderCaption ( girlsH, boysH ){
  var maleTag = $('#gender_graph-male_tag')
  var femaleTag = $('#gender_graph-female_tag')
  if (girlsH === 0 && boysH === 0){
    maleTag.hide()
    femaleTag.hide()
  } else if (girlsH === 0){
    femaleTag.hide()
    $(maleTag).css('top', girlsH+"px");
  } else if (boysH === 0){
    maleTag.hide()
  } else {
    $(maleTag).css('top', girlsH+"px");
  }
};

function addSeniorsCaption ( topOfSeniorsVertBarChart ){

  var seniorsTag = $('#seniors_graph-seniors_tag')
  $(seniorsTag).css('top', topOfSeniorsVertBarChart+"px");
  console.log(topOfSeniorsVertBarChart)

};

var VertBarChart = {
 
  onReady: function() {
    var percentMale = $('#gender_graph-container').attr('percentmale');
    var percentFemale = $('#gender_graph-container').attr('percentfemale');
    var studentsCount = $('#seniors_graph-container').attr('students');
    var seniorsCount = $('#seniors_graph-container').attr('seniors');
    VertBarChart.drawGenderGraph(percentMale, percentFemale);
    VertBarChart.drawSeniorsGraphs(studentsCount, seniorsCount);
  },
 
  drawGenderGraph: function(percentBoys, percentGirls) {
    var canvas = $('#gender_graph')[0]
    if (canvas.getContext == undefined) {
      var ctx = G_vmlCanvasManager.initElement(canvas).getContext("2d"); 
    }
    var ctx = canvas.getContext("2d");
    var width = canvas.width;
    var height = canvas.height;
    var boysH = (percentBoys/100)*height;
    var girlsH = (percentGirls/100)*height;
    ctx.fillStyle="#fbe0a5";
    ctx.fillRect(0,0,width,girlsH);  
    ctx.fillStyle="#f3a35e";
    ctx.fillRect(0,girlsH,width,boysH);

      addGenderCaption(girlsH, boysH);  
  },

  drawSeniorsGraphs: function (studentsCount, seniorsCount) {

    var totalStundentsCanvas = $('#students_graph')[0]
    if (totalStundentsCanvas.getContext == undefined) {
      var ctx = G_vmlCanvasManager.initElement(totalStundentsCanvas).getContext("2d"); 
    }
    var ctx = totalStundentsCanvas.getContext("2d");
    var width = totalStundentsCanvas.width;
    var height = totalStundentsCanvas.height;

    ctx.fillStyle="#f3a35e";
    ctx.fillRect(0,0,width,height);  

    var seniorsCanvas = $('#seniors_graph')[0]
    if (seniorsCanvas.getContext == undefined) {
      var ctx = G_vmlCanvasManager.initElement(seniorsCanvas).getContext("2d"); 
    }

    var ctx = seniorsCanvas.getContext("2d");
    var width = seniorsCanvas.width;
    var height = seniorsCanvas.height;   

    var seniorsH = (seniorsCount/studentsCount)*height;

    ctx.fillStyle="#fbe0a5";
    ctx.fillRect(0,(height-seniorsH),width,seniorsH);

    var topOfSeniorsVertBarChart = (height-seniorsH);
    
    addSeniorsCaption(topOfSeniorsVertBarChart);

  } 
};


$(document).ready(function(){ 
  if ($('#static-data-container').length > 0){
    VertBarChart.onReady() 
  };
});








