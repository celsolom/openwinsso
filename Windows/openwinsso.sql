--
-- PostgreSQL database dump
--

-- Dumped from database version 9.5.3
-- Dumped by pg_dump version 9.5.1

-- Started on 2016-07-07 11:25:43

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 2141 (class 1262 OID 16384)
-- Name: adsso; Type: DATABASE; Schema: -; Owner: celsol
--

CREATE DATABASE adsso WITH TEMPLATE = template0 ENCODING = 'WIN1252' LC_COLLATE = 'Portuguese_Brazil.1252' LC_CTYPE = 'Portuguese_Brazil.1252';


ALTER DATABASE adsso OWNER TO celsol;

\connect adsso

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 1 (class 3079 OID 12355)
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- TOC entry 2144 (class 0 OID 0)
-- Dependencies: 1
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- TOC entry 181 (class 1259 OID 16390)
-- Name: groups; Type: TABLE; Schema: public; Owner: celsol
--

CREATE TABLE groups (
    groupname character varying(45) NOT NULL
);


ALTER TABLE groups OWNER TO celsol;

--
-- TOC entry 182 (class 1259 OID 16395)
-- Name: users_groups; Type: TABLE; Schema: public; Owner: celsol
--

CREATE TABLE users_groups (
    login character(20) NOT NULL,
    groupname character varying(45) NOT NULL
);


ALTER TABLE users_groups OWNER TO celsol;

--
-- TOC entry 184 (class 1259 OID 16846)
-- Name: users_logged; Type: TABLE; Schema: public; Owner: celsol
--

CREATE TABLE users_logged (
    login character varying(20) NOT NULL,
    ip inet NOT NULL,
    date timestamp with time zone
);


ALTER TABLE users_logged OWNER TO celsol;

--
-- TOC entry 186 (class 1259 OID 16862)
-- Name: logged_groups; Type: VIEW; Schema: public; Owner: celsol
--

CREATE VIEW logged_groups AS
 SELECT login,
    users_logged.ip,
    users_logged.date,
    users_groups.groupname
   FROM (users_logged
     JOIN users_groups USING (login));


ALTER TABLE logged_groups OWNER TO celsol;

--
-- TOC entry 188 (class 1259 OID 16877)
-- Name: users; Type: VIEW; Schema: public; Owner: celsol
--

CREATE VIEW users AS
 SELECT DISTINCT users_groups.login
   FROM users_groups
  ORDER BY users_groups.login;


ALTER TABLE users OWNER TO celsol;

--
-- TOC entry 185 (class 1259 OID 16858)
-- Name: users_expired; Type: VIEW; Schema: public; Owner: celsol
--

CREATE VIEW users_expired AS
 SELECT users_logged.login,
    users_logged.ip,
    users_logged.date
   FROM users_logged
  WHERE (age(now(), users_logged.date) > '00:05:00'::interval);


ALTER TABLE users_expired OWNER TO celsol;

--
-- TOC entry 183 (class 1259 OID 16809)
-- Name: users_groups_update; Type: TABLE; Schema: public; Owner: celsol
--

CREATE TABLE users_groups_update (
    login character(20) NOT NULL,
    groupname character varying(45) NOT NULL
);


ALTER TABLE users_groups_update OWNER TO celsol;

--
-- TOC entry 187 (class 1259 OID 16866)
-- Name: users_valid; Type: VIEW; Schema: public; Owner: celsol
--

CREATE VIEW users_valid AS
 SELECT users_logged.login,
    users_logged.ip,
    users_logged.date
   FROM users_logged
  WHERE (age(now(), users_logged.date) < '00:05:00'::interval);


ALTER TABLE users_valid OWNER TO celsol;

--
-- TOC entry 2009 (class 2606 OID 16432)
-- Name: groups_pkey; Type: CONSTRAINT; Schema: public; Owner: celsol
--

ALTER TABLE ONLY groups
    ADD CONSTRAINT groups_pkey PRIMARY KEY (groupname);


--
-- TOC entry 2012 (class 2606 OID 16798)
-- Name: users_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: celsol
--

ALTER TABLE ONLY users_groups
    ADD CONSTRAINT users_groups_pkey PRIMARY KEY (login, groupname);


--
-- TOC entry 2014 (class 2606 OID 16813)
-- Name: users_groups_update_pkey; Type: CONSTRAINT; Schema: public; Owner: celsol
--

ALTER TABLE ONLY users_groups_update
    ADD CONSTRAINT users_groups_update_pkey PRIMARY KEY (login, groupname);


--
-- TOC entry 2016 (class 2606 OID 16853)
-- Name: users_logged_pkey; Type: CONSTRAINT; Schema: public; Owner: celsol
--

ALTER TABLE ONLY users_logged
    ADD CONSTRAINT users_logged_pkey PRIMARY KEY (login, ip);


--
-- TOC entry 2010 (class 1259 OID 16443)
-- Name: fki_groups_fkey; Type: INDEX; Schema: public; Owner: celsol
--

CREATE INDEX fki_groups_fkey ON users_groups USING btree (groupname);


--
-- TOC entry 2017 (class 2606 OID 16804)
-- Name: users_groups_groupname_fkey; Type: FK CONSTRAINT; Schema: public; Owner: celsol
--

ALTER TABLE ONLY users_groups
    ADD CONSTRAINT users_groups_groupname_fkey FOREIGN KEY (groupname) REFERENCES groups(groupname);


--
-- TOC entry 2018 (class 2606 OID 16814)
-- Name: users_groups_update_groupname_fkey; Type: FK CONSTRAINT; Schema: public; Owner: celsol
--

ALTER TABLE ONLY users_groups_update
    ADD CONSTRAINT users_groups_update_groupname_fkey FOREIGN KEY (groupname) REFERENCES groups(groupname);


--
-- TOC entry 2143 (class 0 OID 0)
-- Dependencies: 6
-- Name: public; Type: ACL; Schema: -; Owner: celsol
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM celsol;
GRANT ALL ON SCHEMA public TO celsol;
GRANT ALL ON SCHEMA public TO PUBLIC;


-- Completed on 2016-07-07 11:25:44

--
-- PostgreSQL database dump complete
--

