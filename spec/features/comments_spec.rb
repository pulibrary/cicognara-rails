require 'rails_helper'

RSpec.describe 'comments', type: :feature do
  let(:user) { User.create! email: 'user@example.org', role: 'curator' }
  let(:comment) { Comment.create! text: 'comment 1', entry_id: entry.id, user_id: user.id, timestamp: DateTime.now.in_time_zone }
  let(:entry) { Entry.first }

  before do
    marc = File.join(File.dirname(__FILE__), '..', 'fixtures', 'cicognara.marc.xml')
    MarcIndexer.new.process(marc)

    tei = File.join(File.dirname(__FILE__), '..', 'fixtures', 'cicognara.tei.xml')
    solr = RSolr.connect(url: Blacklight.connection_config[:url])
    solr.add(Cicognara::TEIIndexer.new(tei, marc).solr_docs)
    solr.commit

    comment
  end

  context 'with a logged in user' do
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

  context 'with a user who is not logged in' do
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
