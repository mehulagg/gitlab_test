--
-- PostgreSQL database dump
--

-- Dumped from database version 11.7 (Ubuntu 11.7-2.pgdg19.10+1)
-- Dumped by pg_dump version 11.7 (Ubuntu 11.7-2.pgdg19.10+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: projects; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.projects (
    id integer NOT NULL,
    name character varying,
    path character varying,
    description text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    creator_id integer,
    namespace_id integer NOT NULL,
    last_activity_at timestamp without time zone,
    import_url character varying,
    visibility_level integer DEFAULT 0 NOT NULL,
    archived boolean DEFAULT false NOT NULL,
    avatar character varying,
    merge_requests_template text,
    star_count integer DEFAULT 0 NOT NULL,
    merge_requests_rebase_enabled boolean DEFAULT false,
    import_type character varying,
    import_source character varying,
    approvals_before_merge integer DEFAULT 0 NOT NULL,
    reset_approvals_on_push boolean DEFAULT true,
    merge_requests_ff_only_enabled boolean DEFAULT false,
    issues_template text,
    mirror boolean DEFAULT false NOT NULL,
    mirror_last_update_at timestamp without time zone,
    mirror_last_successful_update_at timestamp without time zone,
    mirror_user_id integer,
    shared_runners_enabled boolean DEFAULT true NOT NULL,
    runners_token character varying,
    build_coverage_regex character varying,
    build_allow_git_fetch boolean DEFAULT true NOT NULL,
    build_timeout integer DEFAULT 3600 NOT NULL,
    mirror_trigger_builds boolean DEFAULT false NOT NULL,
    pending_delete boolean DEFAULT false,
    public_builds boolean DEFAULT true NOT NULL,
    last_repository_check_failed boolean,
    last_repository_check_at timestamp without time zone,
    container_registry_enabled boolean,
    only_allow_merge_if_pipeline_succeeds boolean DEFAULT false NOT NULL,
    has_external_issue_tracker boolean,
    repository_storage character varying DEFAULT 'default'::character varying NOT NULL,
    repository_read_only boolean,
    request_access_enabled boolean DEFAULT true NOT NULL,
    has_external_wiki boolean,
    ci_config_path character varying,
    lfs_enabled boolean,
    description_html text,
    only_allow_merge_if_all_discussions_are_resolved boolean,
    repository_size_limit bigint,
    printing_merge_request_link_enabled boolean DEFAULT true NOT NULL,
    auto_cancel_pending_pipelines integer DEFAULT 1 NOT NULL,
    service_desk_enabled boolean DEFAULT true,
    cached_markdown_version integer,
    delete_error text,
    last_repository_updated_at timestamp without time zone,
    disable_overriding_approvers_per_merge_request boolean,
    storage_version smallint,
    resolve_outdated_diff_discussions boolean,
    remote_mirror_available_overridden boolean,
    only_mirror_protected_branches boolean,
    pull_mirror_available_overridden boolean,
    jobs_cache_index integer,
    external_authorization_classification_label character varying,
    mirror_overwrites_diverged_branches boolean,
    pages_https_only boolean DEFAULT true,
    external_webhook_token character varying,
    packages_enabled boolean,
    merge_requests_author_approval boolean,
    pool_repository_id bigint,
    runners_token_encrypted character varying,
    bfg_object_map character varying,
    detected_repository_languages boolean,
    merge_requests_disable_committers_approval boolean,
    require_password_to_approve boolean,
    emails_disabled boolean,
    max_pages_size integer,
    max_artifacts_size integer,
    pull_mirror_branch_prefix character varying(50),
    remove_source_branch_after_merge boolean,
    marked_for_deletion_at date,
    marked_for_deletion_by_user_id integer,
    autoclose_referenced_issues boolean,
    suggestion_commit_message character varying(255)
);


--
-- Name: projects_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.projects_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: projects_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.projects_id_seq OWNED BY public.projects.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id integer NOT NULL,
    email character varying DEFAULT ''::character varying NOT NULL,
    encrypted_password character varying DEFAULT ''::character varying NOT NULL,
    reset_password_token character varying,
    reset_password_sent_at timestamp without time zone,
    remember_created_at timestamp without time zone,
    sign_in_count integer DEFAULT 0,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    current_sign_in_ip character varying,
    last_sign_in_ip character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    name character varying,
    admin boolean DEFAULT false NOT NULL,
    projects_limit integer NOT NULL,
    skype character varying DEFAULT ''::character varying NOT NULL,
    linkedin character varying DEFAULT ''::character varying NOT NULL,
    twitter character varying DEFAULT ''::character varying NOT NULL,
    bio character varying,
    failed_attempts integer DEFAULT 0,
    locked_at timestamp without time zone,
    username character varying,
    can_create_group boolean DEFAULT true NOT NULL,
    can_create_team boolean DEFAULT true NOT NULL,
    state character varying,
    color_scheme_id integer DEFAULT 1 NOT NULL,
    password_expires_at timestamp without time zone,
    created_by_id integer,
    last_credential_check_at timestamp without time zone,
    avatar character varying,
    confirmation_token character varying,
    confirmed_at timestamp without time zone,
    confirmation_sent_at timestamp without time zone,
    unconfirmed_email character varying,
    hide_no_ssh_key boolean DEFAULT false,
    website_url character varying DEFAULT ''::character varying NOT NULL,
    admin_email_unsubscribed_at timestamp without time zone,
    notification_email character varying,
    hide_no_password boolean DEFAULT false,
    password_automatically_set boolean DEFAULT false,
    location character varying,
    encrypted_otp_secret character varying,
    encrypted_otp_secret_iv character varying,
    encrypted_otp_secret_salt character varying,
    otp_required_for_login boolean DEFAULT false NOT NULL,
    otp_backup_codes text,
    public_email character varying DEFAULT ''::character varying NOT NULL,
    dashboard integer DEFAULT 0,
    project_view integer DEFAULT 0,
    consumed_timestep integer,
    layout integer DEFAULT 0,
    hide_project_limit boolean DEFAULT false,
    note text,
    unlock_token character varying,
    otp_grace_period_started_at timestamp without time zone,
    external boolean DEFAULT false,
    incoming_email_token character varying,
    organization character varying,
    auditor boolean DEFAULT false NOT NULL,
    require_two_factor_authentication_from_group boolean DEFAULT false NOT NULL,
    two_factor_grace_period integer DEFAULT 48 NOT NULL,
    ghost boolean,
    last_activity_on date,
    notified_of_own_activity boolean,
    preferred_language character varying,
    email_opted_in boolean,
    email_opted_in_ip character varying,
    email_opted_in_source_id integer,
    email_opted_in_at timestamp without time zone,
    theme_id smallint,
    accepted_term_id integer,
    feed_token character varying,
    private_profile boolean DEFAULT false NOT NULL,
    roadmap_layout smallint,
    include_private_contributions boolean,
    commit_email character varying,
    group_view integer,
    managing_group_id integer,
    bot_type smallint,
    first_name character varying(255),
    last_name character varying(255),
    static_object_token character varying(255),
    role smallint,
    user_type smallint
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: projects id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.projects ALTER COLUMN id SET DEFAULT nextval('public.projects_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: projects projects_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT projects_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: idx_project_repository_check_partial; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_project_repository_check_partial ON public.projects USING btree (repository_storage, created_at) WHERE (last_repository_check_at IS NULL);


--
-- Name: idx_projects_on_repository_storage_last_repository_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_projects_on_repository_storage_last_repository_updated_at ON public.projects USING btree (id, repository_storage, last_repository_updated_at);


--
-- Name: index_for_migrating_user_highest_roles_table; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_for_migrating_user_highest_roles_table ON public.users USING btree (id) WHERE (((state)::text = 'active'::text) AND (user_type IS NULL) AND (bot_type IS NULL) AND (ghost IS NOT TRUE));


--
-- Name: index_on_id_partial_with_legacy_storage; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_on_id_partial_with_legacy_storage ON public.projects USING btree (id) WHERE ((storage_version < 2) OR (storage_version IS NULL));


--
-- Name: index_on_users_name_lower; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_on_users_name_lower ON public.users USING btree (lower((name)::text));


--
-- Name: index_projects_api_created_at_id_desc; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_projects_api_created_at_id_desc ON public.projects USING btree (created_at, id DESC);


--
-- Name: index_projects_api_created_at_id_for_archived; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_projects_api_created_at_id_for_archived ON public.projects USING btree (created_at, id) WHERE ((archived = true) AND (pending_delete = false));


--
-- Name: index_projects_api_created_at_id_for_archived_vis20; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_projects_api_created_at_id_for_archived_vis20 ON public.projects USING btree (created_at, id) WHERE ((archived = true) AND (visibility_level = 20) AND (pending_delete = false));


--
-- Name: index_projects_api_created_at_id_for_vis10; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_projects_api_created_at_id_for_vis10 ON public.projects USING btree (created_at, id) WHERE ((visibility_level = 10) AND (pending_delete = false));


--
-- Name: index_projects_api_last_activity_at_id_desc; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_projects_api_last_activity_at_id_desc ON public.projects USING btree (last_activity_at, id DESC);


--
-- Name: index_projects_api_name_id_desc; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_projects_api_name_id_desc ON public.projects USING btree (name, id DESC);


--
-- Name: index_projects_api_path_id_desc; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_projects_api_path_id_desc ON public.projects USING btree (path, id DESC);


--
-- Name: index_projects_api_updated_at_id_desc; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_projects_api_updated_at_id_desc ON public.projects USING btree (updated_at, id DESC);


--
-- Name: index_projects_api_vis20_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_projects_api_vis20_created_at ON public.projects USING btree (created_at, id) WHERE (visibility_level = 20);


--
-- Name: index_projects_api_vis20_last_activity_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_projects_api_vis20_last_activity_at ON public.projects USING btree (last_activity_at, id) WHERE (visibility_level = 20);


--
-- Name: index_projects_api_vis20_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_projects_api_vis20_name ON public.projects USING btree (name, id) WHERE (visibility_level = 20);


--
-- Name: index_projects_api_vis20_path; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_projects_api_vis20_path ON public.projects USING btree (path, id) WHERE (visibility_level = 20);


--
-- Name: index_projects_api_vis20_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_projects_api_vis20_updated_at ON public.projects USING btree (updated_at, id) WHERE (visibility_level = 20);


--
-- Name: index_projects_on_created_at_and_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_projects_on_created_at_and_id ON public.projects USING btree (created_at, id);


--
-- Name: index_projects_on_creator_id_and_created_at_and_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_projects_on_creator_id_and_created_at_and_id ON public.projects USING btree (creator_id, created_at, id);


--
-- Name: index_projects_on_creator_id_and_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_projects_on_creator_id_and_id ON public.projects USING btree (creator_id, id);


--
-- Name: index_projects_on_description_trigram; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_projects_on_description_trigram ON public.projects USING gin (description public.gin_trgm_ops);


--
-- Name: index_projects_on_id_and_archived_and_pending_delete; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_projects_on_id_and_archived_and_pending_delete ON public.projects USING btree (id) WHERE ((archived = false) AND (pending_delete = false));


--
-- Name: index_projects_on_id_partial_for_visibility; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_projects_on_id_partial_for_visibility ON public.projects USING btree (id) WHERE (visibility_level = ANY (ARRAY[10, 20]));


--
-- Name: index_projects_on_id_service_desk_enabled; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_projects_on_id_service_desk_enabled ON public.projects USING btree (id) WHERE (service_desk_enabled = true);


--
-- Name: index_projects_on_last_activity_at_and_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_projects_on_last_activity_at_and_id ON public.projects USING btree (last_activity_at, id);


--
-- Name: index_projects_on_last_repository_check_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_projects_on_last_repository_check_at ON public.projects USING btree (last_repository_check_at) WHERE (last_repository_check_at IS NOT NULL);


--
-- Name: index_projects_on_last_repository_check_failed; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_projects_on_last_repository_check_failed ON public.projects USING btree (last_repository_check_failed);


--
-- Name: index_projects_on_last_repository_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_projects_on_last_repository_updated_at ON public.projects USING btree (last_repository_updated_at);


--
-- Name: index_projects_on_lower_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_projects_on_lower_name ON public.projects USING btree (lower((name)::text));


--
-- Name: index_projects_on_marked_for_deletion_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_projects_on_marked_for_deletion_at ON public.projects USING btree (marked_for_deletion_at) WHERE (marked_for_deletion_at IS NOT NULL);


--
-- Name: index_projects_on_marked_for_deletion_by_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_projects_on_marked_for_deletion_by_user_id ON public.projects USING btree (marked_for_deletion_by_user_id) WHERE (marked_for_deletion_by_user_id IS NOT NULL);


--
-- Name: index_projects_on_mirror_creator_id_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_projects_on_mirror_creator_id_created_at ON public.projects USING btree (creator_id, created_at) WHERE ((mirror = true) AND (mirror_trigger_builds = true));


--
-- Name: index_projects_on_mirror_id_where_mirror_and_trigger_builds; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_projects_on_mirror_id_where_mirror_and_trigger_builds ON public.projects USING btree (id) WHERE ((mirror = true) AND (mirror_trigger_builds = true));


--
-- Name: index_projects_on_mirror_last_successful_update_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_projects_on_mirror_last_successful_update_at ON public.projects USING btree (mirror_last_successful_update_at);


--
-- Name: index_projects_on_mirror_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_projects_on_mirror_user_id ON public.projects USING btree (mirror_user_id);


--
-- Name: index_projects_on_name_and_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_projects_on_name_and_id ON public.projects USING btree (name, id);


--
-- Name: index_projects_on_name_trigram; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_projects_on_name_trigram ON public.projects USING gin (name public.gin_trgm_ops);


--
-- Name: index_projects_on_namespace_id_and_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_projects_on_namespace_id_and_id ON public.projects USING btree (namespace_id, id);


--
-- Name: index_projects_on_path_and_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_projects_on_path_and_id ON public.projects USING btree (path, id);


--
-- Name: index_projects_on_path_trigram; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_projects_on_path_trigram ON public.projects USING gin (path public.gin_trgm_ops);


--
-- Name: index_projects_on_pending_delete; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_projects_on_pending_delete ON public.projects USING btree (pending_delete);


--
-- Name: index_projects_on_pool_repository_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_projects_on_pool_repository_id ON public.projects USING btree (pool_repository_id) WHERE (pool_repository_id IS NOT NULL);


--
-- Name: index_projects_on_repository_storage; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_projects_on_repository_storage ON public.projects USING btree (repository_storage);


--
-- Name: index_projects_on_runners_token; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_projects_on_runners_token ON public.projects USING btree (runners_token);


--
-- Name: index_projects_on_runners_token_encrypted; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_projects_on_runners_token_encrypted ON public.projects USING btree (runners_token_encrypted);


--
-- Name: index_projects_on_star_count; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_projects_on_star_count ON public.projects USING btree (star_count);


--
-- Name: index_projects_on_updated_at_and_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_projects_on_updated_at_and_id ON public.projects USING btree (updated_at, id);


--
-- Name: index_service_desk_enabled_projects_on_id_creator_id_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_service_desk_enabled_projects_on_id_creator_id_created_at ON public.projects USING btree (id, creator_id, created_at) WHERE (service_desk_enabled = true);


--
-- Name: index_users_on_accepted_term_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_accepted_term_id ON public.users USING btree (accepted_term_id);


--
-- Name: index_users_on_admin; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_admin ON public.users USING btree (admin);


--
-- Name: index_users_on_bot_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_bot_type ON public.users USING btree (bot_type);


--
-- Name: index_users_on_confirmation_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_confirmation_token ON public.users USING btree (confirmation_token);


--
-- Name: index_users_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_created_at ON public.users USING btree (created_at);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_email ON public.users USING btree (email);


--
-- Name: index_users_on_email_trigram; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_email_trigram ON public.users USING gin (email public.gin_trgm_ops);


--
-- Name: index_users_on_feed_token; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_feed_token ON public.users USING btree (feed_token);


--
-- Name: index_users_on_ghost; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_ghost ON public.users USING btree (ghost);


--
-- Name: index_users_on_group_view; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_group_view ON public.users USING btree (group_view);


--
-- Name: index_users_on_incoming_email_token; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_incoming_email_token ON public.users USING btree (incoming_email_token);


--
-- Name: index_users_on_managing_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_managing_group_id ON public.users USING btree (managing_group_id);


--
-- Name: index_users_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_name ON public.users USING btree (name);


--
-- Name: index_users_on_name_trigram; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_name_trigram ON public.users USING gin (name public.gin_trgm_ops);


--
-- Name: index_users_on_public_email; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_public_email ON public.users USING btree (public_email) WHERE ((public_email)::text <> ''::text);


--
-- Name: index_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_reset_password_token ON public.users USING btree (reset_password_token);


--
-- Name: index_users_on_state; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_state ON public.users USING btree (state);


--
-- Name: index_users_on_state_and_user_type_internal; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_state_and_user_type_internal ON public.users USING btree (state, user_type) WHERE (ghost IS NOT TRUE);


--
-- Name: index_users_on_static_object_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_static_object_token ON public.users USING btree (static_object_token);


--
-- Name: index_users_on_unconfirmed_email; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_unconfirmed_email ON public.users USING btree (unconfirmed_email) WHERE (unconfirmed_email IS NOT NULL);


--
-- Name: index_users_on_unlock_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_unlock_token ON public.users USING btree (unlock_token);


--
-- Name: index_users_on_user_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_user_type ON public.users USING btree (user_type);


--
-- Name: index_users_on_username; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_username ON public.users USING btree (username);


--
-- Name: index_users_on_username_trigram; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_username_trigram ON public.users USING gin (username public.gin_trgm_ops);


--
-- Name: tmp_idx_on_user_id_where_bio_is_filled; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX tmp_idx_on_user_id_where_bio_is_filled ON public.users USING btree (id) WHERE ((COALESCE(bio, ''::character varying))::text IS DISTINCT FROM ''::text);


--
-- Name: projects fk_25d8780d11; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT fk_25d8780d11 FOREIGN KEY (marked_for_deletion_by_user_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: projects fk_6e5c14658a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT fk_6e5c14658a FOREIGN KEY (pool_repository_id) REFERENCES public.pool_repositories(id) ON DELETE SET NULL;


--
-- Name: users fk_789cd90b35; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT fk_789cd90b35 FOREIGN KEY (accepted_term_id) REFERENCES public.application_setting_terms(id) ON DELETE CASCADE;


--
-- Name: users fk_a4b8fefe3e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT fk_a4b8fefe3e FOREIGN KEY (managing_group_id) REFERENCES public.namespaces(id) ON DELETE SET NULL;


--
-- PostgreSQL database dump complete
--

