class ShowHostPage
  TERM_HEIGHT = 60
  TERM_HEIGHT_BIG = 400

  constructor: (@app) ->
    @host_id = Page.data.host.id
    @terminal = term = new App.Terminal('#terminal', TERM_HEIGHT)
    @setup_terminal_commands()
    @setup_terminal_ui()
    @socket = @app.ws()
    term.connect_websockets(@socket, "host_#{@host_id}", 'provisioner')
    term.start()

  setup_terminal_ui: ->
    $('#rollup-terminal').click (e) =>
      if @terminal.height() == TERM_HEIGHT
        @terminal.height TERM_HEIGHT_BIG
      else
        @terminal.height TERM_HEIGHT
      icon = $($(e.target).find('i').context)
      icon.toggleClass('glyphicon-chevron-up').toggleClass('glyphicon-chevron-down')
      term.scroll_to_bottom()
      return false

  setup_terminal_commands: ->
    @terminal.commands['provision'] = (password) =>
      @socket.emit 'host.provision', { id: @host_id, password: password }

    @terminal.commands['reset_known_hosts'] = =>
      @socket.emit "host.reset_known_hosts", { id: @host_id }

    @terminal.commands['containers'] = =>
      @socket.emit "host.list_containers", { id: @host_id }

    @terminal.commands['info'] = =>
      @socket.emit 'host.get_host_info', { id: @host_id }

App.ready ->
  if /^\/hosts\/\d+/.test(window.location.pathname)
    @show_host_page = new ShowHostPage(@)

