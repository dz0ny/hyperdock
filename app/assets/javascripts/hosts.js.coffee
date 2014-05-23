App.ready ->
  $('a#reprovision').on 'click', (e) ->
    $(e.target).replaceWith('ok well i can kick off the job but setup eventbus or sse or what?')
