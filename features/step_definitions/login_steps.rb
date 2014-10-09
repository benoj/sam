Given(/^I am a user with email address '(.*)' and password '(.*)'$/) do |email, password|
  hashed_password =  BCrypt::Password.create(password)
  Sam::Model::User.create(email: email, password: hashed_password,user_type: :administrator)
end

When(/^I am taken to the login page in order to access '(.*)'$/) do | url |
  visit("/users/login?success=#{url}")
end


And(/^I fill in my email with '(.*)'$/) do | email |
  fill_in('email',with: email)
end


And(/^I fill in my password with '(.*)'$/) do | password |
  fill_in('password',with: password)
end

And(/^I click login$/) do
  click_button('Login')
end


Then(/^I am taken to '(.*)'$/) do | url |
  expect(page.current_path).to eq url
end


But(/^when I successfully log in I will be taken to '(.*)'$/) do | url |
  expect(find("input[name='url']", visible: false).value).to eq url
end