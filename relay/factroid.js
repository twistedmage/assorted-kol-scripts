// factroid.js by Zarqon
// jQuery for Factroid.ash

function redeet(dbox) {  // load monster details box
   console.log('Loading details for '+dbox.data('monster')+'.');
   dbox.load('relay_Factroid.ash', 
      { do: 'deets', mon: dbox.data('monster') }, 
      function() { dbox.slideDown(1000); }
   );
}
cliComplete = function(data) {  // extend CLI Links' complete function to reload monster details if fax was requested
   oldComplete.apply(this, arguments);
   if ($(this).hasClass('fax')) redeet($(this).parent());
   return false;
};
var cancan;
jQuery(function($) {
   if (cancan) $(window).on('DOMContentLoaded load resize scroll', function(e) {  // load adventurability for only visible-on-screen locations
      $('.unloaded').each(function(id) {
         var r = this.getBoundingClientRect();
         if (r.top >= 0 && r.top <= (window.innerHeight || document.documentElement.clientHeight)) {
            var caller = $(this); 
            caller.removeClass('unloaded');
            $.post(cancan, { where: caller.data('location'), verb: '9' }, function(data) {
               caller.html(data == 'available' ? '<a href='+caller.data('url')+'><img src="images/itemimages/rightarrow.gif" title="Adventure at '+
                  caller.data('location')+'" height=17 width=17 style="vertical-align: middle"></a>' :
                 '<img class=dimmed src="images/itemimages/hardcorex.gif" title="This location is currently unavailable." height=17 width=17 style="vertical-align: middle">');
            });
         }
      });
   });
   $(document).on('click','.montile .mon', function(e) {  // handle ajaxing monster details box
      var dbox = $(this).siblings('.deets');
      if (this.width == 40) {
         $(this).stop().animate({width: this.naturalWidth, height: this.naturalHeight}, 1000);
         if (dbox.text() == '') redeet(dbox);
          else dbox.slideDown(1000);
      } else {
         $(this).stop().animate({width: '40', height: '40'}, 1000);
         dbox.slideUp(1000);
      }
      return false;
   });
});
