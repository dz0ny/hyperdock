App.ready ->
  btn = $('#reprovision_host')

  if btn.length == 1
    ch = "host_#{btn.data('id')}"
    unless @ws().already_subscribed_to(ch)
      @terminal = new App.Terminal('#terminal')
      console.log @terminal
      @ws().subscribe(ch).bind 'provisioner', @terminal.handle
      console.log "Connected to #{ch}"

    btn.click ->
      $.get("#{btn.data('url')}?password=#{$('#root_password').val()}")
      return false
