module Monitored
  extend ActiveSupport::Concern

  ##
  # Find the region monitor
  def monitor
    monitor? ? self : region.hosts.where(is_monitor: true).first
  end

  def monitor?
    self.is_monitor
  end

  def is_monitor!
    self.update_column(:is_monitor, true)
  end
end
