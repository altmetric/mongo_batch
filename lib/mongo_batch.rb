module MongoBatch
  class Batcher
    attr_reader :query, :batch_size, :to, :offset, :order_by

    def initialize(query, options = {})
      @query = query
      @batch_size = options.fetch(:batch_size) { 1_000 }
      @to = options.fetch(:to) { query.count }
      @offset = options.fetch(:offset) { 0 }
      @order_by = options.fetch(:order_by) { { _id: :asc } }
    end

    def batches
      Enumerator.new(to) do |yielder|
        processed_so_far = offset

        offset.step(by: batch_size, to: to - batch_size).each do |offset|
          yielder << query.order_by(order_by).limit(batch_size).skip(offset)
          processed_so_far += batch_size
        end

        if processed_so_far < to
          last_limit = to - processed_so_far
          yielder << query.order(order_by).limit(last_limit).skip(processed_so_far)
        end
      end
    end
  end

  def self.in_batches(query, options = {})
    Batcher.new(query, options).batches
  end

  def find_in_batches(options = {}, &block)
    batcher = Batcher.new(self, options)

    if block
      batcher.batches.each(&block)
    else
      batcher.batches
    end
  end
end
