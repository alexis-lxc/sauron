require 'rails_helper'
require 'sidekiq/testing'
require 'spec_helper'

RSpec.describe DeleteContainer do
  before(:each) do
    Sidekiq::Worker.clear_all
    FactoryBot.create(:container_host)
    FactoryBot.create(:container_host)
    allow_any_instance_of(ContainerHost).to receive(:reachable?).and_return(true)
  end

  describe 'Delete container worker' do
    let(:lxd_host_ipaddress) {'172.16.7.2'}
    let(:container_name) {'p-wallet-service-01'}

    it 'should delete container successfully' do
      container_details = {:architecture => "x86_64",
                           :devices => {},
                           :ephemeral => false,
                           :profiles => ['default'],
                           :stateful => false,
                           :description => '',
                           :created_at => Time.now - 30,
                           :name => 'p-wallet-service-01',
                           :status => 'Stopped',
                           :status_code => 103,
                           :last_used_at => Time.now}
      allow_any_instance_of(Hyperkit::Client).to receive(:container).with(container_name).and_return(container_details)
      expect_any_instance_of(Hyperkit::Client).to receive(:delete_container).once
      DeleteContainer.new.perform(container_name)
    end

    it 'should not delete container if wait time not elapsed' do
      container_details = {:architecture => "x86_64",
                           :devices => {},
                           :ephemeral => false,
                           :profiles => ['default'],
                           :stateful => false,
                           :description => '',
                           :created_at => Time.now,
                           :name => 'p-wallet-service-01',
                           :status => 'Stopped',
                           :status_code => 103,
                           :last_used_at => Time.now}
      allow_any_instance_of(Hyperkit::Client).to receive(:container).with(container_name).and_return(container_details)
      expect_any_instance_of(Hyperkit::Client).not_to receive(:delete_container)
      expect {
        DeleteContainer.new.perform(container_name)
      }.to raise_error(message="Container p-wallet-service-01 is either running or already deleted")
    end
  end
end
