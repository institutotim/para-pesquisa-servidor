Fabricator :user do
  username { SecureRandom.hex }
  name "Bruce Wayne"
  email "bruce@waynecorps.com"
  role "agent"
  password "batman"
  password_confirmation "batman"
end

Fabricator :agent, from: :user do
  role "agent"
end

Fabricator :api, from: :user do
  role "api"
end

Fabricator :mod, from: :user do
  role "mod"
end