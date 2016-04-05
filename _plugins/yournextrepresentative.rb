class YNR < Jekyll::Generator
  def generate(site)
    Jekyll::Csv::CollectionPopulator.new(
      'source' => 'http://tusrepresentanteslocales.co.cr/media/candidates-mun-re-2016.csv',
      'collection_name' => 'regidores'
    ).populate(site)
    site.collections['regidores'].docs = site.collections['regidores'].docs.find_all { |d| d.data['elected'] == 'True' }
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
