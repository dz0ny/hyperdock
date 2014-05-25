class AddMonitorColumnsToHost < ActiveRecord::Migration
  def change
    add_column :hosts, :rabbitmq_host, :string
    add_column :hosts, :logstash_server, :string
    add_column :hosts, :rabbitmq_password, :string
    add_column :hosts, :sensu_api_user, :string
    add_column :hosts, :sensu_api_password, :string
    add_column :hosts, :sensu_dashboard_user, :string
    add_column :hosts, :sensu_dashboard_password, :string
    add_column :hosts, :kibana_user, :string
    add_column :hosts, :kibana_password, :string
  end
end
