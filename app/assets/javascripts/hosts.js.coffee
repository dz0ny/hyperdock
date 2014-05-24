App.ready ->
  if /^\/hosts\/\d+$/.test(window.location.pathname)
    host_id = window.location.pathname.split('/')[2]
    already_subscribed_to = (ch) -> return App.ws().channels[ch]?
    console.log(window.lo
    ch = "host_#{host_id}"
    if host_id? && !already_subscribed_to(ch)
      @ws().subscribe(ch).bind 'provisioner', (data) ->
        console.log data
      console.log("subscribed to channel #{ch}")
