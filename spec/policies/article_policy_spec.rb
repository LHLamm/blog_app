require "rails_helper"

RSpec.describe ArticlePolicy do
  let(:admin) { create(:user, :admin) }
  let(:writer) { create(:user) }
  let(:other_writer) { create(:user) }

  let(:own_draft) { create(:article, author: writer, status: :draft) }
  let(:own_published) { create(:article, :published, author: writer) }
  let(:own_archived) { create(:article, author: writer, status: :archived) }
  let(:others_draft) { create(:article, author: other_writer, status: :draft) }
  let(:others_published) { create(:article, :published, author: other_writer) }
  let(:others_archived) { create(:article, author: other_writer, status: :archived) }

  describe "#index?" do
    it "allows anyone, including guests" do
      expect(described_class.new(nil, Article)).to be_index
      expect(described_class.new(writer, Article)).to be_index
    end
  end

  describe "#show?" do
    it "allows anyone (including guests) to view published articles" do
      expect(described_class.new(nil, others_published)).to be_show
      expect(described_class.new(writer, others_published)).to be_show
    end

    it "allows anyone (including guests) to view archived articles" do
      expect(described_class.new(nil, others_archived)).to be_show
      expect(described_class.new(writer, others_archived)).to be_show
    end

    it "allows the owner to view their own draft" do
      expect(described_class.new(writer, own_draft)).to be_show
    end

    it "denies a writer viewing another writer's draft" do
      expect(described_class.new(writer, others_draft)).not_to be_show
    end

    it "denies a guest (not logged in) viewing a draft" do
      expect(described_class.new(nil, others_draft)).not_to be_show
    end

    it "allows admin to view any draft" do
      expect(described_class.new(admin, others_draft)).to be_show
    end
  end

  describe "#create?" do
    it "allows any logged-in user" do
      expect(described_class.new(writer, Article.new)).to be_create
    end

    it "denies a guest" do
      expect(described_class.new(nil, Article.new)).not_to be_create
    end
  end

  describe "#update?" do
    it "allows the owner to edit their own draft" do
      expect(described_class.new(writer, own_draft)).to be_update
    end

    it "denies the owner editing their own published article" do
      expect(described_class.new(writer, own_published)).not_to be_update
    end

    it "denies editing another writer's draft" do
      expect(described_class.new(writer, others_draft)).not_to be_update
    end

    it "allows admin to edit any article regardless of status" do
      expect(described_class.new(admin, own_published)).to be_update
      expect(described_class.new(admin, others_draft)).to be_update
    end

    it "denies the owner editing their own archived article" do
      expect(described_class.new(writer, own_archived)).not_to be_update
    end

    it "denies a guest (not logged in) from editing any article" do
      expect(described_class.new(nil, own_draft)).not_to be_update
      expect(described_class.new(nil, others_published)).not_to be_update
    end
  end

  describe "#publish?" do
    it "allows the owner to publish their own draft" do
      expect(described_class.new(writer, own_draft)).to be_publish
    end

    it "denies publishing another writer's draft" do
      expect(described_class.new(writer, others_draft)).not_to be_publish
    end

    it "allows admin to publish any article" do
      expect(described_class.new(admin, others_draft)).to be_publish
    end

    it "denies a guest (not logged in) from publishing" do
      expect(described_class.new(nil, own_draft)).not_to be_publish
    end
  end

  describe "Scope" do
    subject(:resolved_scope) { described_class::Scope.new(user, Article.all).resolve }

    before do
      own_draft
      own_published
      own_archived
      others_draft
      others_published
      others_archived
    end

    context "as a guest" do
      let(:user) { nil }

      it "only includes non-draft articles" do
        expect(resolved_scope).to contain_exactly(own_published, own_archived, others_published, others_archived)
      end
    end

    context "as a writer" do
      let(:user) { writer }

      it "includes own articles (any status) plus everyone else's non-draft articles" do
        expect(resolved_scope).to contain_exactly(
          own_draft, own_published, own_archived, others_published, others_archived
        )
      end
    end

    context "as an admin" do
      let(:user) { admin }

      it "includes every article regardless of status or author" do
        expect(resolved_scope).to contain_exactly(
          own_draft, own_published, own_archived, others_draft, others_published, others_archived
        )
      end
    end
  end
end
