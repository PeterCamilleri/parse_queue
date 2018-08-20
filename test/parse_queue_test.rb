# coding: utf-8

require_relative '../lib/parse_queue'
gem              'minitest'
require          'minitest/autorun'
require          'minitest_visible'

class ParseQueueTest < Minitest::Test

  #Track mini-test progress.
  include MinitestVisible

  def test_that_it_has_a_version_number
    refute_nil(::ParseQueue::VERSION)
    assert(::ParseQueue::VERSION.is_a?(String))
    assert(/\d*\.\d*\.\d*/ =~ ::ParseQueue::VERSION)
  end

  def test_that_it_acts_like_a_queue
    pq = ParseQueue.new
    pq.add((1..3).to_a)

    assert_equal(1, pq.get)
    assert_equal(2, pq.get)
    assert_equal(3, pq.get)
  end

  def test_that_it_auto_fetches
    src = (1..3).each
    pq = ParseQueue.new { src.next }

    assert_equal(1, pq.get)
    assert_equal(2, pq.get)
    assert_equal(3, pq.get)
  end

  def test_that_it_detects_underflow
    assert_raises(ParseQueueNoData) { ParseQueue.new.get }
  end

end
