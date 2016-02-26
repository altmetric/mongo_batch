require 'spec_helper'
require 'mongo_batch'

describe MongoBatch do
  class Post
    include Mongoid::Document
    include Mongoid::Timestamps
    extend MongoBatch

    field :body, type: String
    field :index, type: Integer
  end

  describe '#find_in_batches' do
    it 'yields to the given block for each batch of records' do
      posts = FactoryGirl.create_list(:post, 10).sort_by(&:id)

      expect do |block|
        Post.find_in_batches(batch_size: 2).each(&block)
      end.to yield_successive_args(posts[(0..1)],
                                   posts[(2..3)],
                                   posts[(4..5)],
                                   posts[(6..7)],
                                   posts[(8..9)])
    end

    it 'returns an enumerator if a block is not given' do
      expect(Post.find_in_batches(batch_size: 2)).to be_an(Enumerator)
    end
  end

  describe '.in_batches' do
    it 'returns an enumerator if a block is not given' do
      expect(described_class.in_batches(batch_size: 2)).to be_an(Enumerator)
    end

    it 'starts from the first record if "offset" is not specified' do
      posts = FactoryGirl.create_list(:post, 4).sort_by(&:id)

      batches = described_class.in_batches(Post).map(&:to_a)

      expect(batches.first).to start_with(posts[0])
    end

    it 'skips the number of records indicated in "offset"' do
      posts = FactoryGirl.create_list(:post, 4)

      posts_in_batches = described_class.in_batches(Post, batch_size: 2, offset: 3).map(&:to_a)

      expect(posts_in_batches).to eq([[posts[3]]])
    end

    it 'calculates the count of records if "to" is not specified' do
      posts = FactoryGirl.create_list(:post, 4)

      posts_in_batches = described_class.in_batches(Post, batch_size: 2).map(&:to_a)

      expect(posts_in_batches).to eq([posts[(0..1)], posts[(2..3)]])
    end

    it 'does not calculate the count of records if "to" is specified' do
      FactoryGirl.create_list(:post, 4)

      expect(Post).not_to receive(:count)

      described_class.in_batches(Post, to: 1).map(&:to_a)
    end

    it 'orders the elements ascending by _id by default' do
      posts = FactoryGirl.create_list(:post, 10).sort_by(&:id)

      ids = Post.find_in_batches(batch_size: 2).map(&:to_a).flatten.map(&:id)

      expect(ids).to eq(posts.map(&:id))
    end

    it 'allows to specify a custom sorting order' do
      posts = FactoryGirl.create_list(:post, 10).sort_by(&:id)

      ids = described_class
            .in_batches(Post, batch_size: 2, order_by: { id: 'desc' })
            .map(&:to_a)
            .flatten
            .map(&:id)

      expect(ids).to eq(posts.map(&:id).reverse)
    end

    it 'does not enforce an order if one is already applied' do
      posts = 1.upto(10).map { |n| FactoryGirl.create(:post, index: n) }

      posts_in_batches = described_class
                         .in_batches(Post.desc(:index), batch_size: 5)
                         .map(&:to_a)

      expect(posts_in_batches).to eq([posts[5..9].reverse, posts[0..4].reverse])
    end

    it 'preserves any scopes previously applied' do
      posts = FactoryGirl.create_list(:post, 5, body: 'Hello world!')
      FactoryGirl.create_list(:post, 1)

      posts_in_batches = described_class
                         .in_batches(Post.where(:body.exists => true), batch_size: 2)
                         .map(&:to_a)

      expect(posts_in_batches).to eq([posts[(0..1)], posts[(2..3)], posts[(4..5)]])
    end

    context 'when "to" is a multiple of the batch size' do
      it 'splits the query into uniform batches covering all the records in the query' do
        posts = FactoryGirl.create_list(:post, 10)

        posts_in_batches = described_class.in_batches(Post, batch_size: 2, to: 10).map(&:to_a)

        expect(posts_in_batches).to eq([posts[(0..1)],
                                        posts[(2..3)],
                                        posts[(4..5)],
                                        posts[(6..7)],
                                        posts[(8..9)]])
      end
    end

    context 'when "to" is not a multiple of the batch size' do
      it 'splits the query into batches covering all the records in the query' do
        posts = FactoryGirl.create_list(:post, 10)

        posts_in_batches = described_class.in_batches(Post, batch_size: 3, to: 10).map(&:to_a)

        expect(posts_in_batches).to eq([posts[(0..2)],
                                        posts[(3..5)],
                                        posts[(6..8)],
                                        posts[(9..9)]])
      end
    end
  end
end
