$(document).ready (function() {
  $('img.spinner').hide();
  // setup global ajax handlers, attach them to the body
  $('body').ajaxStart(function(){$('img.spinner').show();});
  $('body').ajaxStop(function(){$('img.spinner').hide();});
  $('body').ajaxError(function(event, xhr, ajaxOptions, thrownError){
      console.log("xhr response: " + JSON.stringify(xhr));
      });
  
  // hide all error and confirm labels
  $('.error').hide();  
  $('.confirm').hide();

  // refresh  mission table if change campagne dropdown
  $('select#campagne').change(function() { 
    //var $form = $('form#mission');
    var camp_id = $('select#campagne').val();
    var uri = "/admin/mission?campagne=" + camp_id;
    
    $.get(uri, function(data) {
        console.log("get succesful");
        //var $table = $(data).find('tbody');
        var $table = $('table.mission tbody', data);
        console.log($table);
        $('tbody').replaceWith($table);
        });

  }); 
  // validate fields before submitting
  $('#submit_btn').click(function() {    
    $('.error').hide();
    var numero = $('input#numero').val();
    if (numero == "") {  // will need to regex int
     $('label#numero_error').show();
     $('input#numero').focus();
     return false; // halt submission if doeasn't validate
     }
    var nom = $('input#nom').val();
    if (nom == "") {  
     $('label#nom_error').show();
     $('input#nom').focus();
     return false; // halt submission if doeasn't validate
     }
     return true;
  });
});