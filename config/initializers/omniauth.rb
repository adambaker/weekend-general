Rails.application.config.middleware.use OmniAuth::Builder do
  provider :open_id, nil, 
    name: 'google', identifier: 'https://www.google.com/accounts/o8/id'
end
