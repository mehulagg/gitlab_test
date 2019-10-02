require 'spec_helper'

describe Gitlab::Database::ActiveRecordUnion do
  let(:user) { create(:user) }

  let(:a) { Project.where(visibility_level: 20) }

  let(:b) { Project.where('EXISTS (?)',  user.authorizations_for_projects) }

  let(:subject) { a.union_pushdown(b) }

  it 'unions two relations' do
    expect(subject.to_sql).to eq(<<~EOSQL.squish
      SELECT "projects".* FROM ( (SELECT "projects".* FROM "projects" WHERE "projects"."visibility_level" = 20) UNION (SELECT "projects".* FROM "projects" WHERE (EXISTS (SELECT 1 FROM "project_authorizations" WHERE "project_authorizations"."user_id" = 1 AND (project_authorizations.project_id = projects.id)))) ) "projects"
                                 EOSQL
                                )
  end

  it 'pushes down where clauses to both relations' do
    union = subject.where(id: 1)

    expect(union.to_sql).to eq(<<~EOSQL.squish
SELECT "projects".* FROM ( (SELECT "projects".* FROM "projects" WHERE "projects"."visibility_level" = 20 AND "projects"."id" = 1) UNION (SELECT "projects".* FROM "projects" WHERE (EXISTS (SELECT 1 FROM "project_authorizations" WHERE "project_authorizations"."user_id" = 2 AND (project_authorizations.project_id = projects.id))) AND "projects"."id" = 1) ) "projects"
                                 EOSQL
                                )
  end

  it 'pushes down individual scopes' do
    union = subject.without_deleted

    expect(union.to_sql).to eq(<<~EOSQL.squish
                               SELECT "projects".* FROM ( (SELECT "projects".* FROM "projects" WHERE "projects"."visibility_level" = 20 AND "projects"."pending_delete" = FALSE) UNION (SELECT "projects".* FROM "projects" WHERE (EXISTS (SELECT 1 FROM "project_authorizations" WHERE "project_authorizations"."user_id" = 3 AND (project_authorizations.project_id = projects.id))) AND "projects"."pending_delete" = FALSE) ) "projects"
                               EOSQL
                              )
  end

  it 'pushes down the limit clause' do
    union = subject.limit(10)

    expect_sql(union, <<~EOSQL.squish
       SELECT
           "projects".*
       FROM ( (
               SELECT
                   "projects".*
               FROM
                   "projects"
               WHERE
                   "projects"."visibility_level" = 20
               LIMIT 10)
       UNION (
           SELECT
               "projects".*
           FROM
               "projects"
           WHERE (EXISTS (
                   SELECT
                       1
                   FROM
                       "project_authorizations"
                   WHERE
                      "project_authorizations"."user_id" = #{user.id}
                       AND (project_authorizations.project_id = projects.id)))
           LIMIT 10)) "projects"
       LIMIT 10
    EOSQL
    )
  end

  it 'does not push down the offset' do
    union = subject.offset(5)

    expect_sql(union, <<~EOSQL.squish
       SELECT
           "projects".*
       FROM ((
               SELECT
                   "projects".*
               FROM
                   "projects"
               WHERE
                   "projects"."visibility_level" = 20)
           UNION (
               SELECT
                   "projects".*
               FROM
                   "projects"
               WHERE (EXISTS (
                       SELECT
                           1
                       FROM
                           "project_authorizations"
                       WHERE
                          "project_authorizations"."user_id" = #{user.id}
                           AND (project_authorizations.project_id = projects.id))))) "projects" OFFSET 5
    EOSQL
    )
  end

  it 'pushes down the offset and recalculates the limit on the union clauses' do
    union = subject.offset(5).limit(10)

    expect_sql(union, <<~EOSQL.squish
       SELECT
           "projects".*
       FROM ((
               SELECT
                   "projects".*
               FROM
                   "projects"
               WHERE
                   "projects"."visibility_level" = 20
               LIMIT 15
               )
           UNION (
               SELECT
                   "projects".*
               FROM
                   "projects"
               WHERE (EXISTS (
                       SELECT
                           1
                       FROM
                           "project_authorizations"
                       WHERE
                          "project_authorizations"."user_id" = #{user.id}
                           AND (project_authorizations.project_id = projects.id)))
               LIMIT 15
           )) "projects" LIMIT 10 OFFSET 5
    EOSQL
    )
  end

  it 'pushes down order by clause' do
    union = subject.order('id DESC').limit(10)

    expect_sql(union, <<~EOSQL.squish
       SELECT
           "projects".*
       FROM ((
               SELECT
                   "projects".*
               FROM
                   "projects"
               WHERE
                   "projects"."visibility_level" = 20
               ORDER BY id DESC
               LIMIT 10
               )
           UNION (
               SELECT
                   "projects".*
               FROM
                   "projects"
               WHERE (EXISTS (
                       SELECT
                           1
                       FROM
                           "project_authorizations"
                       WHERE
                          "project_authorizations"."user_id" = #{user.id}
                           AND (project_authorizations.project_id = projects.id)))
               ORDER BY id DESC
               LIMIT 10
           )) "projects" ORDER BY id DESC LIMIT 10
    EOSQL
    )
  end

  it 'supports reordering' do
    union = subject.order('id DESC').reorder('name ASC').limit(10)

    expect_sql(union, <<~EOSQL.squish
       SELECT
           "projects".*
       FROM ((
               SELECT
                   "projects".*
               FROM
                   "projects"
               WHERE
                   "projects"."visibility_level" = 20
               ORDER BY name ASC
               LIMIT 10
               )
           UNION (
               SELECT
                   "projects".*
               FROM
                   "projects"
               WHERE (EXISTS (
                       SELECT
                           1
                       FROM
                           "project_authorizations"
                       WHERE
                          "project_authorizations"."user_id" = #{user.id}
                           AND (project_authorizations.project_id = projects.id)))
               ORDER BY name ASC
               LIMIT 10
           )) "projects" ORDER BY name ASC LIMIT 10
    EOSQL
    )
  end

  it 'pushes down joins' do
    union = subject.starred_by(user)

    expect_sql(union, <<~EOSQL.squish
      SELECT
          "projects".*
      FROM ((
              SELECT
                  "projects".*
              FROM
                  "projects"
                  INNER JOIN "users_star_projects" ON "users_star_projects"."project_id" = "projects"."id"
              WHERE
                  "projects"."visibility_level" = 20
                  AND "users_star_projects"."user_id" = #{user.id})
          UNION (
              SELECT
                  "projects".*
              FROM
                  "projects"
                  INNER JOIN "users_star_projects" ON "users_star_projects"."project_id" = "projects"."id"
              WHERE (EXISTS (
                      SELECT
                          1
                      FROM
                          "project_authorizations"
                      WHERE
                        "project_authorizations"."user_id" = #{user.id}
                          AND (project_authorizations.project_id = projects.id)))
                AND "users_star_projects"."user_id" = #{user.id})) "projects"
    EOSQL
    )
  end

  it 'pushes down filters on joins' do
    union = subject.joins(:users).where('users.username = ?', 'test')

    expect_sql(union, <<~EOSQL.squish
       SELECT
           "projects".*
       FROM ((
               SELECT
                   "projects".*
               FROM
                   "projects"
                   INNER JOIN "members" ON "members"."source_type" = 'Project'
                       AND "members"."source_id" = "projects"."id"
                       AND "members"."source_type" = 'Project'
                       AND "members"."type" IN ('ProjectMember')
                       AND "members"."requested_at" IS NULL
                   INNER JOIN "users" ON "users"."id" = "members"."user_id"
               WHERE
                   "projects"."visibility_level" = 20
                   AND (users.username = 'test'))
           UNION (
               SELECT
                   "projects".*
               FROM
                   "projects"
                   INNER JOIN "members" ON "members"."source_type" = 'Project'
                       AND "members"."source_id" = "projects"."id"
                       AND "members"."source_type" = 'Project'
                       AND "members"."type" IN ('ProjectMember')
                       AND "members"."requested_at" IS NULL
                   INNER JOIN "users" ON "users"."id" = "members"."user_id"
               WHERE (EXISTS (
                       SELECT
                           1
                       FROM
                           "project_authorizations"
                       WHERE
                           "project_authorizations"."user_id" = 10
                           AND (project_authorizations.project_id = projects.id)))
                   AND (users.username = 'test'))) "projects"
    EOSQL
              )
  end

  context 'disallowed methods' do
    %i(preload preload! eager_load eager_load! includes! includes or or! extending extending!).each do |method|
      it "disallows ##{method}" do
        expect { subject.send(method) }.to raise_error(/not yet supported/)
      end
    end
  end

  it 'pushes down projections' do
    union = subject.select(:name, :id)

    expect_sql(union, <<~EOSQL.squish
       SELECT
           "name", "id"
       FROM ( (
               SELECT
                 "projects"."name", "projects"."id"
               FROM
                   "projects"
               WHERE
                   "projects"."visibility_level" = 20
               )
       UNION (
           SELECT
             "projects"."name", "projects"."id"
           FROM
               "projects"
           WHERE (EXISTS (
                   SELECT
                       1
                   FROM
                       "project_authorizations"
                   WHERE
                      "project_authorizations"."user_id" = #{user.id}
                       AND (project_authorizations.project_id = projects.id)))
           )) "projects"
    EOSQL
    )
  end

  it 'pushes down projections with distinct' do
    union = subject.select(:name).distinct

    expect_sql(union, <<~EOSQL.squish
       SELECT
           DISTINCT "name"
       FROM ( (
               SELECT
                 DISTINCT "projects"."name"
               FROM
                   "projects"
               WHERE
                   "projects"."visibility_level" = 20
               )
       UNION (
           SELECT
             DISTINCT "projects"."name"
           FROM
               "projects"
           WHERE (EXISTS (
                   SELECT
                       1
                   FROM
                       "project_authorizations"
                   WHERE
                      "project_authorizations"."user_id" = #{user.id}
                       AND (project_authorizations.project_id = projects.id)))
           )) "projects"
    EOSQL
    )
  end

  it 'supports reversing the order' do
    union = subject.order('id DESC').reverse_order

    expect_sql(union, <<~EOSQL.squish
       SELECT
           "projects".*
       FROM ((
               SELECT
                   "projects".*
               FROM
                   "projects"
               WHERE
                   "projects"."visibility_level" = 20
               ORDER BY id ASC
               )
           UNION (
               SELECT
                   "projects".*
               FROM
                   "projects"
               WHERE (EXISTS (
                       SELECT
                           1
                       FROM
                           "project_authorizations"
                       WHERE
                          "project_authorizations"."user_id" = #{user.id}
                           AND (project_authorizations.project_id = projects.id)))
               ORDER BY id ASC
           )) "projects" ORDER BY id ASC
    EOSQL
    )
  end

  it 'applies grouping to the union' do
    union = Project.all.union_pushdown(Project.where(id: 1)).group(:name).select(:name)

    expect_sql(union, <<~EOSQL.squish
      SELECT "name" FROM ( (SELECT "projects"."name" FROM "projects") UNION (SELECT "projects"."name" FROM "projects" WHERE "projects"."id" = 1) ) "projects" GROUP BY "name"
    EOSQL
    )
  end

  it 'works with selecting aggregates, too'

  it 'applies group with HAVING to the union' do
    union = Project.all.union_pushdown(Project.where(id: 1)).group(:name).select(:name).having('COUNT(*) > 1')

    expect_sql(union, <<~EOSQL.squish
      SELECT "name" FROM ( (SELECT "projects"."name" FROM "projects") UNION (SELECT "projects"."name" FROM "projects" WHERE "projects"."id" = 1) ) "projects" GROUP BY "name" HAVING ( COUNT(*) > 1 )
    EOSQL
    )
  end

  context 'structural compatibility' do
    it 'prohibits using relations of different type' do
      expect { Project.all.union_pushdown(User.all) }.to raise_error(ArgumentError, /must be of type/)
    end

    it 'raises an error when given structurally incompatible relations' do
      expect { Project.select(:id).union_pushdown(Project.select(:name)) }.to raise_error(ArgumentError, /structurally compatible/)
    end

    it 'raises an error when base relations have a group by clause' do
      expect { Project.group(:name).union_pushdown(Project.group(:name)) }.to raise_error(ArgumentError, /cannot have existing/)
    end
  end

  def expect_sql(rel, sql)
    expect(trim_sql(rel.to_sql)).to eq(trim_sql(sql))
  end

  def trim_sql(sql)
    sql.squish.gsub(/ *([()]) */, ' \1 ')
  end
end
