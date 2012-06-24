require File.expand_path('../../../../spec/helper', __FILE__)
require 'fileutils'
require 'tempfile'

class SpecUploadHelper < Ramaze::Controller
  map '/'

  helper :upload

  handle_uploads_for :auto_upload
  handle_uploads_for [:auto_upload_pattern, /file_2/]

  def empty
    if get_uploaded_files.empty?
      return 'empty'
    else
      return 'not empty'
    end
  end

  def upload
    get_uploaded_files.each_pair do |k, v|
      v.save(File.join('/tmp/ramaze_uploads', v.filename))

      return 'not uploaded' unless v.saved?
    end

    return 'uploaded'
  end

  # If all goes well this should behave exactly the same as upload() with the
  # difference that the uploads are processed in handle_uploads_for() and then
  # just returned.
  def auto_upload
    return upload
  end

  def auto_upload_pattern
    return upload
  end
end

describe('Ramaze::Helper::Upload') do
  behaves_like :rack_test

  before { Dir.mkdir('/tmp/ramaze_uploads') }
  after  { FileUtils.rm_rf('/tmp/ramaze_uploads') }

  it('No files should be uploaded') do
    get('/empty').body.strip.should === 'empty'
  end

  it('Upload a text file') do
    file = Rack::Test::UploadedFile.new(
      __DIR__('uploads/text_1.txt'),
      'text/plain'
    )

    body = post('/upload', :file_1 => file).body.strip

    body.should === 'uploaded'

    File.exist?('/tmp/ramaze_uploads/text_1.txt').should     === true
    File.read('/tmp/ramaze_uploads/text_1.txt').strip.should === 'Hello world'
  end

  it('Upload multiple files') do
    file_1 = Rack::Test::UploadedFile.new(
      __DIR__('uploads/text_1.txt'),
      'text/plain'
    )

    file_2 = Rack::Test::UploadedFile.new(
      __DIR__('uploads/text_2.txt'),
      'text/plain'
    )

    body = post('/upload', :file_1 => file_1, :file_2 => file_2).body.strip

    body.should === 'uploaded'

    File.exist?('/tmp/ramaze_uploads/text_1.txt').should     === true
    File.read('/tmp/ramaze_uploads/text_1.txt').strip.should === 'Hello world'

    File.exist?('/tmp/ramaze_uploads/text_2.txt').should     === true
    File.read('/tmp/ramaze_uploads/text_2.txt').strip.should === 'Hello Ramaze'
  end

  it('Automatically handle uploads') do
    file_1 = Rack::Test::UploadedFile.new(
      __DIR__('uploads/text_1.txt'),
      'text/plain'
    )

    body = post('/auto_upload', :file_1 => file_1).body.strip

    body.should === 'uploaded'

    File.exist?('/tmp/ramaze_uploads/text_1.txt').should     === true
    File.read('/tmp/ramaze_uploads/text_1.txt').strip.should === 'Hello world'
  end

  it('Automatically handle uploads using a pattern') do
    file_1 = Rack::Test::UploadedFile.new(
      __DIR__('uploads/text_1.txt'),
      'text/plain'
    )

    file_2 = Rack::Test::UploadedFile.new(
      __DIR__('uploads/text_2.txt'),
      'text/plain'
    )

    body = post(
      '/auto_upload_pattern',
      :file_1 => file_1,
      :file_2 => file_2
    ).body.strip

    body.should === 'uploaded'

    File.exist?('/tmp/ramaze_uploads/text_1.txt').should     === true
    File.exist?('/tmp/ramaze_uploads/text_2.txt').should     === false
    File.read('/tmp/ramaze_uploads/text_1.txt').strip.should === 'Hello world'
  end
end

describe('Ramaze::Helper::Upload::UploadedFile') do
  before { Dir.mkdir('/tmp/ramaze_uploads') }
  after  { FileUtils.rm_rf('/tmp/ramaze_uploads') }

  it('Create a new file') do
    path = __DIR__('uploads/text_1.txt')
    file = Ramaze::Helper::Upload::UploadedFile.new(
      path,
      'text/plain',
      Tempfile.new('text_1.txt'),
      Ramaze::Helper::Upload::ClassMethods.trait[:default_upload_options]
    )

    file.filename.should  === 'text_1.txt'
    file.type.should      === 'text/plain'
    file.path.nil?.should === true

    file.save('/tmp/ramaze_uploads/text_1.txt')

    file.path.nil?.should === false
    file.instance_variable_get("@realfile").closed?.should === true
  end
end
