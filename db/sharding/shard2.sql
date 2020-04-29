CREATE SCHEMA IF NOT EXISTS parts;
SET SEARCH_PATH=parts,public;

CREATE TABLE issues_1 (
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
-- ALTER TABLE issues_1 ADD CONSTRAINT issues_pkey PRIMARY KEY (project_id, id);

CREATE INDEX idx_issues_1_on_health_status_not_null ON issues_1 USING btree (health_status) WHERE (health_status IS NOT NULL);
CREATE INDEX idx_issues_1_on_project_id_and_created_at_and_id_and_state_id ON issues_1 USING btree (project_id, created_at, id, state_id);
CREATE INDEX idx_issues_1_on_project_id_and_due_date_and_id_and_state_id ON issues_1 USING btree (project_id, due_date, id, state_id) WHERE (due_date IS NOT NULL);
CREATE INDEX idx_issues_1_on_project_id_and_rel_position_and_state_id_and_id ON issues_1 USING btree (project_id, relative_position, state_id, id DESC);
CREATE INDEX idx_issues_1_on_project_id_and_updated_at_and_id_and_state_id ON issues_1 USING btree (project_id, updated_at, id, state_id);
CREATE INDEX idx_issues_1_on_state_id ON issues_1 USING btree (state_id);
CREATE INDEX issues_1_on_author_id ON issues_1 USING btree (author_id);
CREATE INDEX issues_1_on_author_id_and_id_and_created_at ON issues_1 USING btree (author_id, id, created_at);
CREATE INDEX issues_1_on_closed_by_id ON issues_1 USING btree (closed_by_id);
CREATE INDEX issues_1_on_confidential ON issues_1 USING btree (confidential);
CREATE INDEX issues_1_on_description_trigram ON issues_1 USING gin (description public.gin_trgm_ops);
CREATE INDEX issues_1_on_duplicated_to_id ON issues_1 USING btree (duplicated_to_id) WHERE (duplicated_to_id IS NOT NULL);
CREATE INDEX issues_1_on_lock_version ON issues_1 USING btree (lock_version) WHERE (lock_version IS NULL);
CREATE INDEX issues_1_on_milestone_id ON issues_1 USING btree (milestone_id);
CREATE INDEX issues_1_on_moved_to_id ON issues_1 USING btree (moved_to_id) WHERE (moved_to_id IS NOT NULL);
CREATE UNIQUE INDEX issues_1_on_project_id_and_external_key ON issues_1 USING btree (project_id, external_key) WHERE (external_key IS NOT NULL);
CREATE UNIQUE INDEX issues_1_on_project_id_and_iid ON issues_1 USING btree (project_id, iid);
CREATE INDEX issues_1_on_promoted_to_epic_id ON issues_1 USING btree (promoted_to_epic_id) WHERE (promoted_to_epic_id IS NOT NULL);
CREATE INDEX issues_1_on_relative_position ON issues_1 USING btree (relative_position);
CREATE INDEX issues_1_on_sprint_id ON issues_1 USING btree (sprint_id);
CREATE INDEX issues_1_on_title_trigram ON issues_1 USING gin (title public.gin_trgm_ops);
CREATE INDEX issues_1_on_updated_at ON issues_1 USING btree (updated_at);
CREATE INDEX issues_1_on_updated_by_id ON issues_1 USING btree (updated_by_id) WHERE (updated_by_id IS NOT NULL);


-- LIMITATION
-- ALTER TABLE issues_1 ADD CONSTRAINT fk_issues_1_05f1e72feb FOREIGN KEY (author_id) REFERENCES public.users(id) ON DELETE SET NULL;

-- LIMITATION
 -- ALTER TABLE issues_1 ADD CONSTRAINT fk_issues_1_3b8c72ea56 FOREIGN KEY (sprint_id) REFERENCES public.sprints(id) ON DELETE CASCADE;


-- LIMITATION
-- ALTER TABLE issues_1 ADD CONSTRAINT fk_issues_1_899c8f3231 FOREIGN KEY (project_id) REFERENCES public.projects(id) ON DELETE CASCADE;


-- LIMITATION
 -- ALTER TABLE issues_1 ADD CONSTRAINT fk_issues_1_96b1dd429c FOREIGN KEY (milestone_id) REFERENCES public.milestones(id) ON DELETE SET NULL;

-- LIMITATION
-- ALTER TABLE issues_1 ADD CONSTRAINT fk_issues_1_c63cbf6c25 FOREIGN KEY (closed_by_id) REFERENCES public.users(id) ON DELETE SET NULL;

-- LIMITATION
-- ALTER TABLE issues_1 ADD CONSTRAINT fk_issues_1_df75a7c8b8 FOREIGN KEY (promoted_to_epic_id) REFERENCES public.epics(id) ON DELETE SET NULL;

-- LIMITATION
-- ALTER TABLE issues_1 ADD CONSTRAINT fk_issues_1_ffed080f01 FOREIGN KEY (updated_by_id) REFERENCES public.users(id) ON DELETE SET NULL;
CREATE SCHEMA IF NOT EXISTS parts;
SET SEARCH_PATH=parts,public;

CREATE TABLE issues_3 (
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
-- ALTER TABLE issues_3 ADD CONSTRAINT issues_pkey PRIMARY KEY (project_id, id);

CREATE INDEX idx_issues_3_on_health_status_not_null ON issues_3 USING btree (health_status) WHERE (health_status IS NOT NULL);
CREATE INDEX idx_issues_3_on_project_id_and_created_at_and_id_and_state_id ON issues_3 USING btree (project_id, created_at, id, state_id);
CREATE INDEX idx_issues_3_on_project_id_and_due_date_and_id_and_state_id ON issues_3 USING btree (project_id, due_date, id, state_id) WHERE (due_date IS NOT NULL);
CREATE INDEX idx_issues_3_on_project_id_and_rel_position_and_state_id_and_id ON issues_3 USING btree (project_id, relative_position, state_id, id DESC);
CREATE INDEX idx_issues_3_on_project_id_and_updated_at_and_id_and_state_id ON issues_3 USING btree (project_id, updated_at, id, state_id);
CREATE INDEX idx_issues_3_on_state_id ON issues_3 USING btree (state_id);
CREATE INDEX issues_3_on_author_id ON issues_3 USING btree (author_id);
CREATE INDEX issues_3_on_author_id_and_id_and_created_at ON issues_3 USING btree (author_id, id, created_at);
CREATE INDEX issues_3_on_closed_by_id ON issues_3 USING btree (closed_by_id);
CREATE INDEX issues_3_on_confidential ON issues_3 USING btree (confidential);
CREATE INDEX issues_3_on_description_trigram ON issues_3 USING gin (description public.gin_trgm_ops);
CREATE INDEX issues_3_on_duplicated_to_id ON issues_3 USING btree (duplicated_to_id) WHERE (duplicated_to_id IS NOT NULL);
CREATE INDEX issues_3_on_lock_version ON issues_3 USING btree (lock_version) WHERE (lock_version IS NULL);
CREATE INDEX issues_3_on_milestone_id ON issues_3 USING btree (milestone_id);
CREATE INDEX issues_3_on_moved_to_id ON issues_3 USING btree (moved_to_id) WHERE (moved_to_id IS NOT NULL);
CREATE UNIQUE INDEX issues_3_on_project_id_and_external_key ON issues_3 USING btree (project_id, external_key) WHERE (external_key IS NOT NULL);
CREATE UNIQUE INDEX issues_3_on_project_id_and_iid ON issues_3 USING btree (project_id, iid);
CREATE INDEX issues_3_on_promoted_to_epic_id ON issues_3 USING btree (promoted_to_epic_id) WHERE (promoted_to_epic_id IS NOT NULL);
CREATE INDEX issues_3_on_relative_position ON issues_3 USING btree (relative_position);
CREATE INDEX issues_3_on_sprint_id ON issues_3 USING btree (sprint_id);
CREATE INDEX issues_3_on_title_trigram ON issues_3 USING gin (title public.gin_trgm_ops);
CREATE INDEX issues_3_on_updated_at ON issues_3 USING btree (updated_at);
CREATE INDEX issues_3_on_updated_by_id ON issues_3 USING btree (updated_by_id) WHERE (updated_by_id IS NOT NULL);


-- LIMITATION
-- ALTER TABLE issues_3 ADD CONSTRAINT fk_issues_3_05f1e72feb FOREIGN KEY (author_id) REFERENCES public.users(id) ON DELETE SET NULL;

-- LIMITATION
 -- ALTER TABLE issues_3 ADD CONSTRAINT fk_issues_3_3b8c72ea56 FOREIGN KEY (sprint_id) REFERENCES public.sprints(id) ON DELETE CASCADE;


-- LIMITATION
-- ALTER TABLE issues_3 ADD CONSTRAINT fk_issues_3_899c8f3231 FOREIGN KEY (project_id) REFERENCES public.projects(id) ON DELETE CASCADE;


-- LIMITATION
 -- ALTER TABLE issues_3 ADD CONSTRAINT fk_issues_3_96b1dd429c FOREIGN KEY (milestone_id) REFERENCES public.milestones(id) ON DELETE SET NULL;

-- LIMITATION
-- ALTER TABLE issues_3 ADD CONSTRAINT fk_issues_3_c63cbf6c25 FOREIGN KEY (closed_by_id) REFERENCES public.users(id) ON DELETE SET NULL;

-- LIMITATION
-- ALTER TABLE issues_3 ADD CONSTRAINT fk_issues_3_df75a7c8b8 FOREIGN KEY (promoted_to_epic_id) REFERENCES public.epics(id) ON DELETE SET NULL;

-- LIMITATION
-- ALTER TABLE issues_3 ADD CONSTRAINT fk_issues_3_ffed080f01 FOREIGN KEY (updated_by_id) REFERENCES public.users(id) ON DELETE SET NULL;
CREATE SCHEMA IF NOT EXISTS parts;
SET SEARCH_PATH=parts,public;

CREATE TABLE issues_5 (
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
-- ALTER TABLE issues_5 ADD CONSTRAINT issues_pkey PRIMARY KEY (project_id, id);

CREATE INDEX idx_issues_5_on_health_status_not_null ON issues_5 USING btree (health_status) WHERE (health_status IS NOT NULL);
CREATE INDEX idx_issues_5_on_project_id_and_created_at_and_id_and_state_id ON issues_5 USING btree (project_id, created_at, id, state_id);
CREATE INDEX idx_issues_5_on_project_id_and_due_date_and_id_and_state_id ON issues_5 USING btree (project_id, due_date, id, state_id) WHERE (due_date IS NOT NULL);
CREATE INDEX idx_issues_5_on_project_id_and_rel_position_and_state_id_and_id ON issues_5 USING btree (project_id, relative_position, state_id, id DESC);
CREATE INDEX idx_issues_5_on_project_id_and_updated_at_and_id_and_state_id ON issues_5 USING btree (project_id, updated_at, id, state_id);
CREATE INDEX idx_issues_5_on_state_id ON issues_5 USING btree (state_id);
CREATE INDEX issues_5_on_author_id ON issues_5 USING btree (author_id);
CREATE INDEX issues_5_on_author_id_and_id_and_created_at ON issues_5 USING btree (author_id, id, created_at);
CREATE INDEX issues_5_on_closed_by_id ON issues_5 USING btree (closed_by_id);
CREATE INDEX issues_5_on_confidential ON issues_5 USING btree (confidential);
CREATE INDEX issues_5_on_description_trigram ON issues_5 USING gin (description public.gin_trgm_ops);
CREATE INDEX issues_5_on_duplicated_to_id ON issues_5 USING btree (duplicated_to_id) WHERE (duplicated_to_id IS NOT NULL);
CREATE INDEX issues_5_on_lock_version ON issues_5 USING btree (lock_version) WHERE (lock_version IS NULL);
CREATE INDEX issues_5_on_milestone_id ON issues_5 USING btree (milestone_id);
CREATE INDEX issues_5_on_moved_to_id ON issues_5 USING btree (moved_to_id) WHERE (moved_to_id IS NOT NULL);
CREATE UNIQUE INDEX issues_5_on_project_id_and_external_key ON issues_5 USING btree (project_id, external_key) WHERE (external_key IS NOT NULL);
CREATE UNIQUE INDEX issues_5_on_project_id_and_iid ON issues_5 USING btree (project_id, iid);
CREATE INDEX issues_5_on_promoted_to_epic_id ON issues_5 USING btree (promoted_to_epic_id) WHERE (promoted_to_epic_id IS NOT NULL);
CREATE INDEX issues_5_on_relative_position ON issues_5 USING btree (relative_position);
CREATE INDEX issues_5_on_sprint_id ON issues_5 USING btree (sprint_id);
CREATE INDEX issues_5_on_title_trigram ON issues_5 USING gin (title public.gin_trgm_ops);
CREATE INDEX issues_5_on_updated_at ON issues_5 USING btree (updated_at);
CREATE INDEX issues_5_on_updated_by_id ON issues_5 USING btree (updated_by_id) WHERE (updated_by_id IS NOT NULL);


-- LIMITATION
-- ALTER TABLE issues_5 ADD CONSTRAINT fk_issues_5_05f1e72feb FOREIGN KEY (author_id) REFERENCES public.users(id) ON DELETE SET NULL;

-- LIMITATION
 -- ALTER TABLE issues_5 ADD CONSTRAINT fk_issues_5_3b8c72ea56 FOREIGN KEY (sprint_id) REFERENCES public.sprints(id) ON DELETE CASCADE;


-- LIMITATION
-- ALTER TABLE issues_5 ADD CONSTRAINT fk_issues_5_899c8f3231 FOREIGN KEY (project_id) REFERENCES public.projects(id) ON DELETE CASCADE;


-- LIMITATION
 -- ALTER TABLE issues_5 ADD CONSTRAINT fk_issues_5_96b1dd429c FOREIGN KEY (milestone_id) REFERENCES public.milestones(id) ON DELETE SET NULL;

-- LIMITATION
-- ALTER TABLE issues_5 ADD CONSTRAINT fk_issues_5_c63cbf6c25 FOREIGN KEY (closed_by_id) REFERENCES public.users(id) ON DELETE SET NULL;

-- LIMITATION
-- ALTER TABLE issues_5 ADD CONSTRAINT fk_issues_5_df75a7c8b8 FOREIGN KEY (promoted_to_epic_id) REFERENCES public.epics(id) ON DELETE SET NULL;

-- LIMITATION
-- ALTER TABLE issues_5 ADD CONSTRAINT fk_issues_5_ffed080f01 FOREIGN KEY (updated_by_id) REFERENCES public.users(id) ON DELETE SET NULL;
CREATE SCHEMA IF NOT EXISTS parts;
SET SEARCH_PATH=parts,public;

CREATE TABLE issues_7 (
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
-- ALTER TABLE issues_7 ADD CONSTRAINT issues_pkey PRIMARY KEY (project_id, id);

CREATE INDEX idx_issues_7_on_health_status_not_null ON issues_7 USING btree (health_status) WHERE (health_status IS NOT NULL);
CREATE INDEX idx_issues_7_on_project_id_and_created_at_and_id_and_state_id ON issues_7 USING btree (project_id, created_at, id, state_id);
CREATE INDEX idx_issues_7_on_project_id_and_due_date_and_id_and_state_id ON issues_7 USING btree (project_id, due_date, id, state_id) WHERE (due_date IS NOT NULL);
CREATE INDEX idx_issues_7_on_project_id_and_rel_position_and_state_id_and_id ON issues_7 USING btree (project_id, relative_position, state_id, id DESC);
CREATE INDEX idx_issues_7_on_project_id_and_updated_at_and_id_and_state_id ON issues_7 USING btree (project_id, updated_at, id, state_id);
CREATE INDEX idx_issues_7_on_state_id ON issues_7 USING btree (state_id);
CREATE INDEX issues_7_on_author_id ON issues_7 USING btree (author_id);
CREATE INDEX issues_7_on_author_id_and_id_and_created_at ON issues_7 USING btree (author_id, id, created_at);
CREATE INDEX issues_7_on_closed_by_id ON issues_7 USING btree (closed_by_id);
CREATE INDEX issues_7_on_confidential ON issues_7 USING btree (confidential);
CREATE INDEX issues_7_on_description_trigram ON issues_7 USING gin (description public.gin_trgm_ops);
CREATE INDEX issues_7_on_duplicated_to_id ON issues_7 USING btree (duplicated_to_id) WHERE (duplicated_to_id IS NOT NULL);
CREATE INDEX issues_7_on_lock_version ON issues_7 USING btree (lock_version) WHERE (lock_version IS NULL);
CREATE INDEX issues_7_on_milestone_id ON issues_7 USING btree (milestone_id);
CREATE INDEX issues_7_on_moved_to_id ON issues_7 USING btree (moved_to_id) WHERE (moved_to_id IS NOT NULL);
CREATE UNIQUE INDEX issues_7_on_project_id_and_external_key ON issues_7 USING btree (project_id, external_key) WHERE (external_key IS NOT NULL);
CREATE UNIQUE INDEX issues_7_on_project_id_and_iid ON issues_7 USING btree (project_id, iid);
CREATE INDEX issues_7_on_promoted_to_epic_id ON issues_7 USING btree (promoted_to_epic_id) WHERE (promoted_to_epic_id IS NOT NULL);
CREATE INDEX issues_7_on_relative_position ON issues_7 USING btree (relative_position);
CREATE INDEX issues_7_on_sprint_id ON issues_7 USING btree (sprint_id);
CREATE INDEX issues_7_on_title_trigram ON issues_7 USING gin (title public.gin_trgm_ops);
CREATE INDEX issues_7_on_updated_at ON issues_7 USING btree (updated_at);
CREATE INDEX issues_7_on_updated_by_id ON issues_7 USING btree (updated_by_id) WHERE (updated_by_id IS NOT NULL);


-- LIMITATION
-- ALTER TABLE issues_7 ADD CONSTRAINT fk_issues_7_05f1e72feb FOREIGN KEY (author_id) REFERENCES public.users(id) ON DELETE SET NULL;

-- LIMITATION
 -- ALTER TABLE issues_7 ADD CONSTRAINT fk_issues_7_3b8c72ea56 FOREIGN KEY (sprint_id) REFERENCES public.sprints(id) ON DELETE CASCADE;


-- LIMITATION
-- ALTER TABLE issues_7 ADD CONSTRAINT fk_issues_7_899c8f3231 FOREIGN KEY (project_id) REFERENCES public.projects(id) ON DELETE CASCADE;


-- LIMITATION
 -- ALTER TABLE issues_7 ADD CONSTRAINT fk_issues_7_96b1dd429c FOREIGN KEY (milestone_id) REFERENCES public.milestones(id) ON DELETE SET NULL;

-- LIMITATION
-- ALTER TABLE issues_7 ADD CONSTRAINT fk_issues_7_c63cbf6c25 FOREIGN KEY (closed_by_id) REFERENCES public.users(id) ON DELETE SET NULL;

-- LIMITATION
-- ALTER TABLE issues_7 ADD CONSTRAINT fk_issues_7_df75a7c8b8 FOREIGN KEY (promoted_to_epic_id) REFERENCES public.epics(id) ON DELETE SET NULL;

-- LIMITATION
-- ALTER TABLE issues_7 ADD CONSTRAINT fk_issues_7_ffed080f01 FOREIGN KEY (updated_by_id) REFERENCES public.users(id) ON DELETE SET NULL;
