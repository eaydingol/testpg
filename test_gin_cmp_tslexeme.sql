drop table if exists cmpright;
create table cmpright (val text);
INSERT INTO cmpright (val) VALUES ('<4');

drop table if exists cmpleft;
create table cmpleft (num numeric, val text);

INSERT INTO cmpleft (num, val) VALUES (19.53, '-t'), (-85.69, '&HAo'), (-23.8, '=857N'), (73.99, '{MI'), (44.94, 'Y^.E'), (-60.66, '+'), (23.41, ':A'), (-21.99, ']'), (-41.95, NULL), (0.0, 'M>'), (55.18, 'R'), (-5.4, '=');

select
  val as left_cmp,
  (select val from cmpright limit 1) as right_cmp,
  (pg_catalog.gin_cmp_tslexeme(val, (select val from cmpright limit 1))) as cmp_res
from 
  cmpleft
order by num desc;


drop table if exists sequential_call_results;
create table sequential_call_results (left_cmp text, right_cmp text, cmp_res int);
DO $$
DECLARE
  i INTEGER;
  result RECORD;
BEGIN
    FOR i IN 0..(SELECT COUNT(*) FROM cmpleft) - 1 LOOP 
    INSERT INTO sequential_call_results (left_cmp, right_cmp, cmp_res)
    VALUES (
      (SELECT val FROM cmpleft ORDER BY num DESC LIMIT 1 OFFSET i),
      (SELECT val FROM cmpright LIMIT 1),
      (pg_catalog.gin_cmp_tslexeme((SELECT val FROM cmpleft ORDER BY num DESC LIMIT 1 OFFSET i), (SELECT val FROM cmpright LIMIT 1)))
    );
    ---RAISE NOTICE 'Offset: %, Result: %', i, result;
  END LOOP;
END $$;

SELECT * FROM sequential_call_results;
