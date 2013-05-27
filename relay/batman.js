// Batman.js -- for BatMan Relay
// http://kolmafia.us/showthread.php?10042

function goodNum(n) {
   var res = n.match(/Dealt:&nbsp;(.+?)\)/);
   if (res !== null) return parseFloat(res[1]);                  // first, if (Dealt: N) exists, return N
   res = n.replace( /(\(.*?\))|(\<.*?\>)/g, "" );                // strip anything in brackets or parentheses (incl. numbers)
   return parseFloat(res.match(/\d/) ? res.replace( /[^\d\-\.]/g, "" ) : 0);
}

jQuery.fn.dataTableExt.oSort['batnum-html-asc']  = function(a,b) {
   if (a == "") return (b == "") ? 0 : 1;           // empties are always sorted down, regardless of asc/desc
   if (b == "") return (a == "") ? 0 : -1;
   var x = goodNum(a);
   var y = goodNum(b);
   return ((x < y) ? -1 : ((x > y) ?  1 : 0));
};
 
jQuery.fn.dataTableExt.oSort['batnum-html-desc'] = function(a,b) {
   if (a == "") return (b == "") ? 0 : 1;
   if (b == "") return (a == "") ? 0 : -1;
   var x = goodNum(a);
   var y = goodNum(b);
   return ((x < y) ?  1 : ((x > y) ? -1 : 0));
};

function bjilgt(doug) {
   $('#actbox').animate({ left: -50 },'fast').hide('fast',function() { return killforms(doug); });     // side menu conceal before form submit
   return false;
}

jQuery(document).ready(function($){
  // show old combat form (for CAB-enabled users)
   $('#fightform').removeClass("hideform").show();

  // animate bat-computer
   for (i=0;i<=5;i++) $('#compimg').animate({opacity: 0.6},500).animate({opacity: 1},300);

  // register handlers for the side menu
   var timeout;
   function tfadeIn(popup) {
      clearTimeout(timeout);                                      // cancel the fadeout timer
      popup.siblings('.popout').fadeOut('fast');                  // ensure other popups fade out
      popup.stop(true,true).fadeIn();                             // reveal the popup
   }
   function tfadeOut(popup) { timeout = setTimeout(function () {  // set timer to fadeout
      popup.stop(true,true).fadeOut(); }, 300);
   }
   $(document).on({
      mouseenter: function(){
         $(this).next().css('top',$(this).position().top + 40);   // move the popup to the same Y-coord
         $(this).stop().animate({ width: 36 },200);               // slide out the menu a bit
         tfadeIn($(this).next());
      },
      mouseleave: function(){
         tfadeOut($(this).next());
         $(this).stop().animate({ width: 28 },600);
      }
   },".onemenu");
   $(document).on({
      mouseenter: function(){ tfadeIn($(this)); },
      mouseleave: function(){ tfadeOut($(this)); }
   },".popout");
   
  // populate Adventure Again info box
   function refresh_again() {
      $('#again').load('fight.ash', {dashi: 'annae'});
   }

  // CLI Empowerment!
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
   function cli_execute(cmd) {
     $.ajax({
        url: 'fight.ash',
        data: {cli: cmd},
        success: function(data) {                                 // build and show success/failure
          $('#clifeedback').html(data).removeClass("clierror").addClass("clisuccess");
          $("#clifeedback:contains('Error')").removeClass("clisuccess").addClass("clierror");
          $('#clifeedback').fadeIn('fast').fadeOut(4000);
          refresh_again();
        }
     });
     return cliPopdown();
   }
   $('#cliform').submit(function(e) { return cli_execute($('#cliform input:text').val()); });
   $('.cliclose').click(function () { return cliPopdown(); });
   $(document).on('click','.clilink', function(event) {           // enable CLI links; use title if present, otherwise use link text
     var cmd = ($(this).attr('title') == undefined) ? $(this).text() : $(this).attr('title');
     if ($(this).hasClass('edit')) return cliPopup(cmd+' ');      // if 'edit' class, pop up the CLI box prepopulated with cmd
     return cli_execute(cmd);                                     // otherwise, execute cmd
   });

   function slide_actbox() {
      $('#actbox').show(0).animate({ left: -10 },600);     // side menu reveal on ajax load
      refresh_again();
   }
   if ($('#actbox').length != 0) {
      slide_actbox();
   } else $('#bat-enhance').load('BatMan_RE.ash', {page: $('html').html()}, function() {
      slide_actbox();
     // define our ridiculously awesome Actions Table
      var bt = $('#battable').dataTable( {
          'sScrollY': '240px',                                      // vertical scroll, table is 240px high
          'bScrollCollapse': true,                                  // if table data is shorter than 240px, shrink table to fit
          'bPaginate': false,                                       // we scroll instead of paginate
          'bFilter': false,                                         // disable search (for now?)
          'aaSorting': [],                                          // no initial sort, options are already sorted
          'oLanguage': { 'sInfo': '_TOTAL_ possible actions' },
          'bSortClasses': false,                                    // don't bother applying classes to sorted columns
          'aoColumnDefs': [
              { "bVisible": false, "aTargets": [ 8, 9, 10 ] },      // hidden action-type indices (attack, stasis, stun)
              { "sType": "html", "aTargets": [ 5 ] },
              { "sType": "batnum-html", "aTargets": [ 1, 2, 3, 6, 7 ] },
              { "sType": "numeric", "aTargets": [ 8, 9, 10 ] },
              { "sClass": "attackcol", "aTargets": [ 0 ] },         // apply classes to all cells, per row
              { "sClass": "damagecol", "aTargets": [ 1 ] },
              { "sClass": "delevelcol", "aTargets": [ 2, 3 ] },
              { "sClass": "stuncol", "aTargets": [ 4 ] },
              { "sClass": "hpcol", "aTargets": [ 5 ] },
              { "sClass": "mpcol", "aTargets": [ 6 ] },
              { "sClass": "profitcol", "aTargets": [ 7 ] },
              { "iDataSort": 8, "aTargets": [ 0 ] },                // sort Attack column by hidden index
              { "iDataSort": 10, "aTargets": [ 4 ] },               // sort Stun column by hidden index
              { "aDataSort": [ 6, 7 ], "aTargets": [ 6 ] },         // sort MP column by itself, then profit
              { "asSorting": [ "desc", "asc" ], "aTargets": [ 1, 7 ] },
              { "asSorting": [ "desc" ], "aTargets": [ 5, 6 ] },
              { "asSorting": [ "asc" ], "aTargets": [ 0, 2, 3, 4, 8, 9, 10 ] }
          ]
      } );
      bt.fnSortListener( document.getElementById('attacksort'), 8 );   // use hidden indices for sorting from external links
      bt.fnSortListener( document.getElementById('stasissort'), 9 );
      bt.fnSortListener( document.getElementById('stunsort'), 10 );

     // move monster info div after the monster name
      $('#undermon').insertAfter($('#monname'));
	  
     // enhance Manuel
      if ($('#manuelbox').length != 0) { 
         if ($('#manuelcell').length == 0) {                      // add empty manuel cell for players without Manuel
            $('#nowfighting').append('<td width=30></td><td id="manuelcell"></td>');
         }
	     $('#manuelcell').html($('#manuelbox'));
	  }
   });

  // register hotkeys if no CAB
   if ($('table.actionbar').length == 0) $(document).keypress(function(e) {
      if ($('input,textarea').is(":focus")) {
         if (e.keyCode == 27) return cliPopdown();                // ESC closes the CLI box
         return true;                                             // otherwise, give all keystrokes to inputs when focused
      }
//      alert(e.keyCode);
      switch(e.keyCode) {
         case 96: if ($('#actbox form:first').length == 0) {      // ` key submits first menu (for blasting through)
            $('#actbox img:first').click();
           } else $('#actbox form:first').submit();
           break;
         case 49:
         case 50:
         case 51:
         case 52:
         case 53: $('.onemenu:eq('+(e.keyCode-48)+') form:first').submit(); break;  // 1-5 keys submit 2nd-6th menus
         case 48: return cliPopup('');                            // 0 key opens CLI box
      }
   });

} );
