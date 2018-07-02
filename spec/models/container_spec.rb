require 'rails_helper'

RSpec.describe Container do
  it { should validate_presence_of(:container_hostname) }


  describe 'launch' do
    context 'should call lxd module launch_container method' do
      it 'should take values passed' do
        expect(Lxd).to receive(:launch_container).with('ubuntu:14.04', 'p-user-service-01')
        container = Container.new(image: 'ubuntu:14.04', container_hostname: 'p-user-service-01')
        container.launch
      end
      it 'should take image default value if not passed' do
        expect(Lxd).to receive(:launch_container).with('ubuntu:16.04', 'p-user-service-01')
        container = Container.new(image: '', container_hostname: 'p-user-service-01')
        container.launch
      end
    end
  end

end
