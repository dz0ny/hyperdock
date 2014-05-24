#= require jquery.terminal/js/jquery.terminal-0.8.7.js

App.Terminal = class Terminal
  constructor: (selector, ws, ch, ev) ->
    @$el = $(selector)
    @term = @$el.terminal @commands,
      greetings: @greetz
      name: "HDTerm"
      height: 200
      prompt: "~> "
    console.log("test")
    unless ws.already_subscribed_to(ch)
      ws.subscribe(ch).bind ev, @handle_json
      ws.on_open = (data) =>
        console.log "Connected to #{ch}"
        @term.echo "Websockets connected on channel #{ch} and listening for #{ev} events."

  handle_json: (e) =>
    switch e.event
      when 'start' then @term.clear()
      when 'exit'
        m = "Process existed with status #{code}"
        if e.status == 0 then @term.echo(m) else @term.error(m)
      when 'stderr' then @term.error e.message
      when 'exception'
        @term.error ex.class
        @term.error ex.message
        @term.error msg for msg in ex.backtrace
      when 'stdout' then @term.echo e.message

  greetz: """
    Welcome to the wire terminal.
    Kickass terminal emulation powered by https://github.com/jcubic/jquery.terminal 
    """

  commands:
    echo: (arg1) -> @echo arg1
    help: -> @greetings()
