$LOAD_PATH.unshift './config'
require './app/models/book'
config = CicognaraRails::Application.config.database_configuration[::Rails.env]
ActiveRecord::Base.establish_connection(config)

class MarcIndexer < Blacklight::Marc::Indexer
  # this mixin defines lambda facotry method get_format for legacy marc formats
  include Blacklight::Marc::Indexer::Formats

  SEPARATOR = '—'

  GENRES = [
  'Bibliography',
  'Biography',
  'Catalogs',
  'Catalogues raisonnes',
  'Commentaries',
  'Congresses',
  'Diaries',
  'Dictionaries',
  'Drama',
  'Encyclopedias',
  'Exhibitions',
  'Fiction',
  'Guidebooks',
  'In art',
  'Indexes',
  'Librettos',
  'Manuscripts',
  'Newspapers',
  'Periodicals',
  'Pictorial works',
  'Poetry',
  'Portraits',
  'Scores',
  'Songs and music',
  'Sources',
  'Statistics',
  'Texts',
  'Translations'
  ]

  GENRE_STARTS_WITH = [
    'Census',
    'Maps',
    'Methods',
    'Parts',
    'Personal narratives',
    'Scores and parts',
    'Study and teaching',
    'Translations into '
  ]

  def initialize
    super

    settings do
      # type may be 'binary', 'xml', or 'json'
      provide 'marc_source.type', 'xml'
      # set this to be non-negative if threshold should be enforced
      provide 'solr_writer.max_skipped', -1

      # configurable logging, quiet by default
      provide 'log.level', ENV['TRAJECT_LOG_LEVEL'] || 'warn'
    end

    to_field 'id' do |record, accumulator|
      ids = []
      Traject::MarcExtractor.cached('024a').collect_matching_lines(record) do |field, spec, extractor|
        id = extractor.collect_subfields(field, spec).first
        unless id.nil?
          field.subfields.each do |s_field|
            ids << id if (s_field.code == '2') and s_field.value == 'dclib'
          end
        end
      end
      accumulator.replace(ids.uniq)
    end

    to_field 'marc_display', get_xml
    to_field 'text', extract_all_marc_values do |_r, acc|
      acc.replace [acc.join(' ')] # turn it into a single string
    end

    to_field 'format', literal('marc')

    to_field 'language_facet', marc_languages('008[35-37]:041a:041d')

    # Title fields
    #    primary title

    to_field 'title_t', extract_marc('245abchknps')
    to_field 'title_display', extract_marc('245abcfghknps', trim_punctuation: true, alternate_script: false)

    #    additional title fields
    to_field 'title_addl_t',
             extract_marc(%W(
               245abnps
               130#{ATOZ}
               240abcdefgklmnopqrs
               210ab
               222ab
               242abnp
               243abcdefgklmnopqrs
               246abcdefgnp
               247abcdefgnp
             ).join(':'))

    to_field 'title_added_entry_t', extract_marc(%w(
      700gklmnoprst
      710fgklmnopqrst
      711fgklnpst
      730abcdefgklmnopqrst
      740anp
    ).join(':'))

    to_field 'title_series_t', extract_marc('440anpv:490av')

    to_field 'title_sort' do |record, accumulator|
      MarcExtractor.cached("245abcfghknps", :alternate_script => false).collect_matching_lines(record) do |field, spec, extractor|
        str = extractor.collect_subfields(field, spec).first
        str = str.slice(field.indicator2.to_i, str.length) if str
        accumulator << str if accumulator[0].nil?
      end
    end

    # Author fields

    to_field 'author_t', extract_marc('100aqbcdk:110abcdfgkln:111abcdfgklnpq:700aqbcdk:710abcdfgkln:711abcdfgklnpq', trim_punctuation: true)
    to_field 'author_display', extract_marc('100aqbcdk:110abcdfgkln:111abcdfgklnpq', trim_punctuation: true)
    to_field 'name_facet', extract_marc('100aqbcdk:110abcdfgkln:111abcdfgklnpq:700aqbcdk:710abcdfgkln:711abcdfgklnpq', trim_punctuation: true)
    to_field 'related_name_display', extract_marc('700aqbcdk:710abcdfgkln:711abcdfgklnpq', trim_punctuation: true)
    to_field 'author_sort', extract_marc('100aqbcdk:110abcdfgkln:111abcdfgklnpq', trim_punctuation: true, first: true)

    # Subject fields
    to_field 'subject_t' do |record, accumulator|
      subjects = []
      Traject::MarcExtractor.cached(%w(
        600|*0|abcdfklmnopqrtvxyz:
        610|*0|abfklmnoprstvxyz:
        611|*0|abcdefgklnpqstvxyz:
        630|*0|adfgklmnoprstvxyz:
        650|*0|abcvxyz:
        651|*0|avxyz
      )).collect_matching_lines(record) do |field, spec, extractor|
        subject = extractor.collect_subfields(field, spec).first
        unless subject.nil?
          field.subfields.each do |s_field|
            if (s_field.code == 'v' || s_field.code == 'x' || s_field.code == 'y' || s_field.code == 'z')
              subject = subject.gsub(" #{s_field.value}", "#{SEPARATOR}#{s_field.value}")
            end
          end
          subjects << Traject::Macros::Marc21.trim_punctuation(subject)
        end
      end
      accumulator.replace(subjects)
    end

    to_field 'subject_topic_facet' do |record, accumulator|
      subjects = []
      Traject::MarcExtractor.cached(%w(
        600|*0|abcdfklmnopqrtxz:
        610|*0|abfklmnoprstxz:
        611|*0|abcdefgklnpqstxz:
        630|*0|adfgklmnoprstxz:
        650|*0|abcxz:
        651|*0|axz
      )).collect_matching_lines(record) do |field, spec, extractor|
        subject = extractor.collect_subfields(field, spec).first
        unless subject.nil?
          field.subfields.each do |s_field|
            if (s_field.code == 'x' || s_field.code == 'z')
              subject = subject.gsub(" #{s_field.value}", "#{SEPARATOR}#{s_field.value}")
            end
          end
          subject = subject.split(SEPARATOR)
          subjects << subject.map { |s| Traject::Macros::Marc21.trim_punctuation(s) }
        end
      end
      accumulator.replace(subjects.flatten.uniq)
    end

    # 600/610/650/651 $v, $x filtered
    # 655 $a, $v, $x filtered
    to_field 'subject_genre_facet' do |record, accumulator|
      genres = []
      Traject::MarcExtractor.cached(%w(
        600|*0|x:610|*0|x:611|*0|x:
        630|*0|x:650|*0|x:651|*0|x:655|*0|x
      )).collect_matching_lines(record) do |field, spec, extractor|
        genre = extractor.collect_subfields(field, spec).first
        unless genre.nil?
          genre = Traject::Macros::Marc21.trim_punctuation(genre)
          genres << genre if GENRES.include?(genre) || GENRE_STARTS_WITH.any? { |g| genre[g] }
        end
      end
      Traject::MarcExtractor.cached(%w(
        600|*0|v:610|*0|v:611|*0|v:
        630|*0|v:650|*0|v:651|*0|v:
        655|*0|a:655|*0|v
      )).collect_matching_lines(record) do |field, spec, extractor|
        genre = extractor.collect_subfields(field, spec).first
        unless genre.nil?
          genre = Traject::Macros::Marc21.trim_punctuation(genre)
          genres << genre
        end
      end
      accumulator.replace(genres.uniq)
    end

    to_field 'subject_era_facet', marc_era_facet
    to_field 'subject_geo_facet', extract_marc('651a:650z', trim_punctuation: true)

    # Publication fields
    to_field 'published_t', extract_marc('260abcefg:264abcefg')
    to_field 'pub_date', marc_publication_date

    # Analytics
    to_field 'contents_t', extract_marc('505|0*|agrt:505|8*|agrt')

    # Edition Statement
    to_field 'edition_t', extract_marc('250ab')

    each_record do |record, context|
      # add display fields
      context.output_hash['dclib_display'] = context.output_hash['id']
      context.output_hash['published_display'] = context.output_hash['published_t'] unless context.output_hash['published_t'].nil?
      context.output_hash['title_addl_display'] = context.output_hash['title_addl_t'] unless context.output_hash['title_addl_t'].nil?
      context.output_hash['title_added_entry_display'] = context.output_hash['title_added_entry_t'] unless context.output_hash['title_added_entry_t'].nil?
      context.output_hash['title_series_display'] = context.output_hash['title_series_t'] unless context.output_hash['title_series_t'].nil?
      context.output_hash['subject_facet'] = context.output_hash['subject_t'] unless context.output_hash['subject_t'].nil?
      context.output_hash['contents_display'] = context.output_hash['contents_t'] unless context.output_hash['contents_t'].nil?
      context.output_hash['edition_display'] = context.output_hash['edition_t'] unless context.output_hash['edition_t'].nil?
      context.output_hash['language_display'] = context.output_hash['language_facet'] unless context.output_hash['language_facet'].nil?
    end
  end
end

class SolrWriterAccumulator < Traject::SolrJsonWriter
  attr_reader :all_records

  def initialize(argSettings)
    super
    @all_records = {}
  end

  def put(context)
    super
    @all_records[context.output_hash['id'].first] = context.output_hash
  end
end
