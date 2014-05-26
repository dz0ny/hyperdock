class ShowHostPage
  TERM_HEIGHT = 60
  TERM_HEIGHT_BIG = 400

  constructor: (@app) ->
    @host_id = Page.data.host.id
    @terminal = term = new App.Terminal('#terminal', TERM_HEIGHT)
    @extend_terminal()

    $('#rollup-terminal').click (e) =>
      if @terminal.height() == TERM_HEIGHT
        @terminal.height TERM_HEIGHT_BIG
      else
        @terminal.height TERM_HEIGHT
      icon = $($(e.target).find('i').context)
      icon.toggleClass('glyphicon-chevron-up').toggleClass('glyphicon-chevron-down')
      term.scroll_to_bottom()
      return false

    term.connect_websockets(@app.ws(), "host_#{@host_id}", 'provisioner')
    term.start()

  extend_terminal: ->
    @terminal.commands['provision'] = (password) =>
      @app.ws().trigger 'host.provision',
        id: @host_id
        password: password
      false

    @terminal.commands['reset_known_hosts'] = =>
      @app.ws().trigger "host.reset_known_hosts",
        id: @host_id
      false

App.ready ->
  if /^\/hosts\/\d+/.test(window.location.pathname)
    @show_host_page = new ShowHostPage(@)

