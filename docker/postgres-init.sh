#!/usr/bin/env bash
set -Eeo pipefail

# check to see if this file is being run or sourced from another script
_is_sourced() {
	# https://unix.stackexchange.com/a/215279
	[ "${#FUNCNAME[@]}" -ge 2 ] \
		&& [ "${FUNCNAME[0]}" = '_is_sourced' ] \
		&& [ "${FUNCNAME[1]}" = 'source' ]
}

setup_env() {
	declare -g DATABASE_ALREADY_EXISTS
	# look specifically for PG_VERSION, as it is expected in the DB dir
	if [ -s "$PGDATA/PG_VERSION" ]; then
		DATABASE_ALREADY_EXISTS='true'
	fi
}

_main() {

setup_env

# exec
if [ -z "$DATABASE_ALREADY_EXISTS" ]; then

echo 
echo 'init illa database.'
echo 

# waitting for postgres init finished 
# it should be over 18s, pre-postgres.sh will cost at least 18s on MacOS. 
sleep 20 

psql -U postgres postgres <<EOF
create database illa;

\c illa;

create user illa with encrypted password 'illa2022';
grant all privileges on database illa to illa;

CREATE EXTENSION pg_trgm;
CREATE EXTENSION btree_gin;

create table if not exists users
(
    id                       bigserial                         not null
        primary key,
    nickname                 varchar(15)                       not null, /* 3-15 character */
    password_digest          varchar(60)                       not null,
    email                    varchar(255)                      not null,
    language                 smallint                          not null,
    is_subscribed            boolean default false             not null,
    created_at               timestamp                         not null,
    updated_at               timestamp                         not null,
    uid                      uuid    default gen_random_uuid() not null,
    constraint users_ukey
        unique (id, uid)
);

alter table users
    owner to illa;


create table if not exists resources
(
    id                       bigserial                         not null
        primary key,
    name                     varchar(200)                      not null, /* 200 character */
    type                     smallint                          not null,
    options                  jsonb,
    created_at               timestamp                         not null,
    created_by               bigint                            not null,
    updated_at               timestamp                         not null,
    updated_by               bigint                            not null
);

alter table resources
    owner to illa;


create table if not exists apps
(
    id                       bigserial                         not null
        primary key,
    name                     varchar(200)                      not null, /* 200 character */
    release_version          bigint                            not null, 
    mainline_version         bigint                            not null, 
    created_at               timestamp                         not null,
    created_by               bigint                            not null,
    updated_at               timestamp                         not null,
    updated_by               bigint                            not null
);

alter table apps
    owner to illa;



create table if not exists actions
(
    id              bigserial
        primary key,
    version         bigint                                            not null,
    resource_ref_id bigint                                            not null,
    app_ref_id      bigint                                            not null,
    name            varchar(255)                                      not null,
    type            smallint                                          not null,
    transformer     jsonb                                             not null,
    trigger_mode    varchar(16)                                       not null,
    template        jsonb                                                     , 
    created_at      timestamp                                         not null,
    created_by      bigint                                            not null,
    updated_at      timestamp                                         not null,
    updated_by      bigint                                            not null
);

alter table actions
    owner to illa;

create index if not exists actions_at_apprefid_and_version
    on actions (app_ref_id, version);

ALTER TABLE actions
  DROP CONSTRAINT IF EXISTS actions_displayname_constrainte
, ADD CONSTRAINT actions_displayname_constrainte UNIQUE (version, app_ref_id, name);


create table if not exists tree_states 
(
    id                       bigserial                         not null
        primary key,
    state_type               smallint                          not null, 
    parent_node_ref_id       bigint                            not null, 
    children_node_ref_ids    jsonb                                     , 
    app_ref_id               bigint                            not null, 
    version                  bigint                            not null, 
    name                     text                              not null, 
    content                  jsonb                             not null, 
    created_at               timestamp                         not null,
    created_by               bigint                            not null,
    updated_at               timestamp                         not null,
    updated_by               bigint                            not null
);

CREATE INDEX tree_states_at_apprefid_and_version_and_statetype ON tree_states (app_ref_id, version, state_type);
CREATE INDEX tree_states_at_parentnoderefid ON tree_states (parent_node_ref_id);
CREATE INDEX tree_states_at_childrennoderefids ON tree_states (children_node_ref_ids);
CREATE INDEX tree_states_with_gin_at_childrennoderefids ON tree_states USING gin (children_node_ref_ids);
CREATE INDEX tree_states_with_gin_at_name ON tree_states USING gin (name);
CREATE INDEX tree_states_with_fulltextgin_at_name ON tree_states USING gin (to_tsvector('english', name));

ALTER TABLE tree_states
  DROP CONSTRAINT IF EXISTS tree_states_displayname_constrainte
, ADD CONSTRAINT tree_states_displayname_constrainte UNIQUE (version, app_ref_id, name);


alter table tree_states
    owner to illa;


create table if not exists kv_states
(
    id                       bigserial                         not null
        primary key,
    state_type               smallint                          not null, 
    app_ref_id               bigint                            not null, 
    version                  bigint                            not null, 
    key                      text                              not null, 
    value                    jsonb                             not null, 
    created_at               timestamp                         not null,
    created_by               bigint                            not null,
    updated_at               timestamp                         not null,
    updated_by               bigint                            not null
);

CREATE INDEX kv_states_at_apprefid_and_version_and_statetype ON kv_states (app_ref_id, version, state_type);
CREATE INDEX kv_states_with_gin_at_key ON kv_states USING gin (key);
CREATE INDEX kv_states_with_fulltextgin_at_key ON kv_states USING gin (to_tsvector('english', key));

ALTER TABLE kv_states
  DROP CONSTRAINT IF EXISTS kv_states_displayname_constrainte
, ADD CONSTRAINT kv_states_displayname_constrainte UNIQUE (version, app_ref_id, key);

alter table kv_states
    owner to illa;


create table if not exists set_states
(
    id                       bigserial                         not null
        primary key,
    state_type               smallint                          not null,
    app_ref_id               bigint                            not null,
    version                  bigint                            not null, 
    value                    text                              not null, 
    created_at               timestamp                         not null,
    created_by               bigint                            not null,
    updated_at               timestamp                         not null,
    updated_by               bigint                            not null
);

CREATE INDEX set_states_at_apprefid_and_version_and_statetype ON set_states (app_ref_id, version, state_type);
CREATE INDEX set_states_with_gin_at_value ON set_states USING gin (value);
CREATE INDEX set_states_with_fulltextgin_at_value ON set_states USING gin (to_tsvector('english', value));

ALTER TABLE set_states
  DROP CONSTRAINT IF EXISTS set_states_displayname_constrainte
, ADD CONSTRAINT set_states_displayname_constrainte UNIQUE (version, app_ref_id, value);

alter table set_states
    owner to illa;

INSERT INTO users (id, nickname, password_digest, email, language, is_subscribed, created_at, updated_at, uid) VALUES (DEFAULT, 'root', '$2a$10$iVIxJRgy1K6RIV389AYg3OiMIbuDyuCIja1xrHGkCljdg/6gdmWXa', 'root', 1, false, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, DEFAULT);

EOF

    echo
    echo 'init illa database done.'
    echo

else
	echo
	echo 'illa database already exists; Skipping initialization'
	echo
fi
}






if ! _is_sourced; then
	_main "$@"
fi
