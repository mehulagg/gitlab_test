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
) PARTITION BY HASH (project_id);


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

ALTER TABLE public.issues ALTER COLUMN id SET DEFAULT nextval('public.issues_id_seq'::regclass);


--
-- PostgreSQL database dump complete
--

CREATE SCHEMA IF NOT EXISTS parts;

CREATE EXTENSION IF NOT EXISTS postgres_fdw;

CREATE SERVER IF NOT EXISTS shard1 FOREIGN DATA WRAPPER postgres_fdw OPTIONS (dbname 'shard1', host '/home/abrandl-gl/workspace/gdk/postgresql');
CREATE SERVER IF NOT EXISTS shard2 FOREIGN DATA WRAPPER postgres_fdw OPTIONS (dbname 'shard2', host '/home/abrandl-gl/workspace/gdk/postgresql');

CREATE USER MAPPING IF NOT EXISTS for "abrandl-gl" SERVER shard1 OPTIONS (user 'abrandl-gl', password 'abrandl-gl');
CREATE USER MAPPING IF NOT EXISTS for "abrandl-gl" SERVER shard2 OPTIONS (user 'abrandl-gl', password 'abrandl-gl');

CREATE FOREIGN TABLE parts.issues_0 PARTITION OF public.issues FOR VALUES WITH (modulus 8, remainder 0) SERVER shard1;
CREATE FOREIGN TABLE parts.issues_1 PARTITION OF public.issues FOR VALUES WITH (modulus 8, remainder 1) SERVER shard2;
CREATE FOREIGN TABLE parts.issues_2 PARTITION OF public.issues FOR VALUES WITH (modulus 8, remainder 2) SERVER shard1;
CREATE FOREIGN TABLE parts.issues_3 PARTITION OF public.issues FOR VALUES WITH (modulus 8, remainder 3) SERVER shard2;
CREATE FOREIGN TABLE parts.issues_4 PARTITION OF public.issues FOR VALUES WITH (modulus 8, remainder 4) SERVER shard1;
CREATE FOREIGN TABLE parts.issues_5 PARTITION OF public.issues FOR VALUES WITH (modulus 8, remainder 5) SERVER shard2;
CREATE FOREIGN TABLE parts.issues_6 PARTITION OF public.issues FOR VALUES WITH (modulus 8, remainder 6) SERVER shard1;
CREATE FOREIGN TABLE parts.issues_7 PARTITION OF public.issues FOR VALUES WITH (modulus 8, remainder 7) SERVER shard2;
