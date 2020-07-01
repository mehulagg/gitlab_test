export default function(client, queries) {
  queries.forEach(query => client.watchQuery(query).subscribe());
}
