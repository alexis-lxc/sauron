require 'rails_helper'

RSpec.describe LxdProfile do
  before(:each) do
    ContainerHost.create(hostname: 'p-ubuntu-01', ipaddress: '172.16.33.33')
  end

  describe 'get', vcr: true do
    context 'success' do
      it 'should get profile details by name' do
        response = LxdProfile.get('default')
        expect(response[:success]).to eq('true')
        expect(response[:data][:profile][:config][:"user.network-config"][:version]).to eq(1)
        expect(response[:data][:profile][:config][:"user.network-config"][:config].count).to eq(2)
        expect(response[:data][:profile][:config][:"user.user-data"][:runcmd].count).to eq(7)
      end
    end

    context 'failure/not-found' do
      it 'should return success false with error' do
        response = LxdProfile.get('unknown')
        expect(response[:success]).to eq('false')
        expect(response[:error]).to  eq('GET https://172.16.33.33:8443/1.0/profiles/unknown: 404 - Error: not found')
      end
    end
  end

  describe 'create_from', :vcr do
    context 'success' do
      it 'should return success true with no errors' do
        response = LxdProfile.create_from(from: 'default', to: 'new', overrides: {:"limits.cpu"=>"1", :"limits.memory"=>"100MB"})
        new_profile = LxdProfile.get('new')
        expect(response[:success]).to eq('true')
        expect(response[:error]).to  eq('')
        expect(new_profile[:data][:profile][:config][:"limits.cpu"]).to eq('1')
        expect(new_profile[:data][:profile][:config][:"limits.memory"]).to eq('100MB')
      end
    end

    context 'failure' do
      it 'should return success false with errors for unknow profile' do
        response = LxdProfile.create_from(from: 'default-random', to: 'new', overrides: {:"limits.cpu"=>"1", :"limits.memory"=>"100MB"})
        expect(response[:success]).to eq('false')
        expect(response[:error]).to  eq('GET https://172.16.33.33:8443/1.0/profiles/default-random: 404 - Error: not found')
      end

      it 'should return success false with errors for bad overrides' do
        response = LxdProfile.create_from(from: 'default', to: 'new', overrides: {:"limitsssss.cpu"=>"1"})
        expect(response[:success]).to eq('false')
        expect(response[:error]).to  eq('POST https://172.16.33.33:8443/1.0/profiles: 400 - Error: Unknown configuration key: limitsssss.cpu')
      end
    end
  end

  describe 'update', :vcr do
    context 'success' do
      it 'should return success true for new keys added' do
        LxdProfile.create_from(from: 'default', to: 'new', overrides: {})
        response = LxdProfile.update('new', config: {'limits.cpu': '4', 'limits.memory': '100MB'})
        expect(response[:success]).to eq('true')
        expect(response[:error]).to  eq('')

        profile = LxdProfile.get('new')
        expect(profile[:data][:profile][:config][:"limits.cpu"]).to eq('4')
        expect(profile[:data][:profile][:config][:"limits.memory"]).to eq('100MB')
        expect(profile[:data][:profile][:name]).to eq('new')
        expect(profile[:data][:profile][:config][:"user.network-config"][:version]).to eq(1)
      end

      it 'should return success true for updating existing keys' do
        LxdProfile.create_from(from: 'default', to: 'new', overrides: {'limits.cpu': '4', 'limits.memory': '100MB'})
        response = LxdProfile.update('new', config: {'limits.cpu': '8', 'limits.memory': '600MB'})
        expect(response[:success]).to eq('true')
        expect(response[:error]).to  eq('')

        profile = LxdProfile.get('new')
        expect(profile[:data][:profile][:config][:"limits.cpu"]).to eq('8')
        expect(profile[:data][:profile][:config][:"limits.memory"]).to eq('600MB')
        expect(profile[:data][:profile][:name]).to eq('new')
        expect(profile[:data][:profile][:config][:"user.network-config"][:version]).to eq(1)
      end
    end

    context 'failure' do
      it 'should return success false with erorrs for unknown profile' do
        response = LxdProfile.update('random', config: {'limits.cpu': '8', 'limits.memory': '600MB'})
        expect(response[:success]).to eq('false')
        expect(response[:error]).to  eq("PATCH https://172.16.33.33:8443/1.0/profiles/random: 500 - Error: Failed to retrieve profile='random'")
      end
    end
  end
end
