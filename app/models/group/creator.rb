# frozen_string_literal: true
class Group
  class Creator
    GROUP_COULD_NOT_BE_CREATED = 'An error has occured on GitHub, and your team could not be created.'

    class Result
      class Error < StandardError; end

      def self.success(group)
        new(:success, group: group)
      end

      def self.failed(error)
        new(:failed, error: error)
      end

      attr_reader :error, :group

      def initialize(status, group: nil, error: nil)
        @status = status
        @group  = group
        @error  = error
      end

      def success?
        @status == :success
      end

      def failed?
        @status == :failed
      end
    end

    attr_reader :title, :group, :grouping, :organization

    def self.perform(title:, grouping:)
      new(title: title, grouping: grouping).perform
    end

    def initialize(title:, grouping:)
      @title        = title
      @grouping     = grouping
      @organization = grouping.organization
    end

    def perform
      github_team = create_github_team!

      begin
        @group = Group.create!(title: title, grouping: grouping, github_team_id: github_team.id)
        group.save!
      rescue ActiveRecord::RecordInvalid => err
        raise Result::Error, err.message
      end

    rescue Result::Error => err
      silently_destroy_github_team
      Result.failed(err.message)
    end

    private

    def create_github_team!
      organization.github_organization.create_team(title)
    rescue GitHub::Error
      raise Result::Error, GROUP_COULD_NOT_BE_CREATED
    end

    def silently_destroy_github_team
      return true if @group.try(:github_team_id).present?
      organization.github_organization.delete_team(@group.github_team_id)
    rescue GitHub::Error
      true
    end
  end
end
