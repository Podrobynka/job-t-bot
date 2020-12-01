# frozen_string_literal: true

VCR.configure do |c|
  c.hook_into :webmock
  c.cassette_library_dir = Rails.root.join('spec', 'vcr')
  c.configure_rspec_metadata!
  c.ignore_hosts '127.0.0.1', 'localhost'

  # Let's you set default VCR mode with VCR_RESET=true for re-recording
  # episodes. :once is VCR default
  c.default_cassette_options = { record: :all } if ENV['VCR_RESET'] == 'true'
end

VCR::Cassette::Persisters::FileSystem
  .singleton_class
  .prepend(
    Module.new do
      def sanitized_file_name_from(*)
        super.tableize.singularize
      end
    end
  )
