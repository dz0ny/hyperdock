class ShowHostPage
  constructor: (@app) ->
    @host = Page.data.host
    @terminal = term = new App.Terminal('#terminal')
    @setup_terminal_commands()
    @socket = @app.ws()
    @terminal.start()
    @terminal.connect_websocket("host_#{@host.id}", 'provisioner')

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
          @socket.emit "sensu.list_checks", { id: @host.id }

    else
      @terminal.commands['containers'] = =>
        @socket.emit "host.list_containers", { id: @host.id }

      @terminal.commands['info'] = =>
        @socket.emit 'host.get_host_info', { id: @host.id }

App.ready ->
  if /^\/hosts\/\d+$/.test(window.location.pathname)
    @show_host_page = new ShowHostPage(@)

