FactoryGirl.define do
  factory :ingredient do

    name {Faker::Lorem.word.capitalize + " " + Faker::Lorem.word.capitalize}
    acne {rand(0..5)}
    irritant {rand(0..5)}
    safety {Faker::Lorem.word}
    uva {rand(1..3)}
    uvb {rand(1..3)}
    functions {Faker::Lorem.word.upcase + " " + Faker::Lorem.word.upcase}

  end
end