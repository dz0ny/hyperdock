#= require jquery.terminal/js/jquery.terminal-0.8.7.js

App.Terminal = class Terminal
  constructor: (selector, @ws, @ch, @ev) ->
    @$el = $(selector)
    @supported_modes = ['predefined'] # we're still working on STDIN, when ready add 'websocket'
    @mode 'predefined'
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

  greetz: """
    Welcome to the wire terminal.
    Kickass terminal emulation powered by https://github.com/jcubic/jquery.terminal 
    """

  setup: (handler) ->
    @term = @$el.terminal handler,
      greetings: @greetz
      name: "HDTerm"
      height: 200
      prompt: "~> "
    @term.hd_term = @

  ##
  # Switch input mode
  # predefined -- use predefined commands in @commands hash
  # websocket -- forward all input over websockets
  mode: (mode) ->
    return mode if @current_mode == mode
    if mode not in @supported_modes
      throw new Error("Supported modes: #{@supported_modes.join(', ')}")
    @term?.destroy()
    switch mode
      when 'predefined' then @setup @predefined_commands
      when 'websocket' then @setup @websocket_input_handler
    @current_mode = mode

  predefined_commands:
    echo: (arg1) -> @echo arg1
    help: -> @greetings()
    mode: (arg1) -> @hd_term.mode(arg1)
    modes: -> @echo @hd_term.supported_modes.join(', ')

  websocket_input_handler: (input) =>
    return unless input.length > 0
    parts = input.split(' ')
    if parts[0] == "mode" and (parts[1] in @supported_modes)
      @mode parts[1]
    else
      @ws.channels[@ch].trigger 'input', message: input

