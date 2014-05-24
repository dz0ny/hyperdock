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
    this.dispatcher = new WebSocketRails("localhost:3000/websocket");
    // Add some helpers
    this.dispatcher.already_subscribed_to = function(ch) {
      return typeof this.channels[ch] !== 'undefined';
    }
  }
  return this.dispatcher;
}
