require 'rails_helper'

RSpec.describe LxdProfile do
  get_default_profile = {:config=>
                         {:"user.network-config"=>
                          "version: 1\n" +
                            "config:\n" +
                            "  - type: physical\n" +
                            "    name: eth0\n" +
                            "    subnets:\n" +
                            "      - type: dhcp\n" +
                            "        control: auto\n" +
                            "  - type: nameserver\n" +
                            "    address: 172.16.200.200\n",
                            :"user.user-data"=>
                          "#cloud-config\n" +
                            "package_upgrade: true\n" +
                            "ssh_authorized_keys:\n" +
                            " - \n" +
                            "runcmd:\n" +
                            "  - touch /tmp/nsupdate\n" +
                            "  - echo \"server 172.16.200.200\" >> /tmp/nsupdate\n" +
                            "  - echo \"zone lxd\" >> /tmp/nsupdate\n" +
                            "  - echo \"update delete $(hostname).lxd A\" >> /tmp/nsupdate\n" +
                            "  - echo \"update add $(hostname).lxd 60 A $(hostname -I | awk '{print $1}')\" >> /tmp/nsupdate\n" +
                            "  - echo \"send\" >> /tmp/nsupdate\n" +
                            "  - nsupdate -v /tmp/nsupdate\n"},
                            :description=>"Default LXD profile",
                            :devices=>
                          {:eth0=>{:name=>"eth0", :nictype=>"bridged", :parent=>"fan10", :type=>"nic"},
                           :root=>{:path=>"/", :pool=>"local", :type=>"disk"}},
                          :name=>"default",
                          :used_by=>["/1.0/containers/test-1"]}
  get_new_profile = {:config=>
                     {:"limits.cpu"=>"1",
                      :"limits.memory"=>"100MB",
                      :"user.network-config"=>
                     "version: 1\n" +
                       "config:\n" +
                       "  - type: physical\n" +
                       "    name: eth0\n" +
                       "    subnets:\n" +
                       "      - type: dhcp\n" +
                       "        control: auto\n" +
                       "  - type: nameserver\n" +
                       "    address: 172.16.200.200\n",
                       :"user.user-data"=>
                     "#cloud-config\n" +
                       "package_upgrade: true\n" +
                       "ssh_authorized_keys:\n" +
                       " - \n" +
                       "runcmd:\n" +
                       "  - touch /tmp/nsupdate\n" +
                       "  - echo \"server 172.16.200.200\" >> /tmp/nsupdate\n" +
                       "  - echo \"zone lxd\" >> /tmp/nsupdate\n" +
                       "  - echo \"update delete $(hostname).lxd A\" >> /tmp/nsupdate\n" +
                       "  - echo \"update add $(hostname).lxd 60 A $(hostname -I | awk '{print $1}')\" >> /tmp/nsupdate\n" +
                       "  - echo \"send\" >> /tmp/nsupdate\n" +
                       "  - nsupdate -v /tmp/nsupdate\n"},
                       :description=>"Default LXD profile",
                       :devices=>
                     {:eth0=>{:name=>"eth0", :nictype=>"bridged", :parent=>"fan10", :type=>"nic"},
                      :root=>{:path=>"/", :pool=>"local", :type=>"disk"}},
                     :name=>"default",
                     :used_by=>["/1.0/containers/test-1"]}

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

end
