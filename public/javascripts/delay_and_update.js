function delay_update()
{
    setInterval("update_click()", 3000);
   // setTimeout("update_click()", 3000);
}

function update_click()
{
   var btnSubmitTags =  document.getElementById("comment_update");
   //alert(btnSubmitTags.value);
   // Programmatically click the submit button in update
   btnSubmitTags.click();
  
}
