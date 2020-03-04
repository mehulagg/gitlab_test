---
description: "Sometimes it is necessary to store large amounts of records at once, which can be inefficient
when iterating collections and performing individual `save`s. With the arrival of `insert_all`
in Rails 6, which operates at the row level (that is, using `Hash`es), GitLab has added a set
of APIs that make it safe and simple to insert ActiveRecord objects in bulk."
---

# Insert into tables in batches

Sometimes it is necessary to store large amounts of records at once, which can be inefficient
when iterating collections and performing individual `save`s. With the arrival of
[`insert_all`](https://apidock.com/rails/ActiveRecord/Persistence/ClassMethods/insert_all)
in Rails 6, which operates at the row level (that is, using `Hash`es), GitLab has added a set
of APIs that make it safe and simple to insert `ActiveRecord` objects in bulk.

## Prepare `ApplicationRecord`s for bulk insertion

In order for a model class to take advantage of the bulk insertion API, it has to include the
`BulkInsertSafe` concern first:

```ruby
class MyModel < ApplicationRecord
  # other includes here
  # ...
  include BulkInsertSafe # include this last

  # ...
end
```

The `BulkInsertSafe` concern has two functions:

- It performs checks against your model class to ensure that it does not use ActiveRecord
  APIs that are not safe to use with respect to bulk insertions (more on that below)
- It adds a new class method `bulk_insert!`, which you can use to insert many records at once

## Insert records via `bulk_insert!`

If the target class passes the checks performed by `BulkInsertSafe`, you can proceed to use
the `bulk_insert!` class method as follows:

```ruby
records = [MyModel.new, ...]

MyModel.bulk_insert!(records)
```

### Record validation

The `bulk_insert!` method guarantees that `records` will be inserted transactionally, and
will run validations on each record prior to insertion. If any record fails to validate,
an error is raised and the transaction is rolled back. You can turn off validations via
the `:validate` option:

```ruby
MyModel.bulk_insert!(records, validate: false)
```

### Batch size configuration

In those cases where the `records` collection is very large, it will be broken down into
several smaller batches for you. You can control the size of each batch that is generated
via the `:batch_size` option:

```ruby
MyModel.bulk_insert!(records, batch_size: 100)
```

Since this will affect the number of `INSERT`s that will occur, make sure you measure the
performance impact this might have on your code.

### Requirements for safe bulk insertions

Large parts of ActiveRecord's persistence API are built around the notion of callbacks. Many
of these callbacks fire in response to model life cycle events such as `save` or `create`.
These callbacks cannot be used with bulk insertions, since they are meant to be called for
every instance that is saved or created. Since these events do not fire when
records are inserted in bulk, we currently disallow their use.

The specifics around which callbacks are disallowed are defined in `BulkInsertSafe`.
Consult the module source code for details. If your class uses any of the blacklisted
functionality, and you `include BulkInsertSafe`, the application will fail with an error.

### `BulkInsertSafe` versus `InsertAll`

Internally, `BulkInsertSafe` is based on `InsertAll`, and you may wonder when to choose
the former over the latter. To help you make the decision,
the key differences between these classes are listed in the table below.

|                | Input type           | Validates input | Specify batch size | Can bypass callbacks              | Transactional |
|--------------- | -------------------- | --------------- | ------------------ | --------------------------------- | ------------- |
| `bulk_insert!` | ActiveRecord objects | Yes (optional)  | Yes (optional)     | No (prevents unsafe callback use) | Yes           |
| `insert_all!`  | Attribute hashes     | No              | No                 | Yes                               | Yes           |

To summarize, `BulkInsertSafe` moves bulk inserts closer to how ActiveRecord objects
and inserts would normally behave. However, if all you need is to insert raw data in bulk, then
`insert_all` is more efficient.

## Insert `has_many` associations in bulk

A common use case is to save collections of associated relations through the owner side of the relation,
where the owned relation is associated to the owner through the `has_many` class method:

```ruby
owner = OwnerModel.new(owned_relations: array_of_owned_relations)
# saves all `owned_relations` one-by-one
owner.save!
```

This will issue a single `INSERT`, and transaction, for every record in `owned_relations`, which is inefficient if
`array_of_owned_relations` is large. To remedy this, the `BulkInsertableAssociations` concern can be
used to declare that the owner defines associations that are safe for bulk insertion:

```ruby
class OwnerModel < ApplicationRecord
  # other includes here
  # ...
  include BulkInsertableAssociations # include this last

  has_many :my_models
end
```

Here `my_models` must be declared `BulkInsertSafe` (as described previously) for bulk insertions
to happen. You can now insert any yet unsaved records as follows:

```ruby
BulkInsertableAssociations.with_bulk_insert do
  owner = OwnerModel.new(my_models: array_of_my_model_instances)
  # saves `my_models` using a single bulk insert (possibly via multiple batches)
  owner.save!
end
```

Note that you can still save relations that are not `BulkInsertSafe` in this block; they will
simply be treated as if you had invoked `save` from outside the block.

## Known limitations

There are a few restrictions to how these APIs can be used:

- Bulk inserts only work for new records; `UPDATE`s or "upserts" are not supported yet.
- `ON CONFLICT` behavior cannot currently be configured; an error will be raised on primary key conflicts.
- `BulkInsertableAssociations` furthermore has the following restrictions:
  - only compatible with `has_many` relations.
  - does not support `has_many through: ...` relations.
