# frozen_string_literal: true

# Original package: <https://github.com/inopinatus/chef-upgrade>

# Extend the Debian package providers & resources to guard against inadvertent downgrade
shim = Module.new do
  def target_version_already_installed?(current_version, target_version)
    return super unless @new_resource.downgrade_guard
    return false unless current_version && target_version

    Chef::Log.info("#{@new_resource} downgrade guard, comparing current=#{current_version} to target=#{target_version}")
    !shell_out('dpkg', '--compare-versions', current_version.to_s, 'ge', target_version.to_s).error?
  end
end

Chef::Provider::Package::Dpkg.prepend shim
Chef::Resource::DpkgPackage.property :downgrade_guard, [true, false], default: true

Chef::Provider::Package::Apt.prepend shim
Chef::Resource::AptPackage.property :downgrade_guard, [true, false], default: true

Ohai.plugin(:DebianDowngradeProtectionPlugin)
