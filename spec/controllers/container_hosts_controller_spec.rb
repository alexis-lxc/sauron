require 'rails_helper'

RSpec.describe ContainerHostsController do
  login_user

  describe 'POST#create' do
    context 'success' do
      it 'should create with hostname and host ipaddress' do
        expect(Lxd).to receive(:add_remote).with('10.12.1.2').and_return({success: true})
        post :create , :params => {:hostname => 'p-user-service-01', :ipaddress => '10.12.1.2'}
        container_host = ContainerHost.first
        expect(response.code).to eq('201')
        expect(ContainerHost.count).to eq(1)
        expect(container_host.hostname).to eq('p-user-service-01')
        expect(container_host.ipaddress).to eq('10.12.1.2')
      end

      it 'should not create multiple host name and ipaddres entry if same request is hit multiple times' do
        expect(Lxd).to receive(:add_remote).with('10.12.1.2').twice.and_return({success: true})

        2.times do
          post :create , :params => {:hostname => 'p-user-service-01', :ipaddress => '10.12.1.2'}
        end

        expect(ContainerHost.count).to eq(1)
      end


      it 'should return 200 with proper message if same request is hit multiple times' do
        expect(Lxd).to receive(:add_remote).with('10.12.1.2').twice.and_return({success: true})

        2.times do
          post :create , :params => {:hostname => 'p-user-service-01', :ipaddress => '10.12.1.2'}
        end

        expect(response.code).to eq('200')
        expect(JSON.parse(response.body)['message']).to eq("Lxd host already registered")
      end
    end

    context 'failure' do
      it 'should return 400 for missing required param hostname' do
        post :create , :params => {:hostname => '', :ipaddress => '10.12.1.2'}
        expect(response.code).to eq('400')
        expect(JSON.parse(response.body)['errors']).to eq("Hostname can't be blank")
      end
      it 'should return 400 for missing required param ipaddress' do
        post :create , :params => {:hostname => 'p-user-01', :ipaddress => ''}
        expect(response.code).to eq('400')
        expect(JSON.parse(response.body)['errors']).to eq("Ipaddress can't be blank")
      end
      it 'should return 400 for missing required param ipaddress and hostname' do
        post :create , :params => {:hostname => '', :ipaddress => ''}
        expect(response.code).to eq('400')
        expect(JSON.parse(response.body)['errors']).to eq("Hostname can't be blank,Ipaddress can't be blank")
      end
    end
  end

  describe 'GET#index' do
    context 'list all the hosts' do
      it 'should return all the hosts' do
        container_host_1 = FactoryBot.create(:container_host)
        container_host_2 = FactoryBot.create(:container_host)

        expect(ContainerHost.count).to eq(2)

        get :index
        expect(assigns(:container_hosts)).to eq([container_host_1,container_host_2])
        expect(assigns(:container_hosts).count).to eq(2)
      end
    end
  end

  describe 'GET#show' do
    context 'show container_host with the containers' do
      it 'should return all containers on the host along with host details' do
        container_host_1 = FactoryBot.create(:container_host)

        get :show, params: {id: container_host_1.id}
        expect(assigns(:container_host)).to eq(container_host_1)
      end
    end
  end

end
