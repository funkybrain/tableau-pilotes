$(function(){
    
    $('div.tabnav').attr({'id':'tab3'});
    
    $('a#add').click(function(e){
            e.preventDefault();
            var $revendication = $('form li.revendication:first');
            var $newrow = $revendication.clone()
            $('a#add', $newrow).remove();
            //$newrow.find('input[type="text"]').val(""); // reset text field
            console.log($newrow);
            $('form ol').append($newrow);
            //$task.find('input[type="text"]').focus();
            // return false
    });
    // start with three tasks
    //$('a#add').click().click();

    //$('input.textfield:first').focus();
});