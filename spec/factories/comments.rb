# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :comment do
    user_id 1
    commentable_id 1
    text "MyText"
    commentable_type "MyString"
  end
end
