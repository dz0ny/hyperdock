class ShowContainerPage
  constructor: (@app) ->
    @container = Page.data.container
    @terminal = term = new App.Terminal('#terminal')
    @setup_terminal_commands()
    @terminal.start()
    @socket = App.ws()
    @terminal.connect_websocket("container_#{@container.id}", 'provisioner')
    @terminal.websocket.bind 'reload', -> location.reload()

  setup_terminal_commands: ->
    @terminal.commands['top'] = =>
      @terminal.term.echo "Retrieving container process data ..."
      @socket.emit 'container.top', { id: @container.id }

    @terminal.commands['info'] = =>
      @terminal.term.echo "Retrieving container info ..."
      @socket.emit 'container.info', { id: @container.id }

App.ready ->
  if /^\/containers\/\d+$/.test(window.location.pathname)
    @show_container_page = new ShowContainerPage(@)

  ##
  # New container dynamic form
  if /^\/containers\/new$/.test(window.location.pathname)
    $('#container_image_id').on 'change', ->
      $("#env_settings").html $(".image_env_form[data-image-id=#{$(@).val()}]").html()

