require 'rails_helper'
require 'cancan/matchers'

RSpec.describe Ability, type: :model do
  let(:admin) { User.new(email: 'alice@example.org', role: :admin) }
  let(:curator) { User.create email: 'carol@example.org', role: :curator }
  let(:default) { User.new email: 'ursula@example.org', role: :user }
  let(:book) { Book.new }
  let(:version) { Version.new }
  let(:news_item) { NewsItem.new }
  let(:curator_news_item) { NewsItem.new(user_id: curator.id) }

  describe 'an admin user can CRUD books, versions, users, and news items' do
    subject { described_class.new admin }

    it { should be_able_to(:create, version) }
    it { should be_able_to(:read, version) }
    it { should be_able_to(:update, version) }
    it { should be_able_to(:destroy, version) }
    it { should be_able_to(:create, curator) }
    it { should be_able_to(:read, curator) }
    it { should be_able_to(:update, curator) }
    it { should be_able_to(:destroy, curator) }
    it { should be_able_to(:create, book) }
    it { should be_able_to(:read, book) }
    it { should be_able_to(:update, book) }
    it { should be_able_to(:destroy, book) }
    it { should be_able_to(:create, news_item) }
    it { should be_able_to(:read, news_item) }
    it { should be_able_to(:update, news_item) }
    it { should be_able_to(:destroy, news_item) }
  end

  describe 'a curator user can read books, CRUD versions, but not CRUD users' do
    subject { described_class.new curator }

    it { should be_able_to(:create, version) }
    it { should be_able_to(:read, version) }
    it { should be_able_to(:update, version) }
    it { should be_able_to(:destroy, version) }
    it { should_not be_able_to(:create, curator) }
    it { should_not be_able_to(:read, curator) }
    it { should_not be_able_to(:update, curator) }
    it { should_not be_able_to(:destroy, curator) }
    it { should_not be_able_to(:create, book) }
    it { should be_able_to(:read, book) }
    it { should_not be_able_to(:update, book) }
    it { should_not be_able_to(:destroy, book) }
  end

  describe 'a curator user can CR news items as well as UD their own news items' do
    subject { described_class.new curator }

    it { should be_able_to(:create, news_item) }
    it { should be_able_to(:read, news_item) }
    it { should_not be_able_to(:update, news_item) }
    it { should_not be_able_to(:destroy, news_item) }
    it { should be_able_to(:create, curator_news_item) }
    it { should be_able_to(:read, curator_news_item) }
    it { should be_able_to(:update, curator_news_item) }
    it { should be_able_to(:destroy, curator_news_item) }
  end

  describe 'a default user cannot CRUD books, versions, or users' do
    subject { described_class.new default }

    it { should_not be_able_to(:create, version) }
    it { should_not be_able_to(:read, version) }
    it { should_not be_able_to(:update, version) }
    it { should_not be_able_to(:destroy, version) }
    it { should_not be_able_to(:create, curator) }
    it { should_not be_able_to(:read, curator) }
    it { should_not be_able_to(:update, curator) }
    it { should_not be_able_to(:destroy, curator) }
    it { should_not be_able_to(:create, book) }
    it { should_not be_able_to(:read, book) }
    it { should_not be_able_to(:update, book) }
    it { should_not be_able_to(:destroy, book) }
  end

  describe 'a default user can read but cannot CUD news items' do
    subject { described_class.new default }

    it { should_not be_able_to(:create, news_item) }
    it { should be_able_to(:read, news_item) }
    it { should_not be_able_to(:update, news_item) }
    it { should_not be_able_to(:destroy, news_item) }
  end
end
