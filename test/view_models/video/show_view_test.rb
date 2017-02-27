# frozen_string_literal: true
require 'test_helper'

class Video::ShowViewTest < ActiveSupport::TestCase
  setup do
    @attributes = {
      id: '12345',
      title: 'Title',
      provider: 'youtube',
      description: 'description'
    }

    @video = Video::ShowView.new(@attributes)
  end

  test 'has the proper attributes' do
    @attributes.each do |attr, value|
      assert_equal value, @video.send(attr)
    end
  end

  test 'returns the correct URL based on the provider' do
    assert_equal "https://www.youtube.com/embed/#{@video.id}", @video.url
  end
end
