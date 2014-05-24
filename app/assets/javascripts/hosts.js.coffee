App.ready ->
  if /^\/hosts\/\d+$/.test(window.location.pathname)
    host_id = window.location.pathname.split('/')[2]
    ch = "host_#{host_id}"
    if host_id? && !@ws().already_subscribed_to(ch)
      @terminal = new App.Terminal('#terminal')
      @ws().subscribe(ch).bind 'provisioner', @terminal.handle
