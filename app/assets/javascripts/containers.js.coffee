App.ready ->
  $('#container_image_id').on 'change', ->
    $("#env_settings").html $(".image_env_form[data-image-id=#{$(@).val()}]").html()

