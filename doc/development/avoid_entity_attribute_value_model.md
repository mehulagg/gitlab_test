# Avoid Entity Attribute Value Model (EAV)

This pattern is a well-known anti-pattern called [entity-attribute-value or EAV](https://en.wikipedia.org/wiki/Entity%E2%80%93attribute%E2%80%93value_model).
While this used to be the sometimes "necessary evil" many years ago, there are better options today
- in PostgreSQL that's `jsonb` and `hstore`. Both lend itself to store unstructured data. However,
we only consider this a viable solution if we must store unstructured data and don't know upfront
what information to expect.

If we know what attributes we are going to see, a solid table with normal columns is the best
thing to start with (`NULL` values cost next to nothing in terms of space).

## Best practices

- [PostgreSQL anti pattern](https://www.2ndquadrant.com/en/blog/postgresql-anti-patterns-unnecessary-jsonhstore-dynamic-columns/)
- [Database modelization](https://tapoueh.org/blog/2018/03/database-modelization-anti-patterns/)
- [Replacing EAV with JSONB](https://coussej.github.io/2016/01/14/Replacing-EAV-with-JSONB-in-PostgreSQL/)
