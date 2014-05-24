App.ready ->
  btn = $('#reprovision_host')

  if btn.length == 1
    @terminal = new App.Terminal('#terminal', @ws(), "host_#{btn.data('id')}", 'provisioner')

    btn.click ->
      $.get("#{btn.data('url')}?password=#{$('#root_password').val()}")
      return false
