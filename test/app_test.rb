require File.expand_path('../test_helper', __FILE__)

class AppTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def setup
    super
    FileUtils.rm_f CocoaPodsNotifier::RSS_FILE
    CocoaPodsNotifier::Twitter.stubs(:tweet)
  end

  def teardown
    super
    #puts last_response.errors
  end

  def app
    CocoaPodsNotifier
  end

  def test_it_generates_the_rss_file
    post "/#{HOOK_PATH}", :payload => { 'ref' => 'refs/heads/master' }.to_json
    assert_equal 201, last_response.status
    assert File.exist?(CocoaPodsNotifier::RSS_FILE)
  end

  def test_it_does_not_generate_the_rss_file_for_other_branches_than_master
    post "/#{HOOK_PATH}", :payload => { 'ref' => 'refs/heads/other-branch' }.to_json
    assert_equal 200, last_response.status
    assert !File.exist?(CocoaPodsNotifier::RSS_FILE)
  end

  def test_it_identifies_the_pods_added_by_an_update
    post "/#{HOOK_PATH}", :payload => { 'ref' => 'refs/heads/master' }.to_json
    assert_equal 201, last_response.status
    CocoaPodsNotifier::Twitter.stubs(:tweet)
    CocoaPodsNotifier::Twitter.stubs(:tweet)

  end

end
