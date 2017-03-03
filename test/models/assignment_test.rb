# frozen_string_literal: true
require 'test_helper'

class AssignmentTest < ActiveSupport::TestCase
  setup do
    @assignment = assignment(:public_assignment)
  end

  test '.default_scope hides deleted records' do
    @assignment.update_attributes(deleted_at: Time.zone.now)
    refute_includes Assignment.all, @assignment
  end

  # Presence
  %(title slug).each do |column|
    test "#{column} must be present" do
      @assignment.send("#{column}=", nil)
      refute @assignment.valid?
    end
  end

  test 'slug cannot be longer that 60 characters' do
    @assignment.slug = 'aa' * 60
    refute @assignment.valid?
  end

  test 'slug can only contain letters, numbers, dashes, and underscores' do
    @assignment.slug = '$'
    refute @assignment.valid?
  end

  test 'must have a unique slug scoped to the classroom' do
    assignment2 = assignment(:public_assignment_with_starter_code)
    @assignment.slug = assignment2.slug
    refute @assignment.valid?

    group_assignment = group_assignment(:public_group_assignment)
    @assignment.slug = group_assignment.slug
    refute @assignment.valid?
  end

  test '#flipper_id includes the assignments id' do
    assert_equal "Assignment:#{@assignment.id}", @assignment.flipper_id
  end

  test '#private? returns true when `public_repo` is false' do
    private_assignment = assignment(:private_assignment)
    refute private_assignment.public_repo
    assert private_assignment.private?
  end

  test '#public? returns true when `public_repo` is true' do
    assert @assignment.public_repo
    assert @assignment.public?
  end

  test '#starter_code? returns true when the assignment has starter code' do
    assert assignment(:public_assignment_with_starter_code).starter_code?
  end

  test '#starter_code_repository returns a GitHubRepository when there is starter code' do
    assignment = assignment(:public_assignment_with_starter_code)
    assert assignment.starter_code?

    github_repository = assignment.starter_code_repository
    assert_kind_of GitHubRepository, github_repository
    assert_equal github_repository.id, assignment.starter_code_repo_id
  end

  test '#to_param returns the slug' do
    assert_equal @assignment.slug, @assignment.to_param
  end
end
