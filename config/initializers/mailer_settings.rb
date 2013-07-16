if %w(test development).include?(Rails.env)
  # We dont need send email directly on dev env, just use sendmail mock
  ActionMailer::Base.delivery_method = :sendmail
else
  ActionMailer::Base.delivery_method = :smtp
  ActionMailer::Base.perform_deliveries = true
  ActionMailer::Base.raise_delivery_errors = true
  ActionMailer::Base.default :charset => "utf-8"
  ActionMailer::Base.smtp_settings = {
      :address => "smtp.gmail.com",
      :port => 587,
      :domain => "perechin.net",
      :authentication => "plain",
      :user_name => "viktor.danch@gmail.com",
      :password => "secret",
      :enable_starttls_auto => true
  }
end