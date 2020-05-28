class VersionDecorator < Draper::Decorator
  delegate_all

  def manifest_url
    if Version.where(owner_system_number: owner_system_number).size > 1
      h.manifest_version_url(object)
    else
      manifest
    end
  end
end
