# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :notification do
    user_id ""
    type ""
    comment_id ""
    like_id ""
    description "MyText"
  end
end
