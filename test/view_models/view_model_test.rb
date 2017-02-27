# frozen_string_literal: true
require 'test_helper'

class ViewModelTest < ActiveSupport::TestCase
  test 'takes an attributes hash' do
    view = ViewModel.new(foo: 'bar')
    assert_equal 'bar', view.attributes[:foo]
  end

  test 'gets an empty attributes hash by default' do
    assert_equal({}, ViewModel.new.attributes)
    assert_equal({}, ViewModel.new(nil).attributes)
  end

  class WithAttributes < ViewModel
    attr_reader :foo
  end

  class WithAttributesChild < WithAttributes
    attr_reader :baz
  end

  class WithMultipleAttributes < ViewModel
    attr_reader :foo, :baz
  end

  test "automatically sets ivars for ctor attributes if there's an attr_reader" do
    view = WithAttributes.new(foo: 'bar', baz: :quux)

    assert_equal 'bar', view.foo
    assert_raises(NoMethodError) { view.baz }
  end

  test 'ivar setting works for hierarchies too' do
    view = WithAttributesChild.new(foo: 'bar', baz: :quux)

    assert_equal 'bar', view.foo
    assert_equal :quux, view.baz
  end

  test 'attr_reader appropriately handles multiple names' do
    view = WithMultipleAttributes.new(foo: :bar, baz: :quux)

    assert_equal :bar, view.foo
    assert_equal :quux, view.baz
  end
end
