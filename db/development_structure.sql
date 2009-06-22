CREATE TABLE "departments" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "name" varchar(255), "permission_id" integer, "created_at" datetime, "updated_at" datetime);
CREATE TABLE "departments_roles" ("department_id" integer, "role_id" integer);
CREATE TABLE "departments_users" ("department_id" integer, "user_id" integer, "active" boolean DEFAULT 't', "created_at" datetime, "updated_at" datetime);
CREATE TABLE "loc_groups" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "name" varchar(255), "department_id" integer, "view_perm_id" integer, "signup_perm_id" integer, "admin_perm_id" integer, "created_at" datetime, "updated_at" datetime);
CREATE TABLE "locations" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "name" varchar(255), "short_name" varchar(255), "useful_links" text, "max_staff" integer, "min_staff" integer, "priority" integer, "active" boolean, "loc_group_id" integer, "created_at" datetime, "updated_at" datetime);
CREATE TABLE "permissions" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "name" varchar(255), "created_at" datetime, "updated_at" datetime);
CREATE TABLE "permissions_roles" ("role_id" integer, "permission_id" integer);
CREATE TABLE "report_items" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "report_id" integer, "time" datetime, "content" text, "ip_address" varchar(255), "created_at" datetime, "updated_at" datetime);
CREATE TABLE "reports" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "shift_id" integer, "arrived" datetime, "departed" datetime, "created_at" datetime, "updated_at" datetime);
CREATE TABLE "roles" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "name" varchar(255), "department_id" integer, "created_at" datetime, "updated_at" datetime);
CREATE TABLE "roles_users" ("role_id" integer, "user_id" integer);
CREATE TABLE "schema_migrations" ("version" varchar(255) NOT NULL);
CREATE TABLE "shifts" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "start" datetime, "end" datetime, "user_id" integer, "location_id" integer, "scheduled" boolean DEFAULT '--- :true
', "created_at" datetime, "updated_at" datetime);
CREATE TABLE "sub_requests" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "start" datetime, "end" datetime, "mandatory_start" datetime, "mandatory_end" datetime, "potential_takers" varchar(255), "reason" varchar(255), "shift_id" integer, "created_at" datetime, "updated_at" datetime);
CREATE TABLE "substitute_sources" ("sub_request_id" integer, "user_source_id" integer, "user_source_type" varchar(255), "created_at" datetime, "updated_at" datetime);
CREATE TABLE "time_slots" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "location_id" integer, "start" datetime, "end" datetime, "created_at" datetime, "updated_at" datetime);
CREATE TABLE "users" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "login" varchar(255), "name" varchar(255), "first_name" varchar(255), "last_name" varchar(255), "email" varchar(255), "created_at" datetime, "updated_at" datetime);
CREATE UNIQUE INDEX "unique_schema_migrations" ON "schema_migrations" ("version");
INSERT INTO schema_migrations (version) VALUES ('20090522000426');

INSERT INTO schema_migrations (version) VALUES ('20090522000728');

INSERT INTO schema_migrations (version) VALUES ('20090522000757');

INSERT INTO schema_migrations (version) VALUES ('20090522000934');

INSERT INTO schema_migrations (version) VALUES ('20090522001012');

INSERT INTO schema_migrations (version) VALUES ('20090522001024');

INSERT INTO schema_migrations (version) VALUES ('20090522002133');

INSERT INTO schema_migrations (version) VALUES ('20090523041010');

INSERT INTO schema_migrations (version) VALUES ('20090603211518');

INSERT INTO schema_migrations (version) VALUES ('20090604192902');

INSERT INTO schema_migrations (version) VALUES ('20090604193111');

INSERT INTO schema_migrations (version) VALUES ('20090604193811');

INSERT INTO schema_migrations (version) VALUES ('20090604194914');

INSERT INTO schema_migrations (version) VALUES ('20090604201038');

INSERT INTO schema_migrations (version) VALUES ('20090608211657');

INSERT INTO schema_migrations (version) VALUES ('20090610201645');