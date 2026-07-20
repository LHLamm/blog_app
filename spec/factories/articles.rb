FactoryBot.define do
  factory :article do
    sequence(:title) { |n| "Bài viết #{n}" }
    body { "Nội dung bài viết" }
    status { :draft }
    association :author, factory: :user

    trait :published do
      status { :published }
      published_at { Time.current }
    end
  end
end
