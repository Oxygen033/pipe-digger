# WIP: NOT COMPLETE NOW 

A 10‑minute “text‑based quest” that I wrote (It was the only thing I could do at the time, given the circumstances, for lack of anything better).

## Launch
First you need an Oracle DB for example:
```
docker run -d --name rpg-db -p 1521:1521 -e ORACLE_PWD=YourPass123 container-registry.oracle.com/database/express:21.3.0-xe
```

Then you can either install sqlcl locally and connect via it, or install the [Docker Desktop extension](https://hub.docker.com/extensions/mochoa/sqlcl-docker-extension) (as I did).

Then connect (example for docker extension):
```
conn system/YourPass123@host.docker.internal:1521/XEPDB1
```

If you using extension you need to copy files via copy.bat.
Then run following files:
```
SET SERVEROUTPUT ON
@/home/sqlcl/01_schema.sql
@/home/sqlcl/02_init.sql
@/home/sqlcl/03_game.pks
@/home/sqlcl/04_game.pkb
```

When compiled game is ready to "play"

## Game manual
```
EXEC game_pkg.start_game('YOUR_NAME') - start game
EXEC game_pkg.move('north' | 'south' | 'west' | 'east') - move to another room
EXEC game_pkg.examine - examine the current room.
EXEC game_pkg.attack - attack the monster
EXEC game_pkg.defend - defend with chance of counterattack
EXEC game_pkg.use('ITEM NAME') - use item
EXEC game_pkg.check_inventory - check your items (for example to check item name)
```

<img width="498" height="498" alt="dance" src="https://github.com/user-attachments/assets/6083aaeb-86a3-4327-be04-bc56b06d56ac" />

