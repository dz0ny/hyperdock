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
    this.dispatcher = new WebSocketRails(Page.socket);
    // Add some helpers
    this.dispatcher.already_subscribed_to = function(ch) {
      return typeof this.channels[ch] !== 'undefined';
    }
    // Wrapper around `trigger` that auths the user
    this.dispatcher.emit = function(route, data) {
      if (typeof data === "undefined") data = {};
      data.user_token = Page.user_token;
      this.dispatcher.trigger(route, data);
      return false;
    }.bind(this)
  }
  return this.dispatcher;
}
