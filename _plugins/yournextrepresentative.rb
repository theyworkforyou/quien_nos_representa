class YNR < Jekyll::Generator
  SOURCES = [
    {
      'source' => 'http://tusrepresentanteslocales.co.cr/media/candidates-mun-re-2016.csv',
      'collection_name' => 'regidores',
      'filters' => {
        'elected' => 'True'
      }
    }
  ]

  def generate(site)
    SOURCES.each do |csv|
      csv['filters'] ||= {}
      Jekyll::Csv::CollectionPopulator.new(csv).populate(site)
      site.collections[collection].docs = site.collections[collection].docs.find_all do |doc|
        csv['filters'].all? { |k, v| doc.data[k] == v }
      end
    end

    cantons = Jekyll::Collection.new(site, 'cantons')
    site.collections['regidores'].docs.group_by { |r| r['post_label'] }.each do |canton_name, regidores|
      path = File.join(site.source, "_cantons", "#{Jekyll::Utils.slugify(canton_name)}.md")
      canton = Jekyll::Document.new(path, collection: cantons, site: site)
      canton.merge_data!(
        'name' => canton_name,
        'regidores' => regidores
      )
      if site.layouts.key?('cantons')
        canton.merge_data!('layout' => 'cantons')
      end
      cantons.docs << canton
      regidores.each { |r| r.data['canton'] = canton }
    end
    site.collections['cantons'] = cantons
  end
end
