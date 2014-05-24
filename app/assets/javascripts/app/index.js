window.App = {
  ready: function(cb){
    $(document).ready(cb.bind(this));
    $(document).on('page:load', cb.bind(this));
  }
};

App.ready(function() {
  $('select').select2();
});

App.ws = function() {
  if (typeof this.dispatcher === 'undefined') {
    return this.dispatcher = new WebSocketRails("localhost:3000/websocket");
  } else {
    return this.dispatcher;
  }
}
