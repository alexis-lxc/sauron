FactoryBot.define do
  factory :container_host do
    sequence(:hostname){|n| "p-user-service-#{n}"}
    sequence(:ipaddress){|n| "10.12.1.#{n}"}
  end
end


