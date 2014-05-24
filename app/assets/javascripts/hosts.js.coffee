class Terminal
  constructor: (selector) ->
    @$el = $(selector)

  stderr: (msg) ->
    @$el.append "<span>#{msg}</span><br>"

  stdout: (msg) ->
    @$el.append "<span>#{msg}</span><br>"

  clear: ->
    @$el.empty()

  exit: (code) ->
    if code == 0
      @stdout "Process completed successfully."
    else
      @stderr "Process exited with status #{code}"


  handle: (e) =>
    switch e.event
      when 'start' then @clear()
      when 'exit' then @exit(e.status)
      when 'stderr' then @stderr e.message
      when 'stdout' then @stdout e.message


App.ready ->
  if /^\/hosts\/\d+$/.test(window.location.pathname)
    host_id = window.location.pathname.split('/')[2]
    ch = "host_#{host_id}"
    if host_id? && !@ws().already_subscribed_to(ch)
      @terminal = new Terminal('#terminal')
      @ws().subscribe(ch).bind 'provisioner', @terminal.handle
