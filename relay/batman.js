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
   $('#battab').slideUp('fast');
   $('#actbox').animate({ left: -50 },'fast').hide('fast',function() { return killforms(doug); });     // side menu conceal before form submit
   return false;
}

  // functions for (re)loading various sections of the page: Adventure Again box, Blacklist tab, and Wiki tab, respectively
   function refresh_again() {
	   $('#again').load('fight.ash', {dashi: 'annae'});
   }
   function refresh_blacklist(data) {
      if (!data) data = {black: 'get'};
      $('#blacklist').load('BatMan_RE.ash', data);
   }
   function load_wicky() {
      if ($('#wikibox div').length == 0) $('#wikibox').load('fight.ash', {dashi: 'wicky'});
   }
   cliComplete = function(cmd) {                                    // extend cliComplete to refresh the Again box when done
      var ret = oldComplete.apply(this, arguments);
	  refresh_again();
      return ret;
   };

jQuery(function($){
  // show old combat form (for CAB-enabled users)
   $('#fightform').removeClass("hideform").show();

  // animate bat-computer
   for (i=0;i<=8;i++) $('#compimg').animate({opacity: 0.6},700).animate({opacity: 1},400);
   
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

  // initialize/enable tabs
   if ($('#battab').length != 0) {
      $('body').css('margin-bottom','300px');
      $('#battab > div').hide();
      $('#battab div:first').fadeIn('fast');
      $('#battab ul li:first').addClass('active');
      $('#battab ul li a').click(function(){
	     if ($(this).parent().hasClass('active')) return false;   // ignore clicks if already active
         $('#battab ul li.active').removeClass('active');         // remove active from active
         $(this).parent().addClass('active');
		 if ($(this).hasClass('wickytrigger')) load_wicky();
		 if ($(this).hasClass('blacktrigger')) refresh_blacklist();
         var selectedTab = $(this).attr('href');
         $('#battab > div').stop(true,true).fadeOut('fast');
         $(selectedTab).delay(200).fadeIn('fast');
         return false;
      });
   }

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
          'sScrollY': '244px',                                      // vertical scroll, table is 244px high
          'bScrollCollapse': true,                                  // if table data is shorter than 244px, shrink table to fit
          'bPaginate': false,                                       // we scroll instead of paginate
          'bFilter': false,                                         // disable search (for now?)
          'aaSorting': [],                                          // no initial sort, options are already sorted
          'oLanguage': { 'sInfo': '_TOTAL_ possible actions' },
          'bSortClasses': false,                                    // don't bother applying classes to sorted columns
          'aoColumnDefs': [
              { "bVisible": false, "aTargets": [ 9, 10, 11 ] },     // hidden action-type indices (attack, stasis, stun)
              { "sType": "html", "aTargets": [ 5 ] },
              { "sType": "batnum-html", "aTargets": [ 1, 2, 3, 6, 7 ] },
              { "sType": "numeric", "aTargets": [ 9, 10, 11 ] },
              { "sClass": "attackcol", "aTargets": [ 0 ] },         // apply classes to all cells, per row
              { "sClass": "damagecol", "aTargets": [ 1 ] },
              { "sClass": "delevelcol", "aTargets": [ 2, 3 ] },
              { "sClass": "stuncol", "aTargets": [ 4 ] },
              { "sClass": "hpcol", "aTargets": [ 5 ] },
              { "sClass": "mpcol", "aTargets": [ 6 ] },
              { "sClass": "profitcol", "aTargets": [ 7 ] },
              { "sClass": "blackcol", "aTargets": [ 8 ] },
              { "iDataSort": 9, "aTargets": [ 0 ] },                // sort Attack column by hidden index
              { "iDataSort": 11, "aTargets": [ 4 ] },               // sort Stun column by hidden index
              { "aDataSort": [ 6, 7 ], "aTargets": [ 6 ] },         // sort MP column by itself, then profit
              { "asSorting": [ "desc", "asc" ], "aTargets": [ 1, 7 ] },
              { "asSorting": [ "desc" ], "aTargets": [ 5, 6 ] },
              { "asSorting": [ "asc" ], "aTargets": [ 0, 2, 3, 4, 9, 10, 11 ] }
          ]
      } );
      bt.fnSortListener( document.getElementById('attacksort'), 9 );  // use hidden indices for sorting from external links
      bt.fnSortListener( document.getElementById('stasissort'), 10 );
      bt.fnSortListener( document.getElementById('stunsort'), 11 );
	  
     // move a few things
      $('#undermon').insertAfter($('#monname'));
	  $('body').append($('#actbox'));

    // blacklist functions
      $(document).on('click','.addblack', function() {
         refresh_blacklist({black: 'add', id: $(this).attr('title')});
         bt.fnDeleteRow(bt.fnGetPosition($(this).closest("tr").get(0)));
      });
      $(document).on('click','.removeblack', function() {
         refresh_blacklist({black: 'remove', id: $(this).attr('title')});
      });
      $(document).on('click','.editblack', function() {
         var cont = $(this).text();
         $('#blackamt').val($.isNumeric(cont) ? cont : "0");
         $('#blackformbox').slideDown();
         $('#blackid').focus().val($(this).attr('title'));
      });
      $(document).on('submit','#blackform', function() {
         refresh_blacklist($('#blackform').serialize());
		 return false;
      });
      $(document).on('click','.refreshblack', function(event) {        // enable links to reload blacklist
        return refresh_blacklist();  
      });
	  
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
      if (e.keyCode == 27) {                                      // ESC closes blacklist editor/CLI Box
         $('#blackformbox').slideUp();
         return cliPopdown();
      }
      if ($('input,textarea').is(":focus")) return true;          // otherwise, give all keystrokes to inputs when focused
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

});
