module Monitoring
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

  def children
    if self.is_monitor
      @children ||= region.hosts.where(is_monitor: false)
    else
      [] # containers would make sense
    end
  end
end
