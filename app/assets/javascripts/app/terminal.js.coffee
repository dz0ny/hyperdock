#= require jquery.terminal/js/jquery.terminal-0.8.7.js

App.Terminal = class Terminal
  TERM_HEIGHT = 60
  TERM_HEIGHT_BIG = 400

  constructor: (selector, @current_height=TERM_HEIGHT) ->
    @$el = $(selector)
    @bind_height_toggle()

  height: (h) ->
    if h?
      @term.height(h)
      @current_height = h
    @current_height

  handle_json: (e) =>
    switch e.event
      when 'start'
        @term.pause() # disable prompt
      when 'exit'
        m = "Process exited with status #{e.status}"
        if e.status == 0 then @term.echo(m) else @term.error(m)
        @term.resume()
      when 'stderr' then @term.error e.message
      when 'stdout' then @term.echo e.message

  setup: (handler) ->
    @term = @$el.terminal handler,
      greetings: "",
      height: @current_height,
      name: "HDTerm"
      prompt: "~> "
      checkArity: false
    @term.pause()

  connect_websocket: (@ch, @ev) ->
    ws = App.ws()
    unless ws.already_subscribed_to(@ch)
      @websocket = ws.subscribe(@ch)
      @websocket.bind @ev, @handle_json
      ws.on_open = (data) =>
        clearInterval(@reconnect_interval) if @reconnect_interval?
        @term.resume()
      ws.bind 'connection_closed', (data) =>
        @term.pause()
        clearInterval(@reconnect_interval) if @reconnect_interval?
        @reconnect_interval = setInterval ws.reconnect, 5000

  scroll_to_bottom: ->
    @term.scroll(Math.pow(9,9))

  start: ->
    @setup @commands

  commands: {}
    # Example command: 
    # echo: (arg1) -> @echo arg1

  bind_height_toggle: ->
    $('#rollup-terminal').click (e) =>
      if @height() == TERM_HEIGHT
        @height TERM_HEIGHT_BIG
      else
        @height TERM_HEIGHT
      icon = $($(e.target).find('i').context)
      icon.toggleClass('glyphicon-chevron-up').toggleClass('glyphicon-chevron-down')
      @scroll_to_bottom()
      return false
