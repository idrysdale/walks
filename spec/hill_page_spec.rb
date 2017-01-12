require 'hill_page'
require 'hill'
require 'string'
require 'pry'

RSpec.describe HillPage do
  let(:hill) {
    Hill.new(
      1,
      "Kinder's Scout",
      [-1.874349, 53.384774],
      636,
      'SK084875',
      'https://en.wikipedia.org/wiki/Kinder_Scout'
    )
  }
  let(:temporary_file_directory) { 'tmp/hill_pages' }
  subject(:hill_page) { HillPage.new(temporary_file_directory, hill) }
  let(:file_path) { Dir.glob("#{temporary_file_directory}/*").first }

  before do
    FileUtils.rm_rf("#{temporary_file_directory}/.")
  end

  describe '#generate' do
    before do
      hill_page.generate()
    end

    it 'writes a haml file' do
      expect(File.extname(file_path)).to eq ".haml"
    end
  end
end
