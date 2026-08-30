INSERT INTO rooms (room_id, description) VALUES (1, 'You are in dark cave. It is your workplace. There is a door to the north.');
INSERT INTO rooms (room_id, description) VALUES (2, 'You are in a workshop. It is your makeshift home and storage for tools. There is a door to the south and passage to the east.');
INSERT INTO rooms (room_id, description) VALUES (3, 'You are in a dark corridor. There is a passages to the west and south and a door to the north.');
INSERT INTO rooms (room_id, description) VALUES (4, 'You are in old trash dump. Here your previous coworkers left many tools and empty beer barrels. There is a door to the north.');
INSERT INTO rooms (room_id, description) VALUES (5, 'You are in a wet caves. Maybe even some fish live here. There is a passages to the south and east.');
INSERT INTO rooms (room_id, description) VALUES (6, 'You are in collapsed mine. Big rocks block way to the north.');
INSERT INTO rooms (room_id, description) VALUES (7, 'You are in a town border checkpoint. There is an enormously big (Seriously, why is it so big for dwarf?) steel door to the west, leading to the town.');
INSERT INTO rooms (room_id, description) VALUES (8, 'You are in a brewing room. Familiar scent of hops fills the air. There is a door to the north.');
INSERT INTO rooms (room_id, description) VALUES (9, 'You are in a town hall. There is a door to the north.');
INSERT INTO rooms (room_id, description) VALUES (10, 'You are in a mining guild HQ. Your so-called home.');

INSERT INTO room_exits (from_room, direction, to_room) VALUES (1, 'north', 2);
INSERT INTO room_exits (from_room, direction, to_room) VALUES (2, 'south', 1);
INSERT INTO room_exits (from_room, direction, to_room) VALUES (2, 'east', 3);
INSERT INTO room_exits (from_room, direction, to_room) VALUES (3, 'west', 2);
INSERT INTO room_exits (from_room, direction, to_room) VALUES (3, 'south', 4);
INSERT INTO room_exits (from_room, direction, to_room) VALUES (3, 'north', 5);
INSERT INTO room_exits (from_room, direction, to_room) VALUES (4, 'north', 3);
INSERT INTO room_exits (from_room, direction, to_room) VALUES (5, 'east', 6);
INSERT INTO room_exits (from_room, direction, to_room) VALUES (5, 'south', 3);
INSERT INTO room_exits (from_room, direction, to_room) VALUES (7, 'west', 8);
INSERT INTO room_exits (from_room, direction, to_room) VALUES (7, 'south', 6);
INSERT INTO room_exits (from_room, direction, to_room) VALUES (8, 'north', 9);
INSERT INTO room_exits (from_room, direction, to_room) VALUES (9, 'south', 8);

INSERT INTO monsters (monster_id, room_id, name, hp) VALUES (1, 2, 'Mad dwarf', 15);
INSERT INTO monsters (monster_id, room_id, name, hp) VALUES (2, 3, 'Giant spider', 30);
INSERT INTO monsters (monster_id, room_id, name, hp) VALUES (3, 7, 'Drunken guard', 20);

INSERT INTO items (item_id, room_id, name) VALUES (1, 4, 'Pickaxe');
INSERT INTO items (item_id, room_id, name) VALUES (2, 5, 'Health potion');
INSERT INTO items (item_id, room_id, name) VALUES (3, 9, 'Beer mug');

CREATE OR REPLACE TRIGGER player_hp_check
AFTER UPDATE OF hp ON players
FOR EACH ROW
BEGIN
    IF :NEW.hp <= 0 THEN
        DBMS_OUTPUT.PUT_LINE('You died.');
        DELETE FROM players WHERE player_id = :NEW.player_id;
    END IF;
END;
/

CREATE OR REPLACE TRIGGER monster_hp_check
BEFORE UPDATE OF hp ON monsters
FOR EACH ROW
BEGIN
    IF :NEW.hp <= 0 THEN
        DBMS_OUTPUT.PUT_LINE('You defeated the ' || :NEW.name || '!');
        :NEW.status := 'dead';
    END IF;
END;
/