class ShowContainerPage
  constructor: (@app) ->
    @container = Page.data.container
    @terminal = term = new App.Terminal('#terminal')
    @terminal.start()
    @terminal.connect_websocket("container_#{@container.id}", 'provisioner')
    @terminal.websocket.bind 'reload', ->
      console.log("RELOAD")
      location.reload()

App.ready ->
  if /^\/containers\/\d+$/.test(window.location.pathname)
    @show_container_page = new ShowContainerPage(@)

  ##
  # New container dynamic form
  $('#container_image_id').on 'change', ->
    $("#env_settings").html $(".image_env_form[data-image-id=#{$(@).val()}]").html()

