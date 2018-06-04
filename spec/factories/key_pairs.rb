FactoryBot.define do
  factory :key_pair do
    sequence(:name) { |n| "key-pair-#{n}" }
    public_key SSHKey.generate.ssh_public_key
    fingerprint SSHKey.generate.sha1_fingerprint
  end
end
