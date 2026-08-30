docker run -d --name rpg-db -p 1521:1521 -e ORACLE_PWD=YourPass123 container-registry.oracle.com/database/express:21.3.0-xe
conn system/YourPass123@host.docker.internal:1521/XEPDB1
@/home/sqlcl/01_schema.sql
@/home/sqlcl/02_init.sql
SET SERVEROUTPUT ON
@/home/sqlcl/03_game.sql