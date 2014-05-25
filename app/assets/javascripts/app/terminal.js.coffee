#= require jquery.terminal/js/jquery.terminal-0.8.7.js

App.Terminal = class Terminal
  constructor: (selector, @ws, @ch, @ev) ->
    @$el = $(selector)
    @setup @commands
    unless @ws.already_subscribed_to(ch)
      @ws.subscribe(ch).bind ev, @handle_json
      @ws.on_open = (data) =>
        console.log "Connected to #{@ch}"
        @term.echo "Websockets connected on channel #{@ch} and listening for #{@ev} events."

  handle_json: (e) =>
    switch e.event
      when 'start' then @term.clear()
      when 'exit'
        m = "Process exited with status #{e.status}"
        if e.status == 0 then @term.echo(m) else @term.error(m)
      when 'stderr' then @term.error e.message
      when 'stdout' then @term.echo e.message

  setup: (handler) ->
    @term = @$el.terminal handler,
      greetings: "",
      name: "HDTerm"
      height: 200
      prompt: "~> "

  commands:
    echo: (arg1) -> @echo arg1

