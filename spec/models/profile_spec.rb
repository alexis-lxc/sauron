require 'rails_helper'

RSpec.describe Profile do
  it { should validate_presence_of(:name) }
  it { should validate_numericality_of(:cpu_limit).is_greater_than(0).allow_nil }

  before(:each) do
    ContainerHost.create(hostname: 'p-ubuntu-01', ipaddress: '172.16.33.33')
  end

  describe 'create', :vcr do
    context 'success' do
      it 'should transform attributes to LXD valid attrs', :delete_profile_after, profile_name: 'new-profile' do
        profile = Profile.new(name: 'new-profile', cpu_limit: '1', memory_limit: '100MB', ssh_authorized_keys: ['abc','def'])
        response = profile.create
        expect(response).to eq(true)
        profile_get = LxdProfile.get('new-profile')
        expect(profile.errors.full_messages.join(',')).to  eq('')
        expect(profile_get[:data][:profile][:config][:"limits.cpu"]).to eq('1')
        expect(profile_get[:data][:profile][:config][:"limits.memory"]).to eq('100MB')
      end
    end

    context 'failure' do
      it 'should return error if name is not set' do
        profile = Profile.new(name: '', cpu_limit: '', memory_limit: '100MB', ssh_authorized_keys: ['abc','def'])
        response = profile.create
        expect(response).to eq(false)
        expect(profile.errors.full_messages.join(',')).to  eq('Response POST https://172.16.33.33:8443/1.0/profiles: 400 - Error: No name provided')
      end
    end
  end

  describe 'memory_limit_format' do
    context 'success' do
      it 'memory limit and cpu limit should be optional' do
        profile = Profile.new(name: 'profile')
        expect(profile.valid?).to eq(true)
        expect(profile.errors.full_messages).to eq([])
      end

      it 'memory limit with positive memory and suffix kB, MB, GB, TB or EB is valid' do
        profile = Profile.new(name: 'profile', memory_limit: '10GB')
        expect(profile.valid?).to eq(true)
        expect(profile.errors.full_messages).to eq([])
      end

      it 'validates the memory limit if specified in percentage form' do
        profile = Profile.new(name: 'profile', memory_limit: '100')
        expect(profile.valid?).to eq(true)
        expect(profile.errors.full_messages).to eq([])
      end

      it 'cpu limit should be positive' do
        profile = Profile.new(name: 'profile', cpu_limit: 1)
        expect(profile.valid?).to eq(true)
        expect(profile.errors.full_messages).to eq([])
      end
    end

    context 'failure' do
      it 'should be invalid if memory.limit is not of valid format' do
        profile = Profile.new(name: 'profile', memory_limit: '-1')
        expect(profile.valid?).to eq(false)
        expect(profile.errors.full_messages).to eq(["Memory limit Memory limit should be positive % or have suffix one of kB, MB, GB TB, PB or EB"])
      end
    end
  end
end
