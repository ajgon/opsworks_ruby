class DummyJob < ActiveJob::Base
  queue_as :default

  def perform(*args)
    File.open(Rails.root.join('public', 'delayed_job.txt'), 'w') { |f| f.write(SecureRandom.hex(128)) }
  end
end
