json.success @container[:success]
json.data do
  json.hostname @container[:data].container_hostname
  json.status @container[:data].status
  json.ipaddress @container[:data].ipaddress
  json.image @container[:data].image
  json.lxc_profiles @container[:data].lxc_profiles
  json.created_at @container[:data].created_at
end

