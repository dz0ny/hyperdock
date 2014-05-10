window.App = {
  ready: function(cb){
    $(document).ready(cb);
    $(document).on('page:load', cb);
  }
};

App.ready(function() {
  $('select').select2();
});
