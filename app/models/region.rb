class Region < ActiveRecord::Base
  has_many :hosts
  scope :all_available, -> { where("available_hosts_count > 0") }
  default_scope { order(available_hosts_count: :desc) }

  def healthy?
    self.healthy_hosts.count == self.hosts.count
  end

  def num_healthy
    self.healthy_hosts.count
  end

  def unhealthy_hosts
    self.hosts.where(healthy: false)
  end

  def healthy_hosts
    self.hosts.where(healthy: true)
  end

  def update_available_hosts_counter
    self.update_column :available_hosts_count, self.healthy_hosts.count
  end
end
