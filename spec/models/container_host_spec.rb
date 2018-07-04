require 'rails_helper'

RSpec.describe ContainerHost do
  it { should validate_presence_of(:hostname) }
  it { should validate_presence_of(:ipaddress) }

  describe 'register' do
    it 'should increment container host count' do
      expect(Lxd).to receive(:add_remote).with('172.16.1.1').and_return({success: true})
      container = ContainerHost.new(hostname: 'p-lxd-01', ipaddress: '172.16.1.1')
      expect{container.register}.to change{ContainerHost.count}.from(0).to(1)
    end

    it 'should be idempotent' do
      expect(Lxd).to receive(:add_remote).with('172.16.1.1').twice.and_return({success: true})
      container = ContainerHost.new(hostname: 'p-lxd-01', ipaddress: '172.16.1.1')
      container1 = ContainerHost.new(hostname: 'p-lxd-01', ipaddress: '172.16.1.1')
      container.register
      container1.register
      expect(ContainerHost.count).to eq(1)
    end

    it 'should return container_host object on success' do
      expect(Lxd).to receive(:add_remote).with('172.16.1.1').and_return({success: true})
      container = ContainerHost.new(hostname: 'p-lxd-01', ipaddress: '172.16.1.1')
      result    = container.register
      expect(result.id.present?).to eq(true)
      expect(result.hostname).to eq('p-lxd-01')
      expect(result.ipaddress).to eq('172.16.1.1')
      expect(result.errors.full_messages.join(',')).to eq('')
      expect(result.already_exists).to be_falsey
    end

    it 'should call LXD add_remote method' do
      expect(Lxd).to receive(:add_remote).with('172.16.1.1').and_return({success: true})
      ContainerHost.new(hostname: 'p-lxd-01', ipaddress: '172.16.1.1').register
    end

   it 'should not save the record if add_remote fails' do
     expect(Lxd).to receive(:add_remote).with('172.16.1.1').and_return({success: false, errors: '422 Unprocessable Entity'})
      container   = ContainerHost.new(hostname: 'p-lxd-01', ipaddress: '172.16.1.1')
      response    = container.register
      expect(ContainerHost.count).to eq(0)
      expect(response.errors.full_messages.join(',')).to eq("Remote add 422 Unprocessable Entity")
   end

   it 'should return container host object with flag set as true if its already registered' do
     expect(Lxd).to receive(:add_remote).with('172.16.1.1').twice.and_return({success: true})
     container = ContainerHost.new(hostname: 'p-lxd-01', ipaddress: '172.16.1.1')

     expect{container.register}.to change{ContainerHost.count}.from(0).to(1)

     response = container.register
     expect(ContainerHost.count).to eq(1)
     expect(response.id).to eq(1)
     expect(response.hostname).to eq('p-lxd-01')
     expect(response.ipaddress).to eq('172.16.1.1')
     expect(response.errors.full_messages.join(',')).to eq('')
     expect(response.already_exists).to be_truthy
   end
  end

  describe 'client' do
    before(:each) do
      ContainerHost.destroy_all
      FactoryBot.create(:container_host)
      FactoryBot.create(:container_host)
    end

    context 'create client object' do
      it 'should create client with first healthy node' do
        allow_any_instance_of(Hyperkit::Client).to receive(:operations).and_return([])
        expect(ContainerHost.reachable_node).to eq(ContainerHost.first.ipaddress)
      end

      it 'should create client with next healthy node when first node fails' do
        first_container_host = double(ContainerHost, ipaddress: '1.1.1.1')
        second_container_host = double(ContainerHost, ipaddress: '2.2.2.2')
        allow(ContainerHost).to receive(:all).and_return([first_container_host, second_container_host])
        expect(first_container_host).to receive(:reachable?).and_return(false)
        expect(second_container_host).to receive(:reachable?).and_return(true)
        expect(ContainerHost.reachable_node).to eq(ContainerHost.second.ipaddress)
      end

      it 'should not create client when no healthy node present in cluster' do
        allow_any_instance_of(Hyperkit::Client).to receive(:operations).and_raise(Exception.new)
        expect {
          ContainerHost.reachable_node
        }.to raise_error('No Healthy LXD Cluster nodes available. Please try after adding a new node')
      end
    end
  end
end
