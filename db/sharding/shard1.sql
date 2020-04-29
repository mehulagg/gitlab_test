CREATE SCHEMA IF NOT EXISTS parts;
SET SEARCH_PATH=parts,public;

CREATE TABLE issues_0 (
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
-- ALTER TABLE issues_0 ADD CONSTRAINT issues_pkey PRIMARY KEY (project_id, id);

CREATE INDEX idx_issues_0_on_health_status_not_null ON issues_0 USING btree (health_status) WHERE (health_status IS NOT NULL);
CREATE INDEX idx_issues_0_on_project_id_and_created_at_and_id_and_state_id ON issues_0 USING btree (project_id, created_at, id, state_id);
CREATE INDEX idx_issues_0_on_project_id_and_due_date_and_id_and_state_id ON issues_0 USING btree (project_id, due_date, id, state_id) WHERE (due_date IS NOT NULL);
CREATE INDEX idx_issues_0_on_project_id_and_rel_position_and_state_id_and_id ON issues_0 USING btree (project_id, relative_position, state_id, id DESC);
CREATE INDEX idx_issues_0_on_project_id_and_updated_at_and_id_and_state_id ON issues_0 USING btree (project_id, updated_at, id, state_id);
CREATE INDEX idx_issues_0_on_state_id ON issues_0 USING btree (state_id);
CREATE INDEX issues_0_on_author_id ON issues_0 USING btree (author_id);
CREATE INDEX issues_0_on_author_id_and_id_and_created_at ON issues_0 USING btree (author_id, id, created_at);
CREATE INDEX issues_0_on_closed_by_id ON issues_0 USING btree (closed_by_id);
CREATE INDEX issues_0_on_confidential ON issues_0 USING btree (confidential);
CREATE INDEX issues_0_on_description_trigram ON issues_0 USING gin (description public.gin_trgm_ops);
CREATE INDEX issues_0_on_duplicated_to_id ON issues_0 USING btree (duplicated_to_id) WHERE (duplicated_to_id IS NOT NULL);
CREATE INDEX issues_0_on_lock_version ON issues_0 USING btree (lock_version) WHERE (lock_version IS NULL);
CREATE INDEX issues_0_on_milestone_id ON issues_0 USING btree (milestone_id);
CREATE INDEX issues_0_on_moved_to_id ON issues_0 USING btree (moved_to_id) WHERE (moved_to_id IS NOT NULL);
CREATE UNIQUE INDEX issues_0_on_project_id_and_external_key ON issues_0 USING btree (project_id, external_key) WHERE (external_key IS NOT NULL);
CREATE UNIQUE INDEX issues_0_on_project_id_and_iid ON issues_0 USING btree (project_id, iid);
CREATE INDEX issues_0_on_promoted_to_epic_id ON issues_0 USING btree (promoted_to_epic_id) WHERE (promoted_to_epic_id IS NOT NULL);
CREATE INDEX issues_0_on_relative_position ON issues_0 USING btree (relative_position);
CREATE INDEX issues_0_on_sprint_id ON issues_0 USING btree (sprint_id);
CREATE INDEX issues_0_on_title_trigram ON issues_0 USING gin (title public.gin_trgm_ops);
CREATE INDEX issues_0_on_updated_at ON issues_0 USING btree (updated_at);
CREATE INDEX issues_0_on_updated_by_id ON issues_0 USING btree (updated_by_id) WHERE (updated_by_id IS NOT NULL);


-- LIMITATION
-- ALTER TABLE issues_0 ADD CONSTRAINT fk_issues_0_05f1e72feb FOREIGN KEY (author_id) REFERENCES public.users(id) ON DELETE SET NULL;

-- LIMITATION
 -- ALTER TABLE issues_0 ADD CONSTRAINT fk_issues_0_3b8c72ea56 FOREIGN KEY (sprint_id) REFERENCES public.sprints(id) ON DELETE CASCADE;


-- LIMITATION
-- ALTER TABLE issues_0 ADD CONSTRAINT fk_issues_0_899c8f3231 FOREIGN KEY (project_id) REFERENCES public.projects(id) ON DELETE CASCADE;


-- LIMITATION
 -- ALTER TABLE issues_0 ADD CONSTRAINT fk_issues_0_96b1dd429c FOREIGN KEY (milestone_id) REFERENCES public.milestones(id) ON DELETE SET NULL;

-- LIMITATION
-- ALTER TABLE issues_0 ADD CONSTRAINT fk_issues_0_c63cbf6c25 FOREIGN KEY (closed_by_id) REFERENCES public.users(id) ON DELETE SET NULL;

-- LIMITATION
-- ALTER TABLE issues_0 ADD CONSTRAINT fk_issues_0_df75a7c8b8 FOREIGN KEY (promoted_to_epic_id) REFERENCES public.epics(id) ON DELETE SET NULL;

-- LIMITATION
-- ALTER TABLE issues_0 ADD CONSTRAINT fk_issues_0_ffed080f01 FOREIGN KEY (updated_by_id) REFERENCES public.users(id) ON DELETE SET NULL;
CREATE SCHEMA IF NOT EXISTS parts;
SET SEARCH_PATH=parts,public;

CREATE TABLE issues_2 (
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
-- ALTER TABLE issues_2 ADD CONSTRAINT issues_pkey PRIMARY KEY (project_id, id);

CREATE INDEX idx_issues_2_on_health_status_not_null ON issues_2 USING btree (health_status) WHERE (health_status IS NOT NULL);
CREATE INDEX idx_issues_2_on_project_id_and_created_at_and_id_and_state_id ON issues_2 USING btree (project_id, created_at, id, state_id);
CREATE INDEX idx_issues_2_on_project_id_and_due_date_and_id_and_state_id ON issues_2 USING btree (project_id, due_date, id, state_id) WHERE (due_date IS NOT NULL);
CREATE INDEX idx_issues_2_on_project_id_and_rel_position_and_state_id_and_id ON issues_2 USING btree (project_id, relative_position, state_id, id DESC);
CREATE INDEX idx_issues_2_on_project_id_and_updated_at_and_id_and_state_id ON issues_2 USING btree (project_id, updated_at, id, state_id);
CREATE INDEX idx_issues_2_on_state_id ON issues_2 USING btree (state_id);
CREATE INDEX issues_2_on_author_id ON issues_2 USING btree (author_id);
CREATE INDEX issues_2_on_author_id_and_id_and_created_at ON issues_2 USING btree (author_id, id, created_at);
CREATE INDEX issues_2_on_closed_by_id ON issues_2 USING btree (closed_by_id);
CREATE INDEX issues_2_on_confidential ON issues_2 USING btree (confidential);
CREATE INDEX issues_2_on_description_trigram ON issues_2 USING gin (description public.gin_trgm_ops);
CREATE INDEX issues_2_on_duplicated_to_id ON issues_2 USING btree (duplicated_to_id) WHERE (duplicated_to_id IS NOT NULL);
CREATE INDEX issues_2_on_lock_version ON issues_2 USING btree (lock_version) WHERE (lock_version IS NULL);
CREATE INDEX issues_2_on_milestone_id ON issues_2 USING btree (milestone_id);
CREATE INDEX issues_2_on_moved_to_id ON issues_2 USING btree (moved_to_id) WHERE (moved_to_id IS NOT NULL);
CREATE UNIQUE INDEX issues_2_on_project_id_and_external_key ON issues_2 USING btree (project_id, external_key) WHERE (external_key IS NOT NULL);
CREATE UNIQUE INDEX issues_2_on_project_id_and_iid ON issues_2 USING btree (project_id, iid);
CREATE INDEX issues_2_on_promoted_to_epic_id ON issues_2 USING btree (promoted_to_epic_id) WHERE (promoted_to_epic_id IS NOT NULL);
CREATE INDEX issues_2_on_relative_position ON issues_2 USING btree (relative_position);
CREATE INDEX issues_2_on_sprint_id ON issues_2 USING btree (sprint_id);
CREATE INDEX issues_2_on_title_trigram ON issues_2 USING gin (title public.gin_trgm_ops);
CREATE INDEX issues_2_on_updated_at ON issues_2 USING btree (updated_at);
CREATE INDEX issues_2_on_updated_by_id ON issues_2 USING btree (updated_by_id) WHERE (updated_by_id IS NOT NULL);


-- LIMITATION
-- ALTER TABLE issues_2 ADD CONSTRAINT fk_issues_2_05f1e72feb FOREIGN KEY (author_id) REFERENCES public.users(id) ON DELETE SET NULL;

-- LIMITATION
 -- ALTER TABLE issues_2 ADD CONSTRAINT fk_issues_2_3b8c72ea56 FOREIGN KEY (sprint_id) REFERENCES public.sprints(id) ON DELETE CASCADE;


-- LIMITATION
-- ALTER TABLE issues_2 ADD CONSTRAINT fk_issues_2_899c8f3231 FOREIGN KEY (project_id) REFERENCES public.projects(id) ON DELETE CASCADE;


-- LIMITATION
 -- ALTER TABLE issues_2 ADD CONSTRAINT fk_issues_2_96b1dd429c FOREIGN KEY (milestone_id) REFERENCES public.milestones(id) ON DELETE SET NULL;

-- LIMITATION
-- ALTER TABLE issues_2 ADD CONSTRAINT fk_issues_2_c63cbf6c25 FOREIGN KEY (closed_by_id) REFERENCES public.users(id) ON DELETE SET NULL;

-- LIMITATION
-- ALTER TABLE issues_2 ADD CONSTRAINT fk_issues_2_df75a7c8b8 FOREIGN KEY (promoted_to_epic_id) REFERENCES public.epics(id) ON DELETE SET NULL;

-- LIMITATION
-- ALTER TABLE issues_2 ADD CONSTRAINT fk_issues_2_ffed080f01 FOREIGN KEY (updated_by_id) REFERENCES public.users(id) ON DELETE SET NULL;
CREATE SCHEMA IF NOT EXISTS parts;
SET SEARCH_PATH=parts,public;

CREATE TABLE issues_4 (
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
-- ALTER TABLE issues_4 ADD CONSTRAINT issues_pkey PRIMARY KEY (project_id, id);

CREATE INDEX idx_issues_4_on_health_status_not_null ON issues_4 USING btree (health_status) WHERE (health_status IS NOT NULL);
CREATE INDEX idx_issues_4_on_project_id_and_created_at_and_id_and_state_id ON issues_4 USING btree (project_id, created_at, id, state_id);
CREATE INDEX idx_issues_4_on_project_id_and_due_date_and_id_and_state_id ON issues_4 USING btree (project_id, due_date, id, state_id) WHERE (due_date IS NOT NULL);
CREATE INDEX idx_issues_4_on_project_id_and_rel_position_and_state_id_and_id ON issues_4 USING btree (project_id, relative_position, state_id, id DESC);
CREATE INDEX idx_issues_4_on_project_id_and_updated_at_and_id_and_state_id ON issues_4 USING btree (project_id, updated_at, id, state_id);
CREATE INDEX idx_issues_4_on_state_id ON issues_4 USING btree (state_id);
CREATE INDEX issues_4_on_author_id ON issues_4 USING btree (author_id);
CREATE INDEX issues_4_on_author_id_and_id_and_created_at ON issues_4 USING btree (author_id, id, created_at);
CREATE INDEX issues_4_on_closed_by_id ON issues_4 USING btree (closed_by_id);
CREATE INDEX issues_4_on_confidential ON issues_4 USING btree (confidential);
CREATE INDEX issues_4_on_description_trigram ON issues_4 USING gin (description public.gin_trgm_ops);
CREATE INDEX issues_4_on_duplicated_to_id ON issues_4 USING btree (duplicated_to_id) WHERE (duplicated_to_id IS NOT NULL);
CREATE INDEX issues_4_on_lock_version ON issues_4 USING btree (lock_version) WHERE (lock_version IS NULL);
CREATE INDEX issues_4_on_milestone_id ON issues_4 USING btree (milestone_id);
CREATE INDEX issues_4_on_moved_to_id ON issues_4 USING btree (moved_to_id) WHERE (moved_to_id IS NOT NULL);
CREATE UNIQUE INDEX issues_4_on_project_id_and_external_key ON issues_4 USING btree (project_id, external_key) WHERE (external_key IS NOT NULL);
CREATE UNIQUE INDEX issues_4_on_project_id_and_iid ON issues_4 USING btree (project_id, iid);
CREATE INDEX issues_4_on_promoted_to_epic_id ON issues_4 USING btree (promoted_to_epic_id) WHERE (promoted_to_epic_id IS NOT NULL);
CREATE INDEX issues_4_on_relative_position ON issues_4 USING btree (relative_position);
CREATE INDEX issues_4_on_sprint_id ON issues_4 USING btree (sprint_id);
CREATE INDEX issues_4_on_title_trigram ON issues_4 USING gin (title public.gin_trgm_ops);
CREATE INDEX issues_4_on_updated_at ON issues_4 USING btree (updated_at);
CREATE INDEX issues_4_on_updated_by_id ON issues_4 USING btree (updated_by_id) WHERE (updated_by_id IS NOT NULL);


-- LIMITATION
-- ALTER TABLE issues_4 ADD CONSTRAINT fk_issues_4_05f1e72feb FOREIGN KEY (author_id) REFERENCES public.users(id) ON DELETE SET NULL;

-- LIMITATION
 -- ALTER TABLE issues_4 ADD CONSTRAINT fk_issues_4_3b8c72ea56 FOREIGN KEY (sprint_id) REFERENCES public.sprints(id) ON DELETE CASCADE;


-- LIMITATION
-- ALTER TABLE issues_4 ADD CONSTRAINT fk_issues_4_899c8f3231 FOREIGN KEY (project_id) REFERENCES public.projects(id) ON DELETE CASCADE;


-- LIMITATION
 -- ALTER TABLE issues_4 ADD CONSTRAINT fk_issues_4_96b1dd429c FOREIGN KEY (milestone_id) REFERENCES public.milestones(id) ON DELETE SET NULL;

-- LIMITATION
-- ALTER TABLE issues_4 ADD CONSTRAINT fk_issues_4_c63cbf6c25 FOREIGN KEY (closed_by_id) REFERENCES public.users(id) ON DELETE SET NULL;

-- LIMITATION
-- ALTER TABLE issues_4 ADD CONSTRAINT fk_issues_4_df75a7c8b8 FOREIGN KEY (promoted_to_epic_id) REFERENCES public.epics(id) ON DELETE SET NULL;

-- LIMITATION
-- ALTER TABLE issues_4 ADD CONSTRAINT fk_issues_4_ffed080f01 FOREIGN KEY (updated_by_id) REFERENCES public.users(id) ON DELETE SET NULL;
CREATE SCHEMA IF NOT EXISTS parts;
SET SEARCH_PATH=parts,public;

CREATE TABLE issues_6 (
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
-- ALTER TABLE issues_6 ADD CONSTRAINT issues_pkey PRIMARY KEY (project_id, id);

CREATE INDEX idx_issues_6_on_health_status_not_null ON issues_6 USING btree (health_status) WHERE (health_status IS NOT NULL);
CREATE INDEX idx_issues_6_on_project_id_and_created_at_and_id_and_state_id ON issues_6 USING btree (project_id, created_at, id, state_id);
CREATE INDEX idx_issues_6_on_project_id_and_due_date_and_id_and_state_id ON issues_6 USING btree (project_id, due_date, id, state_id) WHERE (due_date IS NOT NULL);
CREATE INDEX idx_issues_6_on_project_id_and_rel_position_and_state_id_and_id ON issues_6 USING btree (project_id, relative_position, state_id, id DESC);
CREATE INDEX idx_issues_6_on_project_id_and_updated_at_and_id_and_state_id ON issues_6 USING btree (project_id, updated_at, id, state_id);
CREATE INDEX idx_issues_6_on_state_id ON issues_6 USING btree (state_id);
CREATE INDEX issues_6_on_author_id ON issues_6 USING btree (author_id);
CREATE INDEX issues_6_on_author_id_and_id_and_created_at ON issues_6 USING btree (author_id, id, created_at);
CREATE INDEX issues_6_on_closed_by_id ON issues_6 USING btree (closed_by_id);
CREATE INDEX issues_6_on_confidential ON issues_6 USING btree (confidential);
CREATE INDEX issues_6_on_description_trigram ON issues_6 USING gin (description public.gin_trgm_ops);
CREATE INDEX issues_6_on_duplicated_to_id ON issues_6 USING btree (duplicated_to_id) WHERE (duplicated_to_id IS NOT NULL);
CREATE INDEX issues_6_on_lock_version ON issues_6 USING btree (lock_version) WHERE (lock_version IS NULL);
CREATE INDEX issues_6_on_milestone_id ON issues_6 USING btree (milestone_id);
CREATE INDEX issues_6_on_moved_to_id ON issues_6 USING btree (moved_to_id) WHERE (moved_to_id IS NOT NULL);
CREATE UNIQUE INDEX issues_6_on_project_id_and_external_key ON issues_6 USING btree (project_id, external_key) WHERE (external_key IS NOT NULL);
CREATE UNIQUE INDEX issues_6_on_project_id_and_iid ON issues_6 USING btree (project_id, iid);
CREATE INDEX issues_6_on_promoted_to_epic_id ON issues_6 USING btree (promoted_to_epic_id) WHERE (promoted_to_epic_id IS NOT NULL);
CREATE INDEX issues_6_on_relative_position ON issues_6 USING btree (relative_position);
CREATE INDEX issues_6_on_sprint_id ON issues_6 USING btree (sprint_id);
CREATE INDEX issues_6_on_title_trigram ON issues_6 USING gin (title public.gin_trgm_ops);
CREATE INDEX issues_6_on_updated_at ON issues_6 USING btree (updated_at);
CREATE INDEX issues_6_on_updated_by_id ON issues_6 USING btree (updated_by_id) WHERE (updated_by_id IS NOT NULL);


-- LIMITATION
-- ALTER TABLE issues_6 ADD CONSTRAINT fk_issues_6_05f1e72feb FOREIGN KEY (author_id) REFERENCES public.users(id) ON DELETE SET NULL;

-- LIMITATION
 -- ALTER TABLE issues_6 ADD CONSTRAINT fk_issues_6_3b8c72ea56 FOREIGN KEY (sprint_id) REFERENCES public.sprints(id) ON DELETE CASCADE;


-- LIMITATION
-- ALTER TABLE issues_6 ADD CONSTRAINT fk_issues_6_899c8f3231 FOREIGN KEY (project_id) REFERENCES public.projects(id) ON DELETE CASCADE;


-- LIMITATION
 -- ALTER TABLE issues_6 ADD CONSTRAINT fk_issues_6_96b1dd429c FOREIGN KEY (milestone_id) REFERENCES public.milestones(id) ON DELETE SET NULL;

-- LIMITATION
-- ALTER TABLE issues_6 ADD CONSTRAINT fk_issues_6_c63cbf6c25 FOREIGN KEY (closed_by_id) REFERENCES public.users(id) ON DELETE SET NULL;

-- LIMITATION
-- ALTER TABLE issues_6 ADD CONSTRAINT fk_issues_6_df75a7c8b8 FOREIGN KEY (promoted_to_epic_id) REFERENCES public.epics(id) ON DELETE SET NULL;

-- LIMITATION
-- ALTER TABLE issues_6 ADD CONSTRAINT fk_issues_6_ffed080f01 FOREIGN KEY (updated_by_id) REFERENCES public.users(id) ON DELETE SET NULL;
