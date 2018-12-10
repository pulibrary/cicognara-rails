require 'rails_helper'

RSpec.describe 'comments', type: :feature do
  let(:user) { User.create! email: 'user@example.org', role: 'curator' }
  let(:comment) { Comment.create! text: 'comment 1', entry_id: entry.id, user_id: user.id, timestamp: DateTime.now.in_time_zone }
  let(:entry) { Entry.first }
  let(:marc) { File.join(File.dirname(__FILE__), '..', 'fixtures', 'cicognara.marc.xml') }
  let(:tei) { File.join(File.dirname(__FILE__), '..', 'fixtures', 'cicognara.tei.xml') }
  let(:file_uri) { "file://#{marc}//marc:record[0]" }
  let(:tei_indexer) { Cicognara::TEIIndexer.new(tei, marc) }
  let(:tei_solr_documents) { tei_indexer.solr_docs }
  let(:solr_client) { Blacklight.default_index.connection }

  before do
    MarcIndexer.new.process(marc, file_uri)

    solr_client.add(tei_solr_documents)
    solr_client.commit

    comment
  end

  context 'a logged in user' do
    before do
      stub_admin_user
    end

    it 'displays comments with buttons for editing/deleting' do
      visit solr_document_path entry.id
      expect(page).to have_selector 'p.comment-text', text: 'comment 1'
      expect(page).to have_link 'Edit', href: edit_comment_path(comment.id)
      expect(page).to have_link 'Delete', href: comment_path(comment.id)
    end
    it 'displays form for adding comments' do
      visit solr_document_path entry.id
      expect(page).to have_button 'Add Comment'
    end
  end

  context 'a user who is not logged in' do
    before do
      stub_public_user
    end
    it 'displays comments without buttons for editing/deleting' do
      visit solr_document_path entry.id
      expect(page).to have_selector 'p.comment-text', text: 'comment 1'
      expect(page).not_to have_link 'Edit', href: edit_comment_path(comment.id)
      expect(page).not_to have_link 'Delete', href: comment_path(comment.id)
    end
  end
end
