// CLI Links
// by Zarqon
// a super-easy way to execute CLI commands from your relay override script

// CLI dialog box
function cliPopup(prepop) {                                    // open CLI box
  $('#mask').css({'width':$(window).width(),'height':$(document).height()});
  $('#clibox').css('top',  $(window).height()/2 - $('#clibox').height()/2);
  $('#clibox').css('left', $(window).width()/2 - $('#clibox').width()/2);
  $('#mask').fadeTo(0,0.1).fadeIn(1000).fadeTo("slow",0.6);
  $('#clibox').show();
  $('#cliform input:text').focus().val(prepop);
  return false;
}
function cliPopdown() {                                        // close CLI box
  $('#mask').hide();
  $('#clibox').fadeOut('fast');
  return false;
}
function cliComplete(data) {
   $('#clifeedback').html(data).removeClass("clierror").addClass("clisuccess");
   $("#clifeedback:contains('Error')").removeClass("clisuccess").addClass("clierror");
   $('#clifeedback').fadeIn('fast').fadeOut(4000);
   var a = $(this), url = a.attr('href');
//   console.log(this);
//   console.log(a.hasClass('through'));
//   console.log(url);
   if (a.hasClass('through') && url) window.location = url;
}
var oldComplete = cliComplete;    // store this function to make it easy for calling scripts to extend
// wrap our ajax cli_execute()
function cli_execute(cmd, caller) {
   caller = caller || this;
   cliPopdown();
   $.ajax({
      url: 'clilinks.ash',
      data: {cli: cmd},
	  context: caller,
      success: cliComplete
   });
}

jQuery(function($){
  // add content for input dialog and feedback popup
   $('body').append("<div id='clibox'><span style='float: right'><font size=1>[<a href=# class='cliclose'>close</a>]</font></span>"+
      "Enter a CLI command:<p><form id='cliform' action='fight.ash' method=post>"+
      "<input name=cli type=text size=60></form><p><a href='#' class='clilink'>help</a> <a href='#' class='clilink' "+
      "title='ashwiki CLI Reference'>more help</a></div><div id='clifeedback' class='clisuccess'></div><div id='mask' class='cliclose'></div>");
  // style the content
   $('head').append("<style type=\"text/css\">#mask { position: fixed; left:0; top:0; width:100%; height: 100%; display:none; z-index: 999; background-color: #222; } "+
      "#clibox, #clifeedback { position:fixed; display:none; border-width:2px; border-style:solid; background-color:white; font-size:0.9em; padding:10px; z-index:1000; } "+
      "#clifeedback { top: 40px; right: 10px; } .clisuccess { border-color: #080; color: #080; } .clierror { border-color: #800; color:#800; } "+
      ".clilink { font-size:0.7em } .clilink:before { content: \"[\" } .clilink:after { content: \"]\" } .cliimglink { border:0 } </style>");

  // enable the dialog box's form
   $('#cliform').submit(function(e) { e.preventDefault(); cli_execute($('#cliform input:text').val()); });
  // enable closing the dialog
   $('.cliclose').click(function () { return cliPopdown(); });
  // enable CLI Links throughout the document
   $(document).on('click','.clilink, .cliimglink', function(e) {  // enable CLI links; use title if present, otherwise use link text
     var a = $(this),
     cmd = (a.attr('title') == undefined) ? a.text() : a.attr('title');
     if (a.hasClass('edit')) return cliPopup(cmd+' ');      // if 'edit' class, pop up the CLI box prepopulated with cmd
	 cli_execute(cmd, this);
	 return false;
   });
});