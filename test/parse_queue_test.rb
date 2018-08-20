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
    assert(/\d+\.\d+\.\d+/ =~ ::ParseQueue::VERSION)
  end

  def test_that_it_acts_like_a_queue_one
    pq = ParseQueue.new
    assert_equal(0, pq.count)
    pq.add(1)
    pq.add(2)
    pq.add(3)

    assert_equal(3, pq.count)
    assert_equal(0, pq.position)
    assert_equal(0, pq.offset)
    assert_equal(1, pq.get)

    assert_equal(2, pq.count)
    assert_equal(1, pq.position)
    assert_equal(0, pq.offset)
    assert_equal(2, pq.get)

    assert_equal(1, pq.count)
    assert_equal(2, pq.position)
    assert_equal(0, pq.offset)
    assert_equal(3, pq.get)

    assert_equal(0, pq.count)
    assert_equal(3, pq.position)
    assert_equal(0, pq.offset)
  end

  def test_that_it_acts_like_a_queue_two
    pq = ParseQueue.new
    assert_equal(0, pq.count)
    pq.add((1..3).to_a)

    assert_equal(3, pq.count)
    assert_equal(0, pq.position)
    assert_equal(0, pq.offset)
    assert_equal(1, pq.get)

    assert_equal(2, pq.count)
    assert_equal(1, pq.position)
    assert_equal(0, pq.offset)
    assert_equal(2, pq.get)

    assert_equal(1, pq.count)
    assert_equal(2, pq.position)
    assert_equal(0, pq.offset)
    assert_equal(3, pq.get)

    assert_equal(0, pq.count)
    assert_equal(3, pq.position)
    assert_equal(0, pq.offset)
  end

  def test_that_it_auto_fetches
    src = (1..3).each
    pq = ParseQueue.new { src.next }

    assert_equal(1, pq.get)
    assert_equal(2, pq.get)
    assert_equal(3, pq.get)
  end


  def test_a_try_with_success
    pq = ParseQueue.new
    pq.add((1..3).to_a)

    assert_equal(3, pq.count)
    assert_equal(0, pq.position)
    assert_equal(0, pq.offset)

    pq.try {
      assert_equal(1, pq.get)
      assert_equal(2, pq.get)
      true
    }

    assert_equal(1, pq.count)
    assert_equal(2, pq.position)
    assert_equal(0, pq.offset)

    assert_equal(3, pq.get)
  end

  def test_a_try_with_roll_back
    pq = ParseQueue.new
    pq.add((1..3).to_a)

    assert_equal(3, pq.count)
    assert_equal(0, pq.position)
    assert_equal(0, pq.offset)

    pq.try {
      assert_equal(1, pq.get)
      assert_equal(2, pq.get)
      false
    }

    assert_equal(3, pq.count)
    assert_equal(0, pq.position)
    assert_equal(0, pq.offset)

    assert_equal(1, pq.get)
    assert_equal(2, pq.get)
    assert_equal(3, pq.get)
  end

  def test_that_it_detects_underflow
    assert_raises(ParseQueueNoData) { ParseQueue.new.get }
  end

end
