DROP SCHEMA parts CASCADE;
DROP SERVER IF EXISTS shard1 CASCADE;
DROP SERVER IF EXISTS shard2 CASCADE;
DROP EXTENSION IF EXISTS postgres_fdw;

CREATE TABLE public.issues (
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


CREATE SEQUENCE public.issues_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: issues_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.issues_id_seq OWNED BY public.issues.id;


--
-- Name: issues id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.issues ALTER COLUMN id SET DEFAULT nextval('public.issues_id_seq'::regclass);


--
-- Name: issues issues_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.issues
    ADD CONSTRAINT issues_pkey PRIMARY KEY (id);


--
-- Name: idx_issues_on_health_status_not_null; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_issues_on_health_status_not_null ON public.issues USING btree (health_status) WHERE (health_status IS NOT NULL);


--
-- Name: idx_issues_on_project_id_and_created_at_and_id_and_state_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_issues_on_project_id_and_created_at_and_id_and_state_id ON public.issues USING btree (project_id, created_at, id, state_id);


--
-- Name: idx_issues_on_project_id_and_due_date_and_id_and_state_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_issues_on_project_id_and_due_date_and_id_and_state_id ON public.issues USING btree (project_id, due_date, id, state_id) WHERE (due_date IS NOT NULL);


--
-- Name: idx_issues_on_project_id_and_rel_position_and_state_id_and_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_issues_on_project_id_and_rel_position_and_state_id_and_id ON public.issues USING btree (project_id, relative_position, state_id, id DESC);


--
-- Name: idx_issues_on_project_id_and_updated_at_and_id_and_state_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_issues_on_project_id_and_updated_at_and_id_and_state_id ON public.issues USING btree (project_id, updated_at, id, state_id);


--
-- Name: idx_issues_on_state_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_issues_on_state_id ON public.issues USING btree (state_id);


--
-- Name: index_issues_on_author_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_issues_on_author_id ON public.issues USING btree (author_id);


--
-- Name: index_issues_on_author_id_and_id_and_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_issues_on_author_id_and_id_and_created_at ON public.issues USING btree (author_id, id, created_at);


--
-- Name: index_issues_on_closed_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_issues_on_closed_by_id ON public.issues USING btree (closed_by_id);


--
-- Name: index_issues_on_confidential; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_issues_on_confidential ON public.issues USING btree (confidential);


--
-- Name: index_issues_on_description_trigram; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_issues_on_description_trigram ON public.issues USING gin (description public.gin_trgm_ops);


--
-- Name: index_issues_on_duplicated_to_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_issues_on_duplicated_to_id ON public.issues USING btree (duplicated_to_id) WHERE (duplicated_to_id IS NOT NULL);


--
-- Name: index_issues_on_lock_version; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_issues_on_lock_version ON public.issues USING btree (lock_version) WHERE (lock_version IS NULL);


--
-- Name: index_issues_on_milestone_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_issues_on_milestone_id ON public.issues USING btree (milestone_id);


--
-- Name: index_issues_on_moved_to_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_issues_on_moved_to_id ON public.issues USING btree (moved_to_id) WHERE (moved_to_id IS NOT NULL);


--
-- Name: index_issues_on_project_id_and_external_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_issues_on_project_id_and_external_key ON public.issues USING btree (project_id, external_key) WHERE (external_key IS NOT NULL);


--
-- Name: index_issues_on_project_id_and_iid; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_issues_on_project_id_and_iid ON public.issues USING btree (project_id, iid);


--
-- Name: index_issues_on_promoted_to_epic_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_issues_on_promoted_to_epic_id ON public.issues USING btree (promoted_to_epic_id) WHERE (promoted_to_epic_id IS NOT NULL);


--
-- Name: index_issues_on_relative_position; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_issues_on_relative_position ON public.issues USING btree (relative_position);


--
-- Name: index_issues_on_sprint_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_issues_on_sprint_id ON public.issues USING btree (sprint_id);


--
-- Name: index_issues_on_title_trigram; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_issues_on_title_trigram ON public.issues USING gin (title public.gin_trgm_ops);


--
-- Name: index_issues_on_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_issues_on_updated_at ON public.issues USING btree (updated_at);


--
-- Name: index_issues_on_updated_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_issues_on_updated_by_id ON public.issues USING btree (updated_by_id) WHERE (updated_by_id IS NOT NULL);


--
-- Name: issues fk_05f1e72feb; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.issues
    ADD CONSTRAINT fk_05f1e72feb FOREIGN KEY (author_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: issues fk_3b8c72ea56; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.issues
    ADD CONSTRAINT fk_3b8c72ea56 FOREIGN KEY (sprint_id) REFERENCES public.sprints(id) ON DELETE CASCADE;


--
-- Name: issues fk_899c8f3231; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.issues
    ADD CONSTRAINT fk_899c8f3231 FOREIGN KEY (project_id) REFERENCES public.projects(id) ON DELETE CASCADE;


--
-- Name: issues fk_96b1dd429c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.issues
    ADD CONSTRAINT fk_96b1dd429c FOREIGN KEY (milestone_id) REFERENCES public.milestones(id) ON DELETE SET NULL;


--
-- Name: issues fk_9c4516d665; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.issues
    ADD CONSTRAINT fk_9c4516d665 FOREIGN KEY (duplicated_to_id) REFERENCES public.issues(id) ON DELETE SET NULL;


--
-- Name: issues fk_a194299be1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.issues
    ADD CONSTRAINT fk_a194299be1 FOREIGN KEY (moved_to_id) REFERENCES public.issues(id) ON DELETE SET NULL;


--
-- Name: issues fk_c63cbf6c25; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.issues
    ADD CONSTRAINT fk_c63cbf6c25 FOREIGN KEY (closed_by_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: issues fk_df75a7c8b8; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.issues
    ADD CONSTRAINT fk_df75a7c8b8 FOREIGN KEY (promoted_to_epic_id) REFERENCES public.epics(id) ON DELETE SET NULL;


--
-- Name: issues fk_ffed080f01; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.issues
    ADD CONSTRAINT fk_ffed080f01 FOREIGN KEY (updated_by_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- PostgreSQL database dump complete
--

