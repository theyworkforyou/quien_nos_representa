class YNR < Jekyll::Generator
  SOURCES = [
    {
      'source' => 'candidates-mun-re-2016.csv',
      'collection_name' => 'regidores',
      'filters' => {
        'elected' => 'True'
      }
    },
    {
      'source' => 'candidates-mun-al-2016.csv',
      'collection_name' => 'alcades',
      'filters' => {
        'elected' => 'True'
      }
    }
  ]

  def generate(site)
    SOURCES.each do |csv|
      csv['filters'] ||= {}
      Jekyll::Csv::CollectionPopulator.new(csv).populate(site)
      site.collections[csv['collection_name']].docs = site.collections[csv['collection_name']].docs.find_all do |doc|
        csv['filters'].all? { |k, v| doc.data[k] == v }
      end
    end

    cantons = Jekyll::Collection.new(site, 'cantons')
    alcades_cantons = site.collections['alcades'].docs.group_by { |r| r['post_label'].sub(/^Alcalde de /, '') }
    regidores_cantons = site.collections['regidores'].docs.group_by { |r| r['post_label'].sub(/^Regidor de /, '') }
    canton_names = (alcades_cantons.keys + regidores_cantons.keys).uniq.sort
    canton_names.each do |canton_name|
      path = File.join(site.source, "_cantons", "#{Jekyll::Utils.slugify(canton_name)}.md")
      canton = Jekyll::Document.new(path, collection: cantons, site: site)
      alcades = alcades_cantons[canton_name].to_a
      regidores = regidores_cantons[canton_name].to_a
      canton.merge_data!(
        'name' => canton_name,
        'alcades' => alcades,
        'regidores' => regidores
      )
      if site.layouts.key?('cantons')
        canton.merge_data!('layout' => 'cantons')
      end
      cantons.docs << canton
      (alcades + regidores).each { |r| r.data['canton'] = canton }
    end
    site.collections['cantons'] = cantons
  end
end
