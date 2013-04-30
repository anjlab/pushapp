require 'test_helper'
require 'pushapp'

class PushappTest < MiniTest::Unit::TestCase

  def test_rmerge_with_empty_values
    assert_equal({}, Pushapp.rmerge(nil, nil))
    assert_equal({}, Pushapp.rmerge({}, nil))
    assert_equal({}, Pushapp.rmerge(nil, {}))
  end

  def test_rmerge_with_plain_hashes
    assert_equal({a: 1, b: 2}, Pushapp.rmerge({a: 1}, {b: 2}))
    assert_equal({a: 1, b: 2}, Pushapp.rmerge({a: 1, b: 2}, {}))
    assert_equal({a: 1, b: 2}, Pushapp.rmerge({}, {a: 1, b: 2}))
  end

  def test_rmerge_with_nested_hashes
    assert_equal({a: {b: 1, c: 2}}, Pushapp.rmerge({}, {a: {b: 1, c: 2}}))
    assert_equal({a: {b: 1, c: 2}}, Pushapp.rmerge({a: {b: 1, c: 2}}, {}))
    assert_equal({a: {b: 1, c: 2}}, Pushapp.rmerge({a: {b: 1}}, {a: {c: 2}}))

    assert_equal({a: {b: 1, c: 2}}, Pushapp.rmerge({a: {b: 2}}, {a: {b: 1, c: 2}}))
  end
end

