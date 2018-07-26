require 'rails_helper'

RSpec.describe ContainersController do
  login_user

  describe 'POST#create' do
    before(:each) do
      FactoryBot.create(:container_host)
    end

    context 'success' do
      it 'should create a container with image, base host and name' do
        allow(Lxd).to receive(:launch_container).and_return({success: 'true'})
        post :create , :params => {:container => {container_hostname: 'p-user-service-01', image: 'ubuntu:16.04'}}
        expect(response.code).to eq('201')
      end
      it 'should return not return error if image is not passed' do
        allow(Lxd).to receive(:launch_container).and_return({success: 'true'})
        post :create , :params => {:container => {:container_hostname => 'p-user-service-01', image: ''}}
        expect(response.code).to eq('201')
      end
    end

    context 'failure' do
      it 'should return 400 for missing required param container_hostname' do
        post :create , :params => {:container => {:container_hostname => '', image: 'ubuntu:16.04'}}
        expect(response.code).to eq('400')
        expect(JSON.parse(response.body)['errors']).to eq("Container hostname can't be blank")
      end
    end
  end

  describe 'GET#index' do
    context 'list all the containers of a host' do
      it 'should return all the hosts' do
        container_1    = Container.new(container_hostname: 'p-user-01')
        container_2    = Container.new(container_hostname: 'p-user-02')
        container_list = [container_1, container_2]
        allow(Lxd).to receive(:list_containers).and_return(container_list)

        get :index
        expect(assigns(:containers)).to eq(container_list)
        expect(assigns(:containers).count).to eq(2)
      end
    end
  end

  describe 'GET#show' do
    context 'show container details' do
      let(:container) { Container.new(container_hostname: 'p-user-01',status: 'Running',ipaddress: '240.1.2.1',image: 'ubuntu',lxc_profiles: ['default'],created_at: '2018-03-26 17:48:26 +0530') }
      let(:container_res) { { success: true, data: container}}
      before do
        allow(Lxd).to receive(:show_container).with('p-user-service-01').and_return(container_res)
      end
      it 'should return all details of a container' do
        get :show, params: { container_hostname: 'p-user-service-01' }
        expect(assigns(:container)).to eq(container_res)
      end

      it 'should render json response' do
        get :show, params: { container_hostname: 'p-user-service-01', format: 'json' }
        expect(response).to be_success
      end
    end
  end

  describe 'DELETE#destroy' do
    context 'destroy a container' do
      let(:container_hostname) { 'p-user-service-01' }

      it "should destroy a container based on hostname and host's ipaddress" do
        allow(Lxd).to receive(:destroy_container).with(container_hostname).and_return({success: 'true', error: ''})

        delete :destroy, params: {container_hostname: container_hostname}
        expect(response.code).to eq('302')
      end

      it 'return errors if LXD moduld fails' do
        allow(Lxd).to receive(:destroy_container).with(container_hostname).and_return({success: 'false', error: 'bad request'})

        delete :destroy, params: {container_hostname: container_hostname}
        expect(response.code).to eq('500')
        expect(JSON.parse(response.body)['error']).to eq('bad request')
        expect(JSON.parse(response.body)['success']).to eq('false')
      end
    end

    context 'validation failure' do
      let(:lxd_host_ipaddress) { '172.16.1.1' }
      let(:container_hostname) { 'p-user-service-01' }

      it 'should return 400 for missing required param container_hostname' do
        delete :destroy, params: {lxd_host_ipaddress: lxd_host_ipaddress}
        expect(response.code).to eq('400')
        expect(JSON.parse(response.body)['errors']).to eq("Container hostname can't be blank")
      end
    end
  end
end
