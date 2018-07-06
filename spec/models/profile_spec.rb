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
        profile_get = Profile.new(name: 'new-profile').get
        expect(profile_get.errors.full_messages.join(',')).to  eq('')
        expect(profile_get.cpu_limit).to eq('1')
        expect(profile_get.memory_limit).to eq('100MB')
        expect(profile_get.ssh_authorized_keys).to eq(['abc','def'])
      end

      it 'should split the ssh_authorized_keys on , if string is passed' do
        profile = Profile.new(name: 'new-profile', cpu_limit: '1', memory_limit: '100MB', ssh_authorized_keys: 'abc,def')
        response = profile.create
        expect(response).to eq(true)
        profile_get = Profile.new(name: 'new-profile').get
        expect(profile_get.errors.full_messages.join(',')).to  eq('')
        expect(profile_get.cpu_limit).to eq('1')
        expect(profile_get.memory_limit).to eq('100MB')
        expect(profile_get.ssh_authorized_keys).to eq(['abc','def'])
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

  describe 'update', :vcr do
    context 'success' do
      it 'should update the profile', :delete_profile_after, profile_name: 'new' do
        LxdProfile.create_from(from: 'default', to: 'new',
                               overrides: {:"limits.cpu"=>"1", :"limits.memory"=>"100MB",
                                           :"ssh_authorized_keys" => ['abc', 'def']})
        profile = Profile.new(name: 'new', cpu_limit: '2', memory_limit: '10GB', ssh_authorized_keys: ['xtc']).update
        expect(profile.errors.full_messages.join(',')).to eq('')
        expect(profile.name).to eq('new')
        expect(profile.ssh_authorized_keys).to eq(['xtc'])
        expect(profile.cpu_limit).to eq('2')
        expect(profile.memory_limit).to eq('10GB')
      end
    end

    context 'failure' do
      it 'should update errors in the profile object' do
        profile = Profile.new(name: 'new', cpu_limit: '2', memory_limit: '10GB', ssh_authorized_keys: ['xtc']).update
        expect(profile.errors.full_messages.join(',')).to eq('Response GET https://172.16.33.33:8443/1.0/profiles/new: 404 - Error: not found')
      end
    end
  end

  describe 'get' do
    context 'success', :vcr do
      it 'should get the lxd profile and return Profile object', :delete_profile_after, profile_name: 'new-profile' do
        LxdProfile.create_from(to: 'new-profile', overrides: {ssh_authorized_keys: ['abc','def'], "limits.cpu": '2', "limits.memory": '10GB'})
        profile = Profile.new(name: 'new-profile').get
        expect(profile.errors.full_messages.join(',')).to eq('')
        expect(profile.name).to eq('new-profile')
        expect(profile.cpu_limit).to eq('2')
        expect(profile.memory_limit).to eq('10GB')
        expect(profile.ssh_authorized_keys).to eq(['abc','def'])
      end
    end

    context 'failure/not-found', :vcr do
      it 'should return object with errors' do
        profile = Profile.new(name: 'new-profile').get
        expect(profile.errors.full_messages.join(',')).to eq('Response GET https://172.16.33.33:8443/1.0/profiles/new-profile: 404 - Error: not found')
      end
    end
  end
end
