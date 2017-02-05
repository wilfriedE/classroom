# frozen_string_literal: true
FactoryGirl.define do
  factory :group do
    github_team_id { rand(1..1_000_000)            }
    title          { Faker::Company.name           }
    slug           { title.parameterize            }
    grouping       { FactoryGirl.create(:grouping) }
    organization   { grouping.organization         }
  end
end
