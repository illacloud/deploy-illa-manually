#!/usr/bin/env bash
set -Eeo pipefail

# check to see if this file is being run or sourced from another script
_is_sourced() {
	# https://unix.stackexchange.com/a/215279
	[ "${#FUNCNAME[@]}" -ge 2 ] \
		&& [ "${FUNCNAME[0]}" = '_is_sourced' ] \
		&& [ "${FUNCNAME[1]}" = 'source' ]
}



_main() {


echo 
echo '[postgres-init.sh] init illa_builder & illa_supervisor database.'
echo 

# waitting for postgres init finished 
# it should be over 18s, pre-postgres.sh will cost at least 18s on MacOS. 
sleep 20 

psql -U postgres postgres <<EOF

-- init illa_builder


create database illa_builder;

\c illa_builder;

create user illa_builder with encrypted password 'illa2022';

grant all privileges on database illa_builder to illa_builder;

CREATE EXTENSION pg_trgm;

CREATE EXTENSION btree_gin;

-- apps
create table if not exists apps (
    id                      bigserial                       not null primary key,
    uid                     uuid default gen_random_uuid()  not null,
    team_id                 bigserial                       not null, 
    name                    varchar(200)                    not null,
    release_version         bigint                          not null,
    mainline_version        bigint                          not null,
    config                  jsonb,
    created_at              timestamp                       not null,
    created_by              bigint                          not null,
    updated_at              timestamp                       not null,
    updated_by              bigint                          not null
);

alter table apps owner to illa_builder;

-- resource
create table if not exists resources (
    id                      bigserial                       not null primary key,
    uid                     uuid default gen_random_uuid()  not null,
    team_id                 bigserial                       not null, 
    name                    varchar(200)                    not null,
    type                    smallint                        not null,
    options                 jsonb,
    created_at              timestamp                       not null,
    created_by              bigint                          not null,
    updated_at              timestamp                       not null,
    updated_by              bigint                          not null
);

alter table resources owner to illa_builder;

-- actions
create table if not exists actions (
    id                      bigserial                       not null primary key,
    uid                     uuid default gen_random_uuid()  not null,
    team_id                 bigserial                       not null, 
    version                 bigint                          not null,
    resource_ref_id         bigint                          not null,
    app_ref_id              bigint                          not null,
    name                    varchar(255)                    not null,
    type                    smallint                        not null,
    transformer             jsonb                           not null,
    trigger_mode            varchar(16)                     not null,
    template                jsonb,
    config                  jsonb,
    created_at              timestamp                       not null,
    created_by              bigint                          not null,
    updated_at              timestamp                       not null,
    updated_by              bigint                          not null
);

create index if not exists actions_at_apprefid_and_version on actions (app_ref_id, version);
alter table actions owner to illa_builder;


ALTER TABLE actions DROP CONSTRAINT IF EXISTS actions_displayname_constrainte,
ADD CONSTRAINT actions_displayname_constrainte UNIQUE (version, app_ref_id, name);

-- tree_states, component tree_states
create table if not exists tree_states (
    id                      bigserial                       not null primary key,
    uid                     uuid default gen_random_uuid()  not null,
    team_id                 bigserial                       not null, 
    state_type              smallint                        not null,
    parent_node_ref_id      bigint                          not null,
    children_node_ref_ids   jsonb,
    app_ref_id              bigint                          not null,
    version                 bigint                          not null,
    name                    text                            not null,
    content                 jsonb                           not null,
    created_at              timestamp                       not null,
    created_by              bigint                          not null,
    updated_at              timestamp                       not null,
    updated_by              bigint                          not null
);

CREATE INDEX tree_states_at_apprefid_and_version_and_statetype ON tree_states (app_ref_id, version, state_type);
CREATE INDEX tree_states_at_parentnoderefid ON tree_states (parent_node_ref_id);
CREATE INDEX tree_states_at_childrennoderefids ON tree_states (children_node_ref_ids);
CREATE INDEX tree_states_with_gin_at_childrennoderefids ON tree_states USING gin (children_node_ref_ids);
CREATE INDEX tree_states_with_gin_at_name ON tree_states USING gin (name);
CREATE INDEX tree_states_with_fulltextgin_at_name ON tree_states USING gin (to_tsvector('english', name));

ALTER TABLE tree_states DROP CONSTRAINT IF EXISTS tree_states_displayname_constrainte,
ADD CONSTRAINT tree_states_displayname_constrainte UNIQUE (version, app_ref_id, name);

alter table tree_states owner to illa_builder;

-- kv_states, component kv_states
create table if not exists kv_states (
    id                      bigserial                       not null primary key,
    uid                     uuid default gen_random_uuid()  not null,
    team_id                 bigserial                       not null, 
    state_type              smallint                        not null,
    app_ref_id              bigint                          not null,
    version                 bigint                          not null,
    key                     text                            not null,
    value                   jsonb                           not null,
    created_at              timestamp                       not null,
    created_by              bigint                          not null,
    updated_at              timestamp                       not null,
    updated_by              bigint                          not null
);

CREATE INDEX kv_states_at_apprefid_and_version_and_statetype ON kv_states (app_ref_id, version, state_type);
CREATE INDEX kv_states_with_gin_at_key ON kv_states USING gin (key);
CREATE INDEX kv_states_with_fulltextgin_at_key ON kv_states USING gin (to_tsvector('english', key));
ALTER TABLE kv_states DROP CONSTRAINT IF EXISTS kv_states_displayname_constrainte,
ADD CONSTRAINT kv_states_displayname_constrainte UNIQUE (version, app_ref_id, key);

alter table kv_states owner to illa_builder;

-- set_states, component set_states
create table if not exists set_states (
    id                      bigserial                       not null primary key,
    uid                     uuid default gen_random_uuid()  not null,
    team_id                 bigserial                       not null, 
    state_type              smallint                        not null,
    app_ref_id              bigint                          not null,
    version                 bigint                          not null,
    value                   text                            not null,
    created_at              timestamp                       not null,
    created_by              bigint                          not null,
    updated_at              timestamp                       not null,
    updated_by              bigint                          not null
);

CREATE INDEX set_states_at_apprefid_and_version_and_statetype ON set_states (app_ref_id, version, state_type);
CREATE INDEX set_states_with_gin_at_value ON set_states USING gin (value);
CREATE INDEX set_states_with_fulltextgin_at_value ON set_states USING gin (to_tsvector('english', value));

ALTER TABLE set_states DROP CONSTRAINT IF EXISTS set_states_displayname_constrainte,
ADD CONSTRAINT set_states_displayname_constrainte UNIQUE (version, app_ref_id, value);

alter table set_states owner to illa_builder;



-- init illa_supervisor


-- init
create database illa_supervisor;
\c illa_supervisor;
create user illa_supervisor with encrypted password 'illa2022';
grant all privileges on database illa_supervisor to illa_supervisor;
CREATE EXTENSION pg_trgm;
CREATE EXTENSION btree_gin;


/**
 * TEAM Management
 *
 *
 */

-- teams
create table if not exists teams (
    id                       bigserial                               not null primary key,
    uid                      uuid         default gen_random_uuid()  not null,
    name                     varchar(255)                            not null,
    identifier               varchar(255) unique                     not null,
    icon                     varchar(255)                            not null,
    permission               jsonb                                   not null,
    created_at               timestamp                               not null,
    updated_at               timestamp                               not null,
    constraint               teams_ukey unique (id, uid)
);

CREATE INDEX teams_uid ON teams (uid);

alter table
    teams owner to illa_supervisor;

-- users
create table if not exists users (
    id                       bigserial                         not null primary key,
    uid                      uuid    default gen_random_uuid() not null,
    nickname                 varchar(15)                       not null, 
    password_digest          varchar(60)                       not null,
    email                    varchar(255)                      not null,
    avatar                   varchar(255)                      not null,
    sso_config               jsonb                             not null, 
    customization            jsonb                             not null, 
    created_at               timestamp                         not null,
    updated_at               timestamp                         not null,
    constraint               users_ukey2 unique (id, uid),
    constraint               users_email unique (email)
);

CREATE INDEX users_uid ON users (uid);
CREATE INDEX users_nickname_fulltext ON users USING gin (to_tsvector('english', nickname));
CREATE INDEX users_email_fulltext ON users USING gin (to_tsvector('english', email));

alter table
    users owner to illa_supervisor;

-- team_members
create table if not exists team_members (
    id                       bigserial                         not null primary key,
    team_id                  bigserial                         not null,
    user_id                  bigserial                         not null,  
    user_role                smallint                          not null, 
    permission               jsonb                            ,         
    status                   smallint                          not null, 
    created_at               timestamp                         not null,
    updated_at               timestamp                         not null
);

CREATE INDEX team_members_team_and_user_id ON team_members (team_id, user_id);

alter table
    team_members owner to illa_supervisor;

-- invites
create table if not exists invites (
    id                       bigserial                            not null primary key,
    uid                      uuid       default gen_random_uuid() not null, 
    category                 smallint                             not null,  
    team_id                  bigserial                            not null,
    team_member_id           bigserial                            not null,  
    email                    varchar(255)                        ,          
    email_status             boolean default false                not null,  
    user_role                smallint                             not null,  
    status                   smallint                             not null,  
    created_at               timestamp                            not null,
    updated_at               timestamp                            not null,
    constraint               invite_ukey unique (id, uid)
);

CREATE INDEX invites_uid ON invites (uid);
CREATE INDEX invites_email ON invites (email);
CREATE INDEX invites_user_role ON invites (user_role);

alter table
    invites owner to illa_supervisor;


/**
 * Role Management
 *
 *
 */

-- roles
create table if not exists roles (
    id                       bigserial                            not null primary key,
    uid                      uuid       default gen_random_uuid() not null,
    name                     varchar(255)                         not null,         
    team_id                  bigserial                            not null, 
    permissions              jsonb                                not null,
    created_at               timestamp                            not null,
    updated_at               timestamp                            not null
);
CREATE INDEX roles_id_team_id ON roles(id, team_id);
CREATE INDEX roles_name_fulltext ON roles USING gin (to_tsvector('english', name));
alter table roles owner to illa_supervisor;

-- user_role_relations
create table if not exists user_role_relations (
    id                       bigserial                            not null primary key,
    uid                      uuid       default gen_random_uuid() not null,
    team_id                  bigserial                            not null, 
    role_id                  bigserial                            not null, 
    user_id                  bigserial                            not null,
    created_at               timestamp                            not null,
    updated_at               timestamp                            not null
);
CREATE INDEX user_role_relations_team_role_user_id ON user_role_relations(team_id, role_id, user_id);
alter table user_role_relations owner to illa_supervisor;

-- unit_role_relations
create table if not exists unit_role_relations (
    id                       bigserial                            not null primary key,
    uid                      uuid       default gen_random_uuid() not null,
    team_id                  bigserial                            not null, 
    role_id                  bigserial                            not null, 
    unit_id                  bigserial                            not null,
    unit_type                smallint                             not null,
    created_at               timestamp                            not null,
    updated_at               timestamp                            not null
);
CREATE INDEX unit_role_relations_team_role_unit_id_and_unit_type ON unit_role_relations(team_id, role_id, unit_id, unit_type);
alter table unit_role_relations owner to illa_supervisor;


/**
 * DDL
 *
 *
 */

INSERT INTO teams ( 
    id, uid, name, identifier, icon, permission, created_at, updated_at
) SELECT
    0, '00000000-0000-0000-0000-000000000000', 'my-team'    , '0'  , 'https://cdn.illacloud.com/email-template/people.png', '{"allowEditorInvite": true, "allowViewerInvite": true, "inviteLinkEnabled": true, "allowEditorManageTeamMember": true, "allowViewerManageTeamMember": true}', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (
    SELECT id FROM teams WHERE id = 0
);


INSERT INTO users (
    uid, nickname, password_digest, email, avatar, sso_config, customization, created_at, updated_at
) SELECT 
    '00000000-0000-0000-0000-000000000000', 
    'root', 
    '\$2a\$10\$iVIxJRgy1K6RIV389AYg3OiMIbuDyuCIja1xrHGkCljdg/6gdmWXa'::text, 
    'root', 
    '', 
    '{"default": ""}', 
    '{"Language": "en-US", "IsSubscribed": false}', 
    CURRENT_TIMESTAMP, 
    CURRENT_TIMESTAMP
WHERE NOT EXISTS (
    SELECT nickname FROM users WHERE nickname = 'root'
);

INSERT INTO team_members (
    team_id, user_id, user_role, permission, status, created_at, updated_at   
) SELECT       
    0, root_id, 1, '{"Config": 0}', 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
FROM (select id as root_id from users where nickname='root') AS t1
WHERE NOT EXISTS (
    SELECT id FROM team_members WHERE team_id = 0 AND user_role = 1
);



EOF

echo
echo '[postgres-init.sh] init illa_builder database done.'
echo

}



if ! _is_sourced; then
	_main "$@"
fi
