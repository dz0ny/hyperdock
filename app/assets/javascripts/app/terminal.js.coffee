#= require jquery.terminal/js/jquery.terminal-0.8.7.js

App.Terminal = class Terminal
  constructor: (selector) ->
    @$el = $(selector)
    @connected = false
    @term = @$el.terminal @handle_user,
      greetings: "",
      name: "HDTerm"
      height: 200
      prompt: "~> "

  stderr: (msg) -> @term.error msg

  stdout: (msg) -> @term.echo msg

  clear: -> @term.clear()

  exit: (code) ->
    if code == 0
      @stdout "Process completed successfully."
    else
      @stderr "Process exited with status #{code}"

  handle_json: (e) =>
    switch e.event
      when 'start' then @clear()
      when 'exit' then @exit(e.status)
      when 'stderr' then @stderr e.message
      when 'stdout' then @stdout e.message

  handle_user: (command, term) =>
    if not @connected
      term.error("STDIN is not connected.")
