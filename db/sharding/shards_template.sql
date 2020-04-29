CREATE SCHEMA IF NOT EXISTS parts;
SET SEARCH_PATH=parts,public;

CREATE TABLE <%= part %> (
    id integer NOT NULL,
    title character varying,
    author_id integer,
    project_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    description text,
    milestone_id integer,
    iid integer,
    updated_by_id integer,
    weight integer,
    confidential boolean DEFAULT false NOT NULL,
    due_date date,
    moved_to_id integer,
    lock_version integer DEFAULT 0,
    title_html text,
    description_html text,
    time_estimate integer,
    relative_position integer,
    service_desk_reply_to character varying,
    cached_markdown_version integer,
    last_edited_at timestamp without time zone,
    last_edited_by_id integer,
    discussion_locked boolean,
    closed_at timestamp with time zone,
    closed_by_id integer,
    state_id smallint DEFAULT 1 NOT NULL,
    duplicated_to_id integer,
    promoted_to_epic_id integer,
    health_status smallint,
    external_key character varying(255),
    sprint_id bigint
);

CREATE EXTENSION IF NOT EXISTS pg_trgm WITH SCHEMA public;

--
-- Name: issues issues_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

-- LIMITATION
-- ALTER TABLE <%= part %> ADD CONSTRAINT issues_pkey PRIMARY KEY (project_id, id);

CREATE INDEX idx_<%= part %>_on_health_status_not_null ON <%= part %> USING btree (health_status) WHERE (health_status IS NOT NULL);
CREATE INDEX idx_<%= part %>_on_project_id_and_created_at_and_id_and_state_id ON <%= part %> USING btree (project_id, created_at, id, state_id);
CREATE INDEX idx_<%= part %>_on_project_id_and_due_date_and_id_and_state_id ON <%= part %> USING btree (project_id, due_date, id, state_id) WHERE (due_date IS NOT NULL);
CREATE INDEX idx_<%= part %>_on_project_id_and_rel_position_and_state_id_and_id ON <%= part %> USING btree (project_id, relative_position, state_id, id DESC);
CREATE INDEX idx_<%= part %>_on_project_id_and_updated_at_and_id_and_state_id ON <%= part %> USING btree (project_id, updated_at, id, state_id);
CREATE INDEX idx_<%= part %>_on_state_id ON <%= part %> USING btree (state_id);
CREATE INDEX <%= part %>_on_author_id ON <%= part %> USING btree (author_id);
CREATE INDEX <%= part %>_on_author_id_and_id_and_created_at ON <%= part %> USING btree (author_id, id, created_at);
CREATE INDEX <%= part %>_on_closed_by_id ON <%= part %> USING btree (closed_by_id);
CREATE INDEX <%= part %>_on_confidential ON <%= part %> USING btree (confidential);
CREATE INDEX <%= part %>_on_description_trigram ON <%= part %> USING gin (description public.gin_trgm_ops);
CREATE INDEX <%= part %>_on_duplicated_to_id ON <%= part %> USING btree (duplicated_to_id) WHERE (duplicated_to_id IS NOT NULL);
CREATE INDEX <%= part %>_on_lock_version ON <%= part %> USING btree (lock_version) WHERE (lock_version IS NULL);
CREATE INDEX <%= part %>_on_milestone_id ON <%= part %> USING btree (milestone_id);
CREATE INDEX <%= part %>_on_moved_to_id ON <%= part %> USING btree (moved_to_id) WHERE (moved_to_id IS NOT NULL);
CREATE UNIQUE INDEX <%= part %>_on_project_id_and_external_key ON <%= part %> USING btree (project_id, external_key) WHERE (external_key IS NOT NULL);
CREATE UNIQUE INDEX <%= part %>_on_project_id_and_iid ON <%= part %> USING btree (project_id, iid);
CREATE INDEX <%= part %>_on_promoted_to_epic_id ON <%= part %> USING btree (promoted_to_epic_id) WHERE (promoted_to_epic_id IS NOT NULL);
CREATE INDEX <%= part %>_on_relative_position ON <%= part %> USING btree (relative_position);
CREATE INDEX <%= part %>_on_sprint_id ON <%= part %> USING btree (sprint_id);
CREATE INDEX <%= part %>_on_title_trigram ON <%= part %> USING gin (title public.gin_trgm_ops);
CREATE INDEX <%= part %>_on_updated_at ON <%= part %> USING btree (updated_at);
CREATE INDEX <%= part %>_on_updated_by_id ON <%= part %> USING btree (updated_by_id) WHERE (updated_by_id IS NOT NULL);


-- LIMITATION
-- ALTER TABLE <%= part %> ADD CONSTRAINT fk_<%= part %>_05f1e72feb FOREIGN KEY (author_id) REFERENCES public.users(id) ON DELETE SET NULL;

-- LIMITATION
 -- ALTER TABLE <%= part %> ADD CONSTRAINT fk_<%= part %>_3b8c72ea56 FOREIGN KEY (sprint_id) REFERENCES public.sprints(id) ON DELETE CASCADE;


-- LIMITATION
-- ALTER TABLE <%= part %> ADD CONSTRAINT fk_<%= part %>_899c8f3231 FOREIGN KEY (project_id) REFERENCES public.projects(id) ON DELETE CASCADE;


-- LIMITATION
 -- ALTER TABLE <%= part %> ADD CONSTRAINT fk_<%= part %>_96b1dd429c FOREIGN KEY (milestone_id) REFERENCES public.milestones(id) ON DELETE SET NULL;

-- LIMITATION
-- ALTER TABLE <%= part %> ADD CONSTRAINT fk_<%= part %>_c63cbf6c25 FOREIGN KEY (closed_by_id) REFERENCES public.users(id) ON DELETE SET NULL;

-- LIMITATION
-- ALTER TABLE <%= part %> ADD CONSTRAINT fk_<%= part %>_df75a7c8b8 FOREIGN KEY (promoted_to_epic_id) REFERENCES public.epics(id) ON DELETE SET NULL;

-- LIMITATION
-- ALTER TABLE <%= part %> ADD CONSTRAINT fk_<%= part %>_ffed080f01 FOREIGN KEY (updated_by_id) REFERENCES public.users(id) ON DELETE SET NULL;
