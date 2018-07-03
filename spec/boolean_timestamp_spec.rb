RSpec.describe BooleanTimestamp do
  it "has a version number" do
    expect(BooleanTimestamp::VERSION).not_to be nil
  end

  context ".boolean_timestamp" do
    it "accepts a symbol argument" do
      klass = define_attribute(:published)
      expect(klass.new.published?).to be false
    end

    it "accepts a string argument" do
      klass = define_attribute("published")
      expect(klass.new.published?).to be false
    end

    it "fails if column name doesn't exist" do
      expect { define_attribute(:missing_column) }
        .to raise_error(ArgumentError, /unknown column 'articles\.missing_column_at'/)
    end
  end

  context "query scopes" do
    let(:now) { Time.now }

    before do
      Article.create!(title: "Before", published_at: now - 100)
      Article.create!(title: "On", published_at: now)
      Article.create!(title: "After", published_at: now + 100)
      Article.create!(title: "Nil")
    end

    after { Article.delete_all }

    context "positive" do
      it "only includes records before or matching the current time" do
        Timecop.freeze(now) do
          expect(Article.published.map(&:title)).to eq(%w[Before On])
        end
      end

      context "negative" do
        it "only includes records with null values or after the current time" do
          Timecop.freeze(now) do
            expect(Article.not_published.map(&:title)).to eq(%w[After Nil])
          end
        end
      end
    end
  end

  context "attribute reader" do
    it "returns true for values before current time" do
      expect(Article.new(published_at: Time.current - 100).published).to eq(true)
    end

    it "returns true for values matching current time" do
      expect(Article.new(published_at: Time.current).published).to eq(true)
    end

    it "returns false for values after current time" do
      expect(Article.new(published_at: Time.current + 100).published).to eq(false)
    end

    it "returns false for nil values" do
      expect(Article.new.published).to eq(false)
    end
  end

  context "boolean attribute reader" do
    it "returns true for values before current time" do
      expect(Article.new(published_at: Time.current - 100)).to be_published
    end

    it "returns true for values matching current time" do
      expect(Article.new(published_at: Time.current)).to be_published
    end

    it "returns false for values after current time" do
      expect(Article.new(published_at: Time.current + 100)).not_to be_published
    end

    it "returns false for nil values" do
      expect(Article.new).not_to be_published
    end
  end

  context "attribute writer" do
    it "sets current timestamp with truthy-ish value" do
      expect(Article.new(published: true)).to be_published
      expect(Article.new(published: "true")).to be_published
      expect(Article.new(published: "1")).to be_published
      expect(Article.new(published: "asdf")).to be_published

      expect(Article.new(published: true).published_at).to be_within(1).of(Time.now)
    end

    it "clears timestamp with falsey-ish value" do
      expect(Article.new(published: false)).not_to be_published
      expect(Article.new(published: "FALSE")).not_to be_published
      expect(Article.new(published: 0)).not_to be_published
      expect(Article.new(published: "0")).not_to be_published
      expect(Article.new(published: "f")).not_to be_published
      expect(Article.new(published: "off")).not_to be_published
    end

    it "does not update timestamp with truthy-ish value if already present" do
      post = Article.new(published_at: Time.current - 100)
      expect { post.published = true }.not_to(change { post.published_at })
    end

    it "works as expected when persisting and fetching from the database" do
      post_id = Article.create!.id
      expect(Article.find(post_id)).not_to be_published

      Article.find(post_id).update!(published: true)
      expect(Article.find(post_id)).to be_published

      expect { Article.find(post_id).update!(published: true) }
        .not_to(change { Article.find(post_id).published_at })
      expect(Article.find(post_id)).to be_published

      expect { Article.find(post_id).update!(published: false) }
        .to change { Article.find(post_id).published }.from(true).to(false)
    end
  end

  private

  def define_attribute(method_name)
    Class.new(ActiveRecord::Base) do
      self.table_name = "articles"

      include BooleanTimestamp

      boolean_timestamp method_name
    end
  end
end

class Article < ActiveRecord::Base
  include BooleanTimestamp

  boolean_timestamp :published
end
