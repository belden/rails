require 'abstract_unit'

class OldContentTypeController < ActionController::Base
  # :ported:
  def render_content_type_from_body
    response.content_type = Mime::RSS
    render :text => "hello world!"
  end

  # :ported:
  def render_defaults
    render :text => "hello world!"
  end

  # :ported:
  def render_content_type_from_render
    render :text => "hello world!", :content_type => Mime::RSS
  end

  # :ported:
  def render_charset_from_body
    response.charset = "utf-16"
    render :text => "hello world!"
  end

  # :ported:
  def render_nil_charset_from_body
    response.charset = nil
    render :text => "hello world!"
  end

  def render_default_for_erb
  end

  def render_default_for_builder
  end

  def render_change_for_builder
    response.content_type = Mime::HTML
    render :action => "render_default_for_builder"
  end

  def render_default_content_types_for_respond_to
    respond_to do |format|
      format.html { render :text   => "hello world!" }
      format.xml  { render :action => "render_default_content_types_for_respond_to" }
      format.js   { render :text   => "hello world!" }
      format.rss  { render :text   => "hello world!", :content_type => Mime::XML }
    end
  end

  def rescue_action(e) raise end
end

class ContentTypeTest < ActionController::TestCase
  tests OldContentTypeController

  def setup
    super
    # enable a logger so that (e.g.) the benchmarking stuff runs, so we can get
    # a more accurate simulation of what happens in "real life".
    @controller.logger = Logger.new(nil)
  end

  # :ported:
  def test_render_defaults
    get :render_defaults
    assert_equal "utf-8", @response.charset
    assert_equal Mime::HTML, @response.content_type
  end

  def test_render_changed_charset_default
    assert_deprecated(/Setting default charset at controller.*config\.action_dispatch\.default_charset/) do
      begin
        OldContentTypeController.default_charset = "utf-16"
        get :render_defaults
        assert_equal "utf-16", @response.charset
        assert_equal Mime::HTML, @response.content_type
      ensure
        OldContentTypeController.default_charset = "utf-8"
      end
    end
  end

  # :ported:
  def test_content_type_from_body
    get :render_content_type_from_body
    assert_equal Mime::RSS, @response.content_type
    assert_equal "utf-8", @response.charset
  end

  # :ported:
  def test_content_type_from_render
    get :render_content_type_from_render
    assert_equal Mime::RSS, @response.content_type
    assert_equal "utf-8", @response.charset
  end

  # :ported:
  def test_charset_from_body
    get :render_charset_from_body
    assert_equal Mime::HTML, @response.content_type
    assert_equal "utf-16", @response.charset
  end

  # :ported:
  def test_nil_charset_from_body
    get :render_nil_charset_from_body
    assert_equal Mime::HTML, @response.content_type
    assert_equal "utf-8", @response.charset, @response.headers.inspect
  end

  def test_nil_default_for_erb
    assert_deprecated(/Setting default charset at controller.*config\.action_dispatch\.default_charset/) do
      begin
        OldContentTypeController.default_charset = nil
        get :render_default_for_erb
        assert_equal Mime::HTML, @response.content_type
        assert_nil @response.charset, @response.headers.inspect
      ensure
        OldContentTypeController.default_charset = "utf-8"
      end
    end
  end

  def test_default_for_erb
    get :render_default_for_erb
    assert_equal Mime::HTML, @response.content_type
    assert_equal "utf-8", @response.charset
  end

  def test_default_for_builder
    get :render_default_for_builder
    assert_equal Mime::XML, @response.content_type
    assert_equal "utf-8", @response.charset
  end

  def test_change_for_builder
    get :render_change_for_builder
    assert_equal Mime::HTML, @response.content_type
    assert_equal "utf-8", @response.charset
  end
end

class AcceptBasedContentTypeTest < ActionController::TestCase
  tests OldContentTypeController

  def test_render_default_content_types_for_respond_to
    @request.accept = Mime::HTML.to_s
    get :render_default_content_types_for_respond_to
    assert_equal Mime::HTML, @response.content_type

    @request.accept = Mime::JS.to_s
    get :render_default_content_types_for_respond_to
    assert_equal Mime::JS, @response.content_type
  end

  def test_render_default_content_types_for_respond_to_with_template
    @request.accept = Mime::XML.to_s
    get :render_default_content_types_for_respond_to
    assert_equal Mime::XML, @response.content_type
  end

  def test_render_default_content_types_for_respond_to_with_overwrite
    @request.accept = Mime::RSS.to_s
    get :render_default_content_types_for_respond_to
    assert_equal Mime::XML, @response.content_type
  end
end
