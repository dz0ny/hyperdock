class ShowHostPage
  TERM_HEIGHT = 60
  TERM_HEIGHT_BIG = 400

  constructor: (@app) ->
    @host = Page.data.host
    @terminal = term = new App.Terminal('#terminal', TERM_HEIGHT)
    @setup_terminal_commands()
    @setup_terminal_ui()
    @socket = @app.ws()
    @terminal.start()
    @terminal.connect_websocket(@socket, "host_#{@host.id}", 'provisioner')

  setup_terminal_ui: ->
    $('#rollup-terminal').click (e) =>
      if @terminal.height() == TERM_HEIGHT
        @terminal.height TERM_HEIGHT_BIG
      else
        @terminal.height TERM_HEIGHT
      icon = $($(e.target).find('i').context)
      icon.toggleClass('glyphicon-chevron-up').toggleClass('glyphicon-chevron-down')
      @terminal.scroll_to_bottom()
      return false

  setup_terminal_commands: ->
    @terminal.commands['provision'] = =>
      @socket.emit 'host.provision', { id: @host.id, password: '' }

    @terminal.commands['reset_known_hosts'] = =>
      @socket.emit "host.reset_known_hosts", { id: @host.id }

    if @host.is_monitor
      @terminal.commands['kibana'] =
        open: =>
          url = "https://kibana.#{@host.name}.#{Page.fqdn}/index.html#/dashboard/file/logstash.json"
          window.open url, "_blank" ; false

      @terminal.commands['sensu'] =
        open: =>
          url = "https://sensu.#{@host.name}.#{Page.fqdn}/"
          window.open url, "_blank" ; false

        checks: =>
          @socket.emit "monitor.list_checks", { id: @host.id }

    else
      @terminal.commands['containers'] = =>
        @socket.emit "host.list_containers", { id: @host.id }

      @terminal.commands['info'] = =>
        @socket.emit 'host.get_host_info', { id: @host.id }

App.ready ->
  if /^\/hosts\/\d+$/.test(window.location.pathname)
    @show_host_page = new ShowHostPage(@)

