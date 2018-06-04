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
end
