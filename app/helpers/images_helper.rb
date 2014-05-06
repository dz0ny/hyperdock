module ImagesHelper
  def simplify_port_bindings input
    JSON.parse("{#{input}}").keys.join(', ')
  end
end
