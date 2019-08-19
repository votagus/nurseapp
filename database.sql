CREATE USER nurseapp PASSWORD 'nurseapp';

CREATE DATABASE nurseapp OWNER nurseapp;

-- Person relation.
CREATE TABLE public.person (
    id integer GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    insurance_number text UNIQUE NOT NULL,
    name text NOT NULL,
    birthdate date NOT NULL
);

-- Person's medical record relation.
CREATE TABLE public.person_medical_check (
    id integer GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    person_insurance_number text NOT NULL REFERENCES person(insurance_number) ON DELETE CASCADE,
    blood_pressure_s integer NOT NULL,
    blood_pressure_d integer NOT NULL,
    heart_rate integer NOT NULL,
    check_date date DEFAULT now() NOT NULL
);

-- FUNCTION: public."createOrUpdatePerson"(person)

-- DROP FUNCTION public."createOrUpdatePerson"(person);

CREATE OR REPLACE FUNCTION public."createOrUpdatePerson"(
	person person)
    RETURNS person
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
AS $BODY$
DECLARE
p person; -- To store the input and the result of the query.
BEGIN
	p := person;
	
	-- Try to insert a new record or update an existing one.
	INSERT INTO person (insurance_number, name, birthdate) 
	VALUES (p.insurance_number, p.name, p.birthdate)
	ON CONFLICT (insurance_number) DO UPDATE SET name = p.name,
	birthdate = p.birthdate RETURNING * INTO p;
	RETURN p;
END;
$BODY$;

ALTER FUNCTION public."createOrUpdatePerson"(person)
    OWNER TO nurseapp;

COMMENT ON FUNCTION public."createOrUpdatePerson"(person)
    IS 'Function to create or update a person record.';


