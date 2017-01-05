class WikipediaHillScraper
  require 'nokogiri'
  require 'open-uri'
  require 'silva'
  require_relative 'hill_data'

  def initialize(domain, path, hill_store)
    @domain = domain
    @url = domain + path
    @hill_store = hill_store
  end

  def scrape_hills
    nodes = Nokogiri::HTML(open(@url))

    hill_table_rows = nodes.css('table.wikitable tr')

    remove_heading_row(hill_table_rows)

    hills = hill_table_rows.map { |tr|
      name = tr.at('td[1]').text
      absolute_height = tr.at('td[2]').text.gsub(/\D/, '')
      grid_ref = tr.at('td[4]').text.strip
      link = tr.at('td[1]').at_css('a')['href'] if tr.at('td[1]').at_css('a')

      if link and !link.start_with?('/w/index')
        link = @domain + link
      else
        link = nil
      end

      HillData.new(
        name,
        grid_ref_to_lat_long(grid_ref),
        absolute_height,
        grid_ref,
        link
      )
    }

    hills.each { |hill| @hill_store.push(hill) }
  end

  private

  def remove_heading_row(table_rows)
    table_rows.shift
  end

  def grid_ref_to_lat_long(grid_ref)
    wgs84 = Silva::Location.from(:gridref, gridref: grid_ref).to(:wgs84)
    return [ wgs84.long, wgs84.lat ]
  end

end
