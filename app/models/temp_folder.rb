##
# Give any model a temp folder
module TempFolder
  extend ActiveSupport::Concern

  def tmp
    path = Rails.root.join("tmp/#{self.class.to_s.pluralize}/#{self.id}")
    FileUtils.mkdir_p(path) unless path.exist?
    path
  end
end

