require 'rails_helper'
require 'cancan/matchers'

RSpec.describe Ability, type: :model do
  let(:admin) { User.new(email: 'alice@example.org', role: :admin) }
  let(:curator) { User.new email: 'carol@example.org', role: :curator }
  let(:default) { User.new email: 'ursula@example.org', role: :user }
  let(:book) { Book.new }
  let(:version) { Version.new }

  describe 'an admin user can CRUD books, versions and users' do
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

  describe 'a default user cannot CRUD books, versions or users' do
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
end
