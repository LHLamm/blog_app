FactoryBot.define do
  factory :action_log do
    action_name { "publish" }
    metadata { {} }
    association :loggable, factory: :article
    user
  end
end
