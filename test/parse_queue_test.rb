# coding: utf-8

require_relative '../lib/parse_queue'
gem              'minitest'
require          'minitest/autorun'
require          'minitest_visible'


class ParseQueueTest < Minitest::Test

  #Track mini-test progress.
  include MinitestVisible

  def test_that_it_has_a_version_number
    refute_nil ::ParseQueue::VERSION
  end

end
