App.ready ->
  if /^\/hosts\/\d+$/.test(window.location.pathname)
    ws = @ws()
    host_id = window.location.pathname.split('/')[2]
    ch = "host_#{host_id}"
    if host_id? && !ws.already_subscribed_to(ch)
      ws.subscribe(ch).bind 'provisioner', (data) ->
        console.log data
      console.log("subscribed to channel #{ch}")
