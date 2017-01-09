require 'excursion_page'
require 'excursion'
require 'string'

RSpec.describe ExcursionPage do
  let(:excursion) {
    Excursion.new(
      1,
      "Way of the Roses",
      [1, 2, 3],
    )
  }
  let(:temporary_file_directory) { 'tmp/excursions_pages' }
  subject(:excursion_page) {
    ExcursionPage.new(temporary_file_directory, excursion)
  }
  let(:file_path) { Dir.glob("#{temporary_file_directory}/*").first }

  before do
    FileUtils.mkdir_p temporary_file_directory
    FileUtils.rm_rf("#{temporary_file_directory}/.")
  end

  describe '#generate' do
    before do
      excursion_page.generate()
    end

    it 'writes a haml file' do
      expect(File.extname(file_path)).to eq ".haml"
    end
  end
end
