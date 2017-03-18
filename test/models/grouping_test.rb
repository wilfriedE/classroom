# frozen_string_literal: true
require 'test_helper'

class GroupingTest < ActiveSupport::TestCase
  setup do
    @grouping = grouping(:spring_semester)
    @organization = @grouping.organization
  end

  test 'organization_id must be present' do
    @grouping.organization_id = nil
    refute_predicate @grouping, :valid?
    assert_predicate @grouping.errors[:organization_id], :any?
  end

  test 'title must be present' do
    @grouping.title = nil
    refute_predicate @grouping, :valid?
    assert_predicate @grouping.errors[:title], :any?
  end

  test 'title must be unique to the organization' do
    other_grouping  = grouping(:fall_semester)
    @grouping.title = other_grouping.title

    assert_equal other_grouping.organization_id, @grouping.organization_id

    refute_predicate @grouping, :valid?
    assert_predicate @grouping.errors[:title], :any?
  end

  test 'slug must be unique even if the titles are not' do
    grouping = @organization.groupings.build(title: @grouping.slug)
    refute_predicate grouping, :valid?
    assert_predicate grouping.errors[:slug], :any?
  end
end
