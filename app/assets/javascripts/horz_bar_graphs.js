function addHsSATCaption ( mathW, readingW, writingW ){ 
  // change argument names to be explicit (mathW to mathWidth)
  $('#math_tag').css('left', (mathW - 20) +"px");
  $('#reading_tag').css('left', ((mathW+readingW)-40) +"px");  
  $('#writing_tag').css('left', ((mathW+readingW+writingW)-30) +"px");


  $('#hs_math_score').css('left', (mathW - 13) +"px");

  $('#hs_reading_score').css('left', ((mathW+readingW ) - 13) +"px");  

  $('#hs_writing_score').css('left', ((mathW+readingW+writingW)-13) +"px");


};

function addStateSATCaption( mathW, readingW, writingW ){
  var mathScore = $('#state_math_score');
  $(mathScore).css('left', (mathW - 13) +"px");

  var readingScore = $('#state_reading_score');
  $(readingScore).css('left', ((mathW+readingW ) - 13) +"px");  

  var writingScore = $('#state_writing_score');
  $(writingScore).css('left', ((mathW+readingW+writingW)-13) +"px");
};

function addHsACTCaption( hsACTW ){
  var hsACTScore = $('#hs_ACT_score');
  $(hsACTScore).css('left', (hsACTW - 20) +"px");
};

function addStateACTCaption( stateACTW ){
  var stateACTScore = $('#state_ACT_score');
  $(stateACTScore).css('left', (stateACTW - 25) +"px");  
};


var HorzBarChart = {
 
  onReady: function() {
    var hsMath= $('#SATs_graph-container').attr('sat_math');
    var hsReading= $('#SATs_graph-container').attr('sat_reading');
    var hsWriting= $('#SATs_graph-container').attr('sat_writing');

    var stateMath= $('#SATs_graph-container').attr('state_sat_math');
    var stateReading= $('#SATs_graph-container').attr('state_sat_reading');
    var stateWriting= $('#SATs_graph-container').attr('state_sat_writing');

    var hsACT = $('#ACTs_graph-container').attr('ACT');
    var stateACT = $('#ACTs_graph-container').attr('state_ACT');

    HorzBarChart.drawHsSATGraph(hsMath, hsReading, hsWriting);
    HorzBarChart.drawStateSATGraph(stateMath, stateReading, stateWriting);
    
    HorzBarChart.drawHsACTGraph(hsACT);
    HorzBarChart.drawStateACTGraph(stateACT);

  },
 
  drawHsSATGraph: function(hsMath, hsReading, hsWriting) {
    // hs SAT graph
    var canvas = $('#HS_SAT_graph')[0]
    // look into changing to "undefined"
    if (canvas.getContext == undefined) {
      var ctx = G_vmlCanvasManager.initElement(canvas).getContext("2d"); 
    }
    var ctx = canvas.getContext("2d");
    var width = canvas.width;
    var height = canvas.height;


    var mathW = (hsMath*width)/2400;
    var readingW = (hsReading*width)/2400;
    var writingW = (hsWriting*width)/2400;

    var totalW = width - (mathW + readingW + writingW)

    ctx.fillStyle="#f59651";
    ctx.fillRect(0,0,mathW,height); 


    ctx.fillStyle="#f59651";
    ctx.fillRect(mathW,0,readingW,height); 


    ctx.beginPath();
    ctx.moveTo(mathW,0);
    ctx.lineTo(mathW,height);
    ctx.lineWidth = 2;
    ctx.strokeStyle="#fff";
    ctx.stroke(); 

    ctx.fillStyle="#f59651";
    ctx.fillRect((mathW+readingW),0,writingW,height); 

    ctx.beginPath();
    ctx.moveTo((mathW+readingW),0);
    ctx.lineTo((mathW+readingW),height);
    ctx.lineWidth = 2;
    ctx.strokeStyle="#fff";
    ctx.stroke(); 
    
    ctx.fillStyle="#fee2aa";
    ctx.fillRect((mathW+readingW+writingW),0,totalW,height); 

    ctx.beginPath();
    ctx.moveTo((mathW+readingW+writingW),0);
    ctx.lineTo((mathW+readingW+writingW),height);
    ctx.lineWidth = 2;
    ctx.strokeStyle="#fff";
    ctx.stroke(); 

    addHsSATCaption( mathW, readingW, writingW )

  },

  drawStateSATGraph: function(stateMath, stateReading, stateWriting) {
    // state SAT graph
    var canvas = $('#state_SAT_graph')[0]
    if (canvas.getContext == undefined) {
      var ctx = G_vmlCanvasManager.initElement(canvas).getContext("2d"); 
    }
    var ctx = canvas.getContext("2d");
    var width = canvas.width;
    var height = canvas.height;

    var mathW = (stateMath*width)/2400;
    var readingW = (stateReading*width)/2400;
    var writingW = (stateWriting*width)/2400;

    var totalW = width - (mathW + readingW + writingW)

    ctx.fillStyle="#bababa";
    ctx.fillRect(0,0,mathW,height); 

    ctx.fillStyle="#bababa";
    ctx.fillRect(mathW,0,readingW,height);

    ctx.beginPath();
    ctx.moveTo(mathW,0);
    ctx.lineTo(mathW,height);
    ctx.lineWidth = 2;
    ctx.strokeStyle="#fff";
    ctx.stroke();     

    
    ctx.fillStyle="#bababa";
    ctx.fillRect((mathW+readingW),0,writingW,height); 

    ctx.beginPath();
    ctx.moveTo((mathW+readingW),0);
    ctx.lineTo((mathW+readingW),height);
    ctx.lineWidth = 2;
    ctx.strokeStyle="#fff";
    ctx.stroke(); 
    
    ctx.fillStyle="#f6f6f6";
    ctx.fillRect((mathW+readingW+writingW),0,totalW,height); 

    ctx.beginPath();
    ctx.moveTo((mathW+readingW+writingW),0);
    ctx.lineTo((mathW+readingW+writingW),height);
    ctx.lineWidth = 2;
    ctx.strokeStyle="#fff";
    ctx.stroke(); 

    addStateSATCaption( mathW, readingW, writingW );
  }, 

  drawHsACTGraph: function(hsACT) {
    // state SAT graph
    var canvas = $('#hs_ACT_graph')[0]
    if (canvas.getContext == undefined) {
      var ctx = G_vmlCanvasManager.initElement(canvas).getContext("2d"); 
    }
    var ctx = canvas.getContext("2d");
    var width = canvas.width;
    var height = canvas.height;

    var hsACTW = (hsACT*width)/36;
    var totalW = width - hsACTW;

    ctx.fillStyle="#f59551";
    ctx.fillRect(0,0,hsACTW,height); 

    ctx.beginPath();
    ctx.moveTo(hsACTW,0);
    ctx.lineTo(hsACTW,height);
    ctx.lineWidth = 4;
    ctx.strokeStyle="#fff";
    ctx.stroke();  

    ctx.fillStyle="#fee2aa";
    ctx.fillRect(hsACTW,0,totalW,height); 


    addHsACTCaption( hsACTW );
  },

  drawStateACTGraph: function(stateACT) {
    // state ACT graph
    var canvas = $('#state_ACT_graph')[0]
    if (canvas.getContext == undefined) {
      var ctx = G_vmlCanvasManager.initElement(canvas).getContext("2d"); 
    }
    var ctx = canvas.getContext("2d");
    var width = canvas.width;
    var height = canvas.height;

    var stateACTW = (stateACT*width)/36;
    var totalW = width - stateACTW;

    ctx.fillStyle="#bababa";
    ctx.fillRect(0,0,stateACTW,height); 

    ctx.beginPath();
    ctx.moveTo(stateACTW,0);
    ctx.lineTo(stateACTW,height);
    ctx.lineWidth = 4;
    ctx.strokeStyle="#fff";
    ctx.stroke(); 

    ctx.fillStyle="#f6f6f6";
    ctx.fillRect(stateACTW,0,totalW,height); 


    addStateACTCaption( stateACTW );
  }  
};


$(document).ready(function(){ 

  var winWidth = $(window).width();

  console.log(winWidth);


  if ($('#static-data-container').length > 0){
    HorzBarChart.onReady() 
  };
});








