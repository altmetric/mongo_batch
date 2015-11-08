# MongoBatch

A Ruby library to run Mongoid queries on large collections in batches.

**Supported Ruby versions:** 2.1, 2.2

**Supported Mongoid versions:** 4.0, 5.0

## Usage

Extend your Mongoid models with `MongoBatch` to be able to call
`find_in_batches` on your models. The method will yield each batch of
records to the given block.

```ruby
require 'mongo_batch'

class Post
  extend MongoBatch
end

Post.find_in_batches do |batch|
  batch.each do |post|
    post.update(body: 'Hello world!')
  end
end
```

If you do not pass a block to `find_in_batches`, the method will
return an [Enumerator](http://ruby-doc.org/core-2.2.2/Enumerator.html).

```ruby
Post.find_in_batches.with_index.each do |batch, index|
  batch.each do |post|
    post.update(body: "Hello world! #{index}")
  end
end
```

The default batch size is 1,000 records, but `find_in_batches` accepts
an option to configure a different batch size, as well as options to
limit the records to process, sorting criteria and an initial offset.

```ruby
Post
  .find_in_batches(batch_size: 500, to: 2_000, offset: 100, order_by: { _id: :desc })
  .each do |batch|
    batch.each do |post|
      post.update(body: "Hola mundo!")
    end
end

```

If you have more complex queries or prefer not to extend your models
with `MongoBatch`,
you can use `MongoBatch.in_batches` and supply the query you want to batch.

```ruby
MongoBatch
  .in_batches(Post.where(:body.exists => true).no_timeout)
  .each do |batch|
    batch.each do |post|
      post.update(body: 'Hello world!')
    end
end
```

`MongoBatch.in_batches` also accepts values to configure the batch size, limit of
records to process, sorting criteria or an initial offset.

```ruby
MongoBatch
  .in_batches(Post.where(:body.exists => true).no_timeout,
              to: 2_000, offset: 100, order_by: { _id::desc })
  .each do |batch|
     batch.each do |post|
       post.update(body: 'Hi mum!')
     end
  end
```

## License

Copyright © 2015 Altmetric LLP

Distributed under the MIT License.

[URI]: http://ruby-doc.org/stdlib/libdoc/uri/rdoc/URI.html

