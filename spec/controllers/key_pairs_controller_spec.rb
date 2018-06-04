require 'rails_helper'

RSpec.describe KeyPairsController, type: :controller do
  login_user

  describe 'GET#index' do
    context 'list all the key_pairs' do
      it 'should return all the key_pairs' do
        key_pair_1 = FactoryBot.create(:key_pair)
        key_pair_2 = FactoryBot.create(:key_pair)

        expect(KeyPair.count).to eq(2)

        get :index
        expect(assigns(:key_pairs)).to eq([key_pair_1,key_pair_2])
        expect(assigns(:key_pairs).count).to eq(2)
      end
    end
  end

  describe 'GET#show' do
    context 'show specific key_pair' do
      it 'should return specific key pair based on supplied id' do
        key_pair_1 = FactoryBot.create(:key_pair)

        get :show, params: {id: key_pair_1.id}
        expect(assigns(:key_pair)).to eq(key_pair_1)
      end
    end
  end

  describe 'POST#create' do
    context 'success' do
      it 'should create new key_pair' do
        post :create, :params => {key_pair: {name: 'new_key_pair'}}
        key_pair = KeyPair.first
        expect(response.code).to eq('302')
        expect(KeyPair.count).to eq(1)
        expect(key_pair.name).to eq('new_key_pair')
        expect(key_pair.public_key).not_to eq('')
      end

      it 'should not create multiple key_pair if same request is hit multiple times' do
        2.times do
          post :create, :params => {key_pair: {name: 'new_key_pair'}}
        end

        expect(KeyPair.count).to eq(1)
      end

      it 'should return 200 with proper message if same request is hit multiple times' do
        2.times do
          post :create, :params => {key_pair: {name: 'new_key_pair'}}
        end

        expect(response.code).to eq('200')
      end
    end

    context 'failure' do
      it 'should display flash error message if invalid request sent' do
        post :create, :params => {key_pair: {name: ''}}
        expect(response).to be_success
        expect(assigns(:key_pair).errors.details).to eq(name: [{error: :blank}])
      end
    end
  end
end
