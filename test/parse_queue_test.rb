# coding: utf-8

require_relative '../lib/parse_queue'
gem              'minitest'
require          'minitest/autorun'
require          'minitest_visible'

class ParseQueueTest < Minitest::Test

  #Track mini-test progress.
  include MinitestVisible

  def prep_queue
    src = (1..3).each

    ParseQueue.new {
      begin
        src.next
      rescue StopIteration
        false
      end
    }
  end

  def test_that_it_has_a_version_number
    refute_nil(::ParseQueue::VERSION)
    assert(::ParseQueue::VERSION.is_a?(String))
    assert(/\A\d+\.\d+\.\d+/ =~ ::ParseQueue::VERSION)
  end

  def test_that_it_acts_like_a_queue
    pq = prep_queue
    assert_equal(0, pq.fwd_count)
    pq.read_all

    assert_equal(3, pq.fwd_count)
    assert_equal(0, pq.position)
    assert_equal(0, pq.offset)

    assert_equal(1, pq.get)
    assert_equal(2, pq.fwd_count)
    assert_equal(1, pq.position)
    assert_equal(0, pq.offset)

    assert_equal(2, pq.get)
    assert_equal(1, pq.fwd_count)
    assert_equal(2, pq.position)
    assert_equal(0, pq.offset)

    assert_equal(3, pq.get)
    assert_equal(0, pq.fwd_count)
    assert_equal(3, pq.position)
    assert_equal(0, pq.offset)
  end

  def test_that_we_can_read_all
    pq = prep_queue
    pq.read_all

    assert_equal(3, pq.fwd_count)
    assert_equal(0, pq.position)
    assert_equal(0, pq.offset)

    assert_equal(1, pq.get)
    assert_equal(2, pq.get)
    assert_equal(3, pq.get)
  end

  def test_that_it_auto_fetches
    pq = prep_queue

    assert_equal(1, pq.get)
    assert_equal(2, pq.get)
    assert_equal(3, pq.get)
    assert_raises(ParseQueueNoFwd) { pq.get }
  end

  def test_that_manual_roll_back_works
    pq = prep_queue
    pq.read_all

    assert_equal(3, pq.fwd_count)
    assert_equal(0, pq.position)
    assert_equal(0, pq.offset)

    save = pq.position

    assert_equal(1, pq.get)
    assert_equal(2, pq.get)
    assert_equal(3, pq.get)

    assert_equal(0, pq.fwd_count)
    assert_equal(3, pq.position)
    assert_equal(0, pq.offset)

    pq.position = save

    assert_equal(3, pq.fwd_count)
    assert_equal(0, pq.position)
    assert_equal(0, pq.offset)
  end

  def test_a_try_with_success
    pq = prep_queue
    pq.read_all

    assert_equal(3, pq.fwd_count)
    assert_equal(0, pq.position)
    assert_equal(0, pq.offset)

    pq.try {
      assert_equal(1, pq.get)
      assert_equal(2, pq.get)
      true
    }

    assert_equal(1, pq.fwd_count)
    assert_equal(2, pq.position)
    assert_equal(0, pq.offset)

    assert_equal(3, pq.get)
  end

  def test_a_try_bang_with_success
    pq = prep_queue
    pq.read_all

    assert_equal(3, pq.fwd_count)
    assert_equal(0, pq.position)
    assert_equal(0, pq.offset)

    pq.try! {
      assert_equal(1, pq.get)
      assert_equal(2, pq.get)
      true
    }

    assert_equal(1, pq.fwd_count)
    assert_equal(2, pq.position)
    assert_equal(2, pq.offset)

    assert_equal(3, pq.get)
  end

  def test_a_try_with_roll_back
    pq = prep_queue
    pq.read_all

    assert_equal(3, pq.fwd_count)
    assert_equal(0, pq.position)
    assert_equal(0, pq.offset)

    pq.try {
      assert_equal(1, pq.get)
      assert_equal(2, pq.get)
      false
    }

    assert_equal(3, pq.fwd_count)
    assert_equal(0, pq.position)
    assert_equal(0, pq.offset)

    assert_equal(1, pq.get)
    assert_equal(2, pq.get)
    assert_equal(3, pq.get)
  end

  def test_a_try_bang_with_roll_back
    pq = prep_queue
    pq.read_all

    assert_equal(3, pq.fwd_count)
    assert_equal(0, pq.position)
    assert_equal(0, pq.offset)

    pq.try! {
      assert_equal(1, pq.get)
      assert_equal(2, pq.get)
      false
    }

    assert_equal(3, pq.fwd_count)
    assert_equal(0, pq.position)
    assert_equal(0, pq.offset)

    assert_equal(1, pq.get)
    assert_equal(2, pq.get)
    assert_equal(3, pq.get)
  end

  def test_that_we_can_back_up
    pq = prep_queue
    pq.read_all
    assert_equal(3, pq.fwd_count)

    assert_equal(1, pq.get)
    assert_equal(2, pq.fwd_count)

    pq.back_up
    assert_equal(3, pq.fwd_count)

    assert_equal(1, pq.get)
    assert_equal(2, pq.fwd_count)
  end

  def test_shifting_out_old_data
    pq = prep_queue
    pq.read_all

    assert_equal(1, pq.get)
    pq.shift
    assert_equal(2, pq.fwd_count)
    assert_equal(1, pq.position)
    assert_equal(1, pq.offset)

    assert_equal(2, pq.get)
    pq.shift
    assert_equal(1, pq.fwd_count)
    assert_equal(2, pq.position)
    assert_equal(2, pq.offset)

    assert_equal(3, pq.get)
    pq.shift
    assert_equal(0, pq.fwd_count)
    assert_equal(3, pq.position)
    assert_equal(3, pq.offset)
  end

  def test_that_it_detects_errors
    assert_raises(ParseQueueNoFwd) { ParseQueue.new.get }
    assert_raises(ParseQueueNoRev) { ParseQueue.new.back_up }

    pq = prep_queue

    assert_equal(1, pq.get)
    assert_equal(2, pq.get)
    assert_equal(3, pq.get)
    assert_raises(ParseQueueNoFwd) { pq.get }

    assert_raises(ParseQueueNoRev) {
      pq = prep_queue

      pq.try {
        assert_equal(1, pq.get)
        assert_equal(2, pq.get)
        pq.shift
        false
      }
    }

    assert_raises(ParseQueueNoRev) {
      pq = prep_queue

      save = pq.position
      assert_equal(1, pq.get)
      assert_equal(2, pq.get)
      pq.shift
      pq.position = save
    }

    assert_raises(ParseQueueNoFwd) {
      pq = ParseQueue.new
      pq.position = 1
    }

  end

end
