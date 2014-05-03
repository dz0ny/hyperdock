class DockerHostValidator < ActiveModel::Validator
  def validate record
    begin
      reject(record) unless record.get_info.has_key? "Containers"
    rescue JSON::ParserError
      reject record
    rescue Net::OpenTimeout
      record.errors.add(:base, "Connection to #{record.docker_url} timed out")
    rescue Errno::ECONNREFUSED
      record.errors.add(:base, "Connection to #{record.docker_url} refused")
    rescue Errno::EADDRNOTAVAIL
      record.errors.add(:base, "Address #{record.docker_url} is invalid")
    rescue SocketError
      record.errors.add(:base, "Cannot connect to #{record.docker_url}")
    rescue URI::InvalidURIError
      record.errors.add(:base, "Address #{record.docker_url} is invalid")
    end
  end

  def reject record
    record.errors.add(:base, "#{record.docker_url} is not Docker")
  end
end
