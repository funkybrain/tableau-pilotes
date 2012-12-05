$(function(){
  
  // highlight correct navigation tab  
  $('div.tabnav').attr({'id':'tab3'});
    
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

  // refresh revendication mission dropdown if change mission dropdown
  // $('form#mission select[name="choix_mission"]').change(function() {
  //  var option = $(this).val();
  //  $('form#revendication select').val(option);
  // });
    
  // change victoire type based on revendication
  // only victoire aeriennes should have choices other than 'confirmee'
  // $('select.revendication').change(function() { 
  //   var rev_id = $('this').val();
  //   var option = $('<option></option>').attr("value", "1").text("Confirme");
  //   if (rev_id !==1) {
  //     $('select#victoire').empty().append(option);
  //   };
  //   // todo: reset to default values if rev_id === 1
  // });


    $('a#add').click(function(e){
            e.preventDefault();
            var $revendication = $('form#revendication li.revendication:first');
            var $newrow = $revendication.clone()
            $('a#add', $newrow).remove();
            //$newrow.find('input[type="text"]').val(""); // reset text field
            
            $('form#revendication ol').append($newrow);
            //$task.find('input[type="text"]').focus();
            // return false
    });
    // start with three tasks
    //$('a#add').click().click();

    //$('input.textfield:first').focus();
});