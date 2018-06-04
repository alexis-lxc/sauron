json.success true
json.data do
  json.hostname @container.container_hostname
  json.ipaddress @container.ipaddress
  json.image @container.image
  json.status @container.status
  json.created_at @container.created_at
  json.lxc_profiles @container.lxc_profiles
end

