# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Group::Creator, type: :model do
  let(:organization) { classroom_org }
  let(:grouping)     { create(:grouping, organization: organization) }

  describe '::perform', :vcr do
    describe 'successful creation' do
      after(:each) do
        Group.destroy_all
      end

      it 'creates a Group' do
        result = Group::Creator.perform(title: 'Salty Wood Runners', grouping: grouping)

        expect(result.success?).to be_truthy
        expect(result.group.grouping).to eql(grouping)
      end
    end

    describe 'unsuccessful creation' do
      it 'fails if the team could not be created on GitHub' do
        stub_request(:post, github_url("/organizations/#{organization.github_id}/repos"))
          .to_return(body: '{}', status: 401)

        result = Group::Creator.perform(title: 'Salty Wood Runners', grouping: grouping)

        expect(result.failed?).to be_truthy
      end
    end
  end
end
