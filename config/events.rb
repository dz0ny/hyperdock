WebsocketRails::EventMap.describe do
  # You can use this file to map incoming events to controller actions.
  # One event can be mapped to any number of controller actions. The
  # actions will be executed in the order they were subscribed.
  #
  # Uncomment and edit the next line to handle the client connected event:
  #   subscribe :client_connected, :to => Controller, :with_method => :method_name
  #
  # Here is an example of mapping namespaced events:
  #   namespace :product do
  #     subscribe :new, :to => ProductController, :with_method => :new_product
  #   end
  # The above will handle an event triggered on the client like `product.new`.
  namespace :host do
    subscribe :provision, 'websocket#provision_host'
    subscribe :reset_known_hosts, 'websocket#reset_known_hosts'
    subscribe :list_containers, 'websocket#list_containers'
    subscribe :get_host_info, 'websocket#get_host_info'
  end 

  namespace :sensu do
    subscribe :list_checks, 'websocket#list_sensu_checks'
  end

  namespace :container do
    subscribe :top, 'websocket#container_top'
    subscribe :info, 'websocket#container_info'
  end
end
