// Batman.js -- for BatMan Relay
// http://kolmafia.us/showthread.php?10042

function goodNum(n) {
   var res = n.match(/Dealt:&nbsp;(.+?)\)/);
   if (res !== null) return parseFloat(res[1]);                  // first, if (Dealt: N) exists, return N
   res = n.replace( /(\(.*?\))|(\<.*?\>)/g, "" );                // strip anything in brackets or parentheses (incl. numbers)
   return parseFloat(res.match(/\d/) ? res.replace( /[^\d\-\.]/g, "" ) : 0);
}

jQuery.extend( jQuery.fn.dataTableExt.oSort, {
   "batnum-html-asc": function ( a, b ) {
      if (a == "") return (b == "") ? 0 : 1;           // empties are always sorted down, regardless of asc/desc
      if (b == "") return (a == "") ? 0 : -1;
      var x = goodNum(a);
      var y = goodNum(b);
      return ((x < y) ? -1 : ((x > y) ?  1 : 0));
   },
   "batnum-html-desc": function ( a, b ) {
      if (a == "") return (b == "") ? 0 : 1;
      if (b == "") return (a == "") ? 0 : -1;
      var x = goodNum(a);
      var y = goodNum(b);
      return ((x < y) ?  1 : ((x > y) ? -1 : 0));
   }
});

function bjilgt(doug) {
   $('#battab').slideUp('fast');
   $('#actbox').animate({ left: -50 },'fast').hide('fast',function() { return killforms(doug); });     // side menu conceal before form submit
   return false;
}

  // functions for (re)loading various sections of the page: Adventure Again box, Blacklist tab, and Wiki tab, respectively
   function refresh_again() {
      $('#again').load('fight.ash', {dashi: 'annae'});
      $('#srhelper').load('fight.ash', {turnflag: turncount, dashi: 'sera'});     // also reload semirare helper here
   }
   function refresh_blacklist(data) {
      if (!data) data = {black: 'get'};
      $('#blacklist').load('BatMan_RE.ash', data);
   }
   function load_wicky() {
      if ($('#wikibox div').length == 0) $('#wikibox').load('fight.ash', {dashi: 'wicky'});
   }
   cliComplete = function(data) {                                  // extend cliComplete to refresh the Again box when done
      oldComplete.apply(this, arguments);
      refresh_again();
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
  // elements helper
   $(document).on({
      mouseenter: function(){ $('#elementhelper').stop().fadeIn(); },
      mouseleave: function(){ $('#elementhelper').stop().fadeOut(); }
   },".showelements");

  // initialize/enable tabs
   if ($('#battab').length != 0) {
      if ($('div.content').length == 0) $('body').css('margin-bottom','310px');
       else $('div.content').append('<p><img src="/images/otherimages/spacer.gif" width=1 height=310>');
      //css('bottom',$('#battab').position().top+40);
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
//      alert('actbox length > 0');
   } else $('#bat-enhance').load('BatMan_RE.ash', {turnflag: turncount, page: $('html').html()}, function() {
      slide_actbox();
     // define our ridiculously awesome Actions Table
      var bt = $('#battable').DataTable( {
          'scrollY': '244px',                                       // vertical scroll, table is 244px high
          'scrollCollapse': true,                                   // if table data is shorter than 244px, shrink table to fit
          'paging': false,                                          // we scroll instead of paginate
          'order': [],                                              // no initial sort, options are already sorted
          'language': {
             'info': '_TOTAL_ possible actions',
             'search': '<img src="/images/itemimages/magnify.gif" title="Filter (press 9 to give focus)" height=16 width=16> ',
             'zeroRecords': 'No matching actions found'
          },
          'orderClasses': false,                                    // don't bother applying classes to sorted columns
          'columnDefs': [
              { "visible": false, "targets": [ 9, 10, 11, 12 ] },   // hidden action-type indices (attack, stasis, stun)
              { "type": "batnum-html", "targets": [ 1, 2, 3, 5, 6, 7 ] },
              { "type": "html-num-fmt", "targets": [ 4 ] },
              { "type": "numeric", "targets": [ 9, 10, 11 ] },
              { "className": "attackcol", "targets": [ 0 ] },       // apply classes to all cells, per row
              { "className": "damagecol", "targets": [ 1 ] },
              { "className": "delevelcol", "targets": [ 2, 3 ] },
              { "className": "stuncol", "targets": [ 4 ] },
              { "className": "hpcol", "targets": [ 5 ] },
              { "className": "mpcol", "targets": [ 6 ] },
              { "className": "profitcol", "targets": [ 7 ] },
              { "className": "blackcol", "targets": [ 8 ] },
              { "orderData": 9, "targets": [ 0 ] },                 // sort Attack column by hidden index
//              { "orderData": 11, "targets": [ 4 ] },                // sort Stun column by hidden index
//              { "aDataSort": [ 6, 7 ], "targets": [ 6 ] },          // sort MP column by itself, then profit
              { "orderSequence": [ "desc", "asc" ], "targets": [ 1, 7 ] },
              { "orderSequence": [ "desc" ], "targets": [ 4, 6 ] },
              { "orderSequence": [ "asc" ], "targets": [ 0, 2, 3, 5, 9, 10, 11 ] }
          ]
      } );
      bt.order.listener( document.getElementById('attacksort'), 9 );  // use hidden indices for sorting from external links
      bt.order.listener( document.getElementById('stasissort'), 10 );
      bt.order.listener( document.getElementById('stunsort'), 11 );

     // enable ENTER submitting the first action listed -- only when the table has been filtered to a single action
      bt.on('draw.dt', function () {
         if (bt.rows({filter: 'applied'}).count() == 1) $('#battable_filter label input').addClass('goodtogo');
          else $('#battable_filter label input').removeClass('goodtogo');
      });
      $(document).on('keyup','input.goodtogo', function(e) {
         if (e.keyCode === 13) { bjilgt(this); $('#battable form.butt:first').submit(); }  // 13 = ENTER
      });

     // move a few things
      $('#undermon').insertAfter($('#monname'));
      $('body').append($('#actbox'));

     // blacklist functions
      $(document).on('click','.addblack', function() {
         refresh_blacklist({black: 'add', id: $(this).attr('title')});
         bt.row($(this).closest("tr")).remove().draw();
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
            $('#monsterpic').closest('tr').append('<td width=30></td><td id="manuelcell"></td>');
         }
         $('#manuelcell').html($('#manuelbox'));
      }
   });

  // register hotkeys if no CAB
   if ($('table.actionbar').length == 0) $(document).on('keypress', function(e) {
      if (e.keyCode == 27) {                                      // ESC closes blacklist editor/CLI Box
         $('#blackformbox').slideUp();
         return cliPopdown();
      }
//      if ($('input.goodtogo').is(":focus")) alert(e.keyCode);
      if ($('input,textarea').is(":focus")) return true;          // otherwise, give all keystrokes to inputs when focused
//      alert(e.keyCode);
      if ($('#actbox').length != 0) switch (e.keyCode) {
         case 96: bjilgt($('#actbox img:first'));
            if ($('#actbox form:first').length == 0 || $('#actbox form:first').attr('name') == 'disablebatman') {  // ` key submits first menu (for blasting through)
               $('#actbox img:first').click();
            } else $('#actbox form:first').submit();
            break;
         case 49:
         case 50:
         case 51:
         case 52:
         case 53: $('.onemenu:eq('+(e.keyCode-48)+') form:first').submit(); break;  // 1-5 keys submit 2nd-6th menus
         case 57: if ($('#battable_filter').is(":visible")) $('#battable_filter label input').focus(); return false; // 9 key gives focus to filter
         case 48: return cliPopup('');                            // 0 key opens CLI box
         case 101: $('#elementhelper').stop().fadeIn().fadeOut(1200); return true;      // 'E' key pops up element helper
      }
   });

});