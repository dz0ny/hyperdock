class AddMonitorCertsToHost < ActiveRecord::Migration
  def change
    add_column :hosts, :logstash_cert, :text
    add_column :hosts, :logstash_key, :text
    add_column :hosts, :sensu_cert, :text
    add_column :hosts, :sensu_key, :text
  end
end
