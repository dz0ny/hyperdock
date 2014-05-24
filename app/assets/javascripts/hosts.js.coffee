App.ready ->
  already_subscribed_to = (ch) -> return App.ws().channels[ch]?
  host_id = $('#host_id').val()
  ch = "host_#{host_id}"
  if host_id? && !already_subscribed_to(ch)
    @ws().subscribe(ch).bind 'provisioner', (data) ->
      console.log data
    console.log("subscribed to channel #{ch}")
