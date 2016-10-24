# frozen_string_literal: true
ActiveRecord::Type.register(:tei_type, TeiType)
ActiveRecord::Type.register(:nokogiri_type, NokogiriType)
ActiveRecord::Type.register(:marc_nokogiri_type, MarcNokogiriType)
