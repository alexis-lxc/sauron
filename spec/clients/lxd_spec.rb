require 'rails_helper'

RSpec.describe Lxd do

  describe 'add_remote' do
    before(:each) do
      FactoryBot.create(:container_host)
    end

    it 'should create clients certificate on lxd host server' do
      allow(File).to receive(:read).and_return('')
      allow_any_instance_of(Hyperkit::Client).to receive(:create_certificate).and_return(true)
      response = Lxd.add_remote('172.16.7.1')
      expect(response[:success]).to eq(true)
    end

    it 'should return true if lxd create certificate returns certificate already present' do
      allow(File).to receive(:read).and_return('')
      allow_any_instance_of(Hyperkit::Client).to receive(:create_certificate).and_raise(Hyperkit::Error.from_response({status: 400, body: 'bad request Certificate already in trust store'}))
      response = Lxd.add_remote('172.16.7.1')
      expect(response[:success]).to eq(true)
    end

    it 'should return false if any error else than 400' do
      allow(File).to receive(:read).and_return('')
      allow_any_instance_of(Hyperkit::Client).to receive(:create_certificate).and_raise(Hyperkit::Error.from_response({status: 422, body: 'unprocessable entity'}))
      response = Lxd.add_remote('172.16.7.1')
      expect(response[:success]).to eq(false)
      expect(response[:errors]).to eq(' : 422 - unprocessable entity')
    end
  end

  describe 'launch_container' do
    before(:each) do
      FactoryBot.create(:container_host)
    end

    let(:container_hostname) {'p-wallet-service-01'}
    let(:image) {'ubuntu'}

    context 'create container returns success true' do
      before(:each) do
        allow(Lxd).to receive(:create_container).with(container_hostname).and_return({success: 'true'})
      end
      context 'start_container returns success true' do
        it 'should return success true' do
          expect(StartContainer).to receive(:perform_in).with(Figaro.env.WAIT_INTERVAL_FOR_STARTING_CONTAINER, container_hostname).once
          allow(Lxd).to receive(:start_container).with(container_hostname).and_return({success: 'true'})
          response = Lxd.launch_container(image, container_hostname)
          expect(response[:success]).to eq('true')
        end
      end
    end
    context 'create_container returns success false' do
      it 'should not call start_container and return' do
        FactoryBot.create(:container_host)
        allow(Lxd).to receive(:create_container).with(container_hostname).and_return({success: 'false'})
        response = Lxd.launch_container(image, container_hostname)
        expect(response[:success]).to eq('false')
      end
    end
  end

  describe 'create_container' do
    before(:each) do
      FactoryBot.create(:container_host)
    end
    let(:lxd_host_ipaddress) {'172.16.7.2'}
    let(:container_name) {'p-wallet-service-01'}

    context 'success' do
      it 'should create a new container based on the attributes passed' do
        expected_response = {:id => "2dbf5369-f3c8-4f16-b28f-8cfab8e45a7e",
                             :class => "task",
                             :created_at => '2018-03-27 13:52:59 +0700',
                             :updated_at => '2018-03-27 13:52:59 +0700',
                             :status => 'Running',
                             :status_code => 200,
                             :resources => {:containers => ["/1.0/containers/p-wallet-service-01"]},
                             :metadata => nil,
                             :may_cancel => false,
                             :err => ""}
        allow_any_instance_of(Hyperkit::Client).to receive(:create_container).with(container_name, server: "https://cloud-images.ubuntu.com/releases", protocol: "simplestreams", alias: "16.04").and_return(expected_response)
        response = Lxd.create_container(container_name)
        expect(response[:success]).to eq('true')
        expect(response[:error]).to eq('')
      end
    end
    context 'failure' do
      it 'should return the error message if creation fails with success as false' do
        expected_response = Hyperkit::Error.new()
        allow_any_instance_of(Hyperkit::Client).to receive(:create_container).with(container_name, server: "https://cloud-images.ubuntu.com/releases", protocol: "simplestreams", alias: "16.04").and_raise(expected_response)
        response = Lxd.create_container(container_name)
        expect(response[:success]).to eq(false)
      end
    end
  end

  describe 'start_container' do
    before(:each) do
      FactoryBot.create(:container_host)
    end
    let(:container_name) {'p-wallet-service-01'}

    context 'success' do
      it 'should start a container' do
        expected_response = {:id => "2e90750f-864f-49f7-b729-c73dc02224ee",
                             :class => "task",
                             :created_at => '2018-03-27 14:47:04 +0700',
                             :updated_at => '2018-03-27 14:47:04 +0700',
                             :status => 'Running',
                             :status_code => 200,
                             :resources => {:containers => ["/1.0/containers/p-wallet-service-01"]},
                             :metadata => nil,
                             :may_cancel => false,
                             :err => ""}
        allow_any_instance_of(Hyperkit::Client).to receive(:start_container).with(container_name).and_return(expected_response)
        response = Lxd.start_container(container_name)
        expect(response[:success]).to eq('true')
        expect(response[:error]).to eq('')
      end
    end
    context 'failure' do
      it 'should return the error if start container fails' do
        expected_response = Hyperkit::Error.new
        allow_any_instance_of(Hyperkit::Client).to receive(:start_container).with(container_name).and_raise(expected_response)
        response = Lxd.start_container(container_name)
        expect(response[:success]).to eq(false)
      end
    end
  end

  describe 'show container' do
    before(:each) do
      FactoryBot.create(:container_host)
    end

    it 'should call hyperkit container and container_state and return specific details' do
      container_name = 'p-user-service-lxc-05'
      container_state = {:status => "Running", :status_code => 103, :disk => {}, :memory => {:usage => 42934272, :usage_peak => 154955776, :swap_usage => 0,
                                                                                             :swap_usage_peak => 0}, :network => {:eth0 => {:addresses => [{:family => "inet", :address => "240.7.1.113", :netmask => "8",
                                                                                                                                                            :scope => "global"}, {:family => "inet6", :address => "fe80::216:3eff:fe5d:c0ae", :netmask => "64", :scope => "link"}], :counters =>
                                                                                                                                                {:bytes_received => 116410, :bytes_sent => 123737, :packets_received => 768, :packets_sent => 1033}, :hwaddr => "00:16:3e:5d:c0:ae", :host_name => "vethC88TMP",
                                                                                                                                            :mtu => 1450, :state => "up", :type => "broadcast"}, :lo => {:addresses => [{:family => "inet", :address => "127.0.0.1", :netmask => "8", :scope => "local"}, {:family => "inet6", :address => "::1", :netmask => "128", :scope => "local"}],
                                                                                                                                                                                                         :counters => {:bytes_received => 0, :bytes_sent => 0, :packets_received => 0, :packets_sent => 0}, :hwaddr => "", :host_name => "", :mtu => 65536, :state => "up", :type => "loopback"}},
                         :pid => 15179, :processes => 27, :cpu => {:usage => 24615824306}}

      container_details = {:architecture => "x86_64",
                           :config =>
                               {:"image.architecture" => "amd64",
                                :"image.description" => "ubuntu 16.04 LTS amd64 (release) (20180306)",
                                :"image.label" => "release",
                                :"image.os" => "ubuntu",
                                :"image.release" => "xenial",
                                :"image.serial" => "20180306",
                                :"image.version" => "16.04",
                                :"volatile.base_image" =>
                                    "c5bbef7f4e1c19f0104fd49b862b2e549095d894765c75c6d72775f1d98185ec",
                                :"volatile.eth0.hwaddr" => "00:16:3e:16:39:9d",
                                :"volatile.idmap.base" => "0",
                                :"volatile.idmap.next" =>
                                    "[{\"Isuid\":true,\"Isgid\":false,\"Hostid\":100000,\"Nsid\":0,\"Maprange\":65536},{\"Isuid\":false,\"Isgid\":true,\"Hostid\":100000,\"Nsid\":0,\"Maprange\":65536}]",
                                :"volatile.last_state.idmap" =>
                                    "[{\"Isuid\":true,\"Isgid\":false,\"Hostid\":100000,\"Nsid\":0,\"Maprange\":65536},{\"Isuid\":false,\"Isgid\":true,\"Hostid\":100000,\"Nsid\":0,\"Maprange\":65536}]",
                                :"volatile.last_state.power" => "RUNNING"},
                           :devices => {},
                           :ephemeral => false,
                           :profiles => ["default"],
                           :stateful => false,
                           :description => "",
                           :created_at => '2018-03-26 09:35:31 UTC',
                           :expanded_config =>
                               {:"environment.http_proxy" => "",
                                :"image.architecture" => "amd64",
                                :"image.description" => "ubuntu 16.04 LTS amd64 (release) (20180306)",
                                :"image.label" => "release",
                                :"image.os" => "ubuntu",
                                :"image.release" => "xenial",
                                :"image.serial" => "20180306",
                                :"image.version" => "16.04",
                                :"user.network_mode" => "",
                                :"volatile.base_image" =>
                                    "c5bbef7f4e1c19f0104fd49b862b2e549095d894765c75c6d72775f1d98185ec",
                                :"volatile.eth0.hwaddr" => "00:16:3e:16:39:9d",
                                :"volatile.idmap.base" => "0",
                                :"volatile.idmap.next" =>
                                    "[{\"Isuid\":true,\"Isgid\":false,\"Hostid\":100000,\"Nsid\":0,\"Maprange\":65536},{\"Isuid\":false,\"Isgid\":true,\"Hostid\":100000,\"Nsid\":0,\"Maprange\":65536}]",
                                :"volatile.last_state.idmap" =>
                                    "[{\"Isuid\":true,\"Isgid\":false,\"Hostid\":100000,\"Nsid\":0,\"Maprange\":65536},{\"Isuid\":false,\"Isgid\":true,\"Hostid\":100000,\"Nsid\":0,\"Maprange\":65536}]",
                                :"volatile.last_state.power" => "RUNNING"},
                           :expanded_devices =>
                               {:eth0 =>
                                    {:name => "eth0", :nictype => "bridged", :parent => "fan-11", :type => "nic"},
                                :root => {:path => "/", :pool => "default", :type => "disk"}},
                           :name => "p-user-service-lxc-05",
                           :status => "Running",
                           :status_code => 103,
                           :last_used_at => '2018-03-26 09:35:42 UTC'}

      allow_any_instance_of(Hyperkit::Client).to receive(:container).with(container_name).and_return(container_details)
      allow_any_instance_of(Hyperkit::Client).to receive(:container_state).with(container_name).and_return(container_state)

      container = Lxd.show_container('p-user-service-lxc-05')
      expect(container.ipaddress).to eq('240.7.1.113')
      expect(container.status).to eq('Running')
      expect(container.container_hostname).to eq('p-user-service-lxc-05')
      expect(container.image).to eq('ubuntu 16.04 LTS amd64 (release) (20180306)')
      expect(container.lxc_profiles).to eq(["default"])
    end
  end

  describe 'stop_container' do
    before(:each) do
      FactoryBot.create(:container_host)
    end

    it 'should take a container_name & host_ipaddress and stop a container' do
      container_name = 'p-wallet-service-01'
      container_stop_details= {:id => "0a2dbdc0-add9-4031-8e4e-ea1549c81f7c",
                               :class => "task",
                               :created_at => '2018-04-03 17:33:46 +0700',
                               :updated_at => '2018-04-03 17:33:46 +0700',
                               :status => "Running",
                               :status_code => 200,
                               :resources => {:containers => ["/1.0/containers/p-wallet-service-01"]},
                               :metadata => nil,
                               :may_cancel => false,
                               :err => ""}
      allow_any_instance_of(Hyperkit::Client).to receive(:stop_container).with(container_name).and_return(container_stop_details)
      response = Lxd.stop_container(container_name)
      expect(response[:success]).to be_truthy
      expect(response[:error]).to eq('')
    end

    it 'should return error if client fails' do
      container_name = 'p-wallet-service-01'
      allow_any_instance_of(Hyperkit::Client).to receive(:stop_container).with(container_name).and_raise(Hyperkit::Error.from_response({status: 400, body: 'bad request'}))
      response = Lxd.stop_container(container_name)
      expect(response[:success]).to be_falsey
      expect(response[:error]).to eq(' : 400 - bad request')
    end
  end

  describe 'destroy_container' do
    before(:each) do
      FactoryBot.create(:container_host)
    end
    let(:lxd_host_ipaddress) {ContainerHost.first.ipaddress}
    let(:container_hostname) {'p-wallet-service-01'}

    context 'stop_container returns success true' do
      context 'delete_container returns success true' do
        it 'should return success true' do
          allow(Lxd).to receive(:stop_container).with(container_hostname).and_return({success: 'true'})

          expect(DeleteContainer).to receive(:perform_in).with(Figaro.env.WAIT_INTERVAL_FOR_STARTING_CONTAINER, container_hostname).once
          response = Lxd.destroy_container(container_hostname)
          expect(response[:success]).to eq('true')
        end
      end
      context 'delete_container returns success false' do
        it 'should return success false' do
          allow(Lxd).to receive(:stop_container).with(container_hostname).and_return({success: 'false', error: 'bad request'})

          expect(DeleteContainer).not_to receive(:perform_in)
          response = Lxd.destroy_container(container_hostname)

          expect(response[:success]).to eq('false')
          expect(response[:error]).to eq('bad request')
        end
      end
    end
  end

  describe 'attach_public_key' do
    before(:each) do
      FactoryBot.create(:container_host)
    end
    let(:lxd_host_ipaddress) {ContainerHost.first.ipaddress}
    let(:container_hostname) {'localhost'}

    context 'attach_public_key returns success true' do
      it 'should return success true' do
        allow(Lxd).to receive(:attach_public_key).
            with(container_hostname, 'public_key').
            and_return({success: 'true'})
        response = Lxd.attach_public_key(container_hostname, 'public_key')
        expect(response[:success]).to eq('true')
      end
    end

    context 'attach_public_key returns success false' do
      it 'should return success false' do
        allow(Lxd).to receive(:attach_public_key).
            with(lxd_host_ipaddress, container_hostname, 'public_key').
            and_return({success: 'false', error: 'bad request'})
        response = Lxd.attach_public_key(lxd_host_ipaddress, container_hostname, 'public_key')
        expect(response[:success]).to eq('false')
        expect(response[:error]).to eq('bad request')
      end
    end
  end
end
