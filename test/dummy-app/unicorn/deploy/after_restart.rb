# frozen_string_literal: true
Chef::Log.info('Running deploy/after_restart.rb...')

execute 'copy assets' do
  cwd release_path
  command "mkdir -p #{release_path}/public/test && cp -r #{release_path}/public/assets/* #{release_path}/public/test || true"
end

