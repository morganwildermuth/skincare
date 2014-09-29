FactoryGirl.define do
  factory :product do

    name {Faker::Lorem.word.capitalize + " " + Faker::Lorem.word.capitalize}
    description {Faker::Lorem.sentence}
    image_cosdna {Faker::Lorem.word}

  end
end