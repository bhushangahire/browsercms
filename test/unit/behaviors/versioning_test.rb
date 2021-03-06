require 'test_helper'

class VersioningTest < ActiveSupport::TestCase

  test "version_foriegn_key is always the same" do
    assert_equal :original_record_id, Cms::HtmlBlock.version_foreign_key
  end

  test "Non-versioned columns include 'original_record_id'" do
    assert_equal true, Cms::HtmlBlock.non_versioned_columns.include?("original_record_id")
  end

  test "non_versioned_columns should be made into string" do
    class ::Cms::SpecialBlock < ActiveRecord::Base
      is_versioned
    end

    Cms::SpecialBlock.non_versioned_columns.each do |c|
      assert_equal String, c.class, "Expected #{c} to be a String, but wasn't."
    end

  end
  test "Saving a new record should create two rows, one in html_blocks, one in html_block_versions" do
    block = Cms::HtmlBlock.new(:name=>"Name is required.")
    assert_equal true, block.save!
    assert_equal 1, block.versions.size
  end

  test "Saving a new Versioned block should allow after_save callbacks to work" do
    block = Cms::HtmlBlock.new(:name=>"Testing")
    assert block.save
    assert_equal false, block.skip_callbacks
  end

  test "Saving a block without changing any attributes should skip after_save callbacks" do
    block = Cms::HtmlBlock.new(:name=>"Testing")
    block.save

    block.name = "Testing"
    assert block.save

    assert_equal true, block.skip_callbacks
  end

  test "Updating a block should increment the version on the new draft" do
    block = Factory(:html_block)
    assert_equal 1, block.version
    block.name = "New Name"
    assert block.save

    assert_equal 2, block.versions.size
    assert_equal 1, block.versions[0].version
    assert_equal 2, block.versions[1].version
  end

  test "Build new version should create a new version with an incremented version from the primary object" do
    block = Cms::HtmlBlock.new(:name=>"ABC")
    assert block.save
    assert_equal 2, block.build_new_version_and_add_to_versions_list_for_saving.version
  end

  test "Updating an object should perform after_save callbacks" do
    block = Factory(:html_block)
    block.name = "New THing"
    block.expects(:update_connected_pages).returns(true)

    block.save
  end
end