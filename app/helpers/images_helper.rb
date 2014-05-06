module ImagesHelper
  def simplify_image_port_bindings input
    JSON.parse("{#{input}}").keys.join(', ')
  end
end
