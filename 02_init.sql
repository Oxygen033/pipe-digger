INSERT INTO rooms (room_id, description) VALUES (1, 'You are in dark cave. It is your workplace. There is a door to the north.');
INSERT INTO rooms (room_id, description) VALUES (2, 'You are in workshop. It is your makeshift home and storage for tools. There is a door to the south and passage to the east.');
INSERT INTO rooms (room_id, description) VALUES (3, 'You are in a dark corridor. There is a passage to the west and a door to the north.');

INSERT INTO room_exits (from_room, direction, to_room) VALUES (1, 'north', 2);
INSERT INTO room_exits (from_room, direction, to_room) VALUES (2, 'south', 1);
INSERT INTO room_exits (from_room, direction, to_room) VALUES (2, 'east', 3);

INSERT INTO monsters (monster_id, room_id, name, hp) VALUES (1, 2, 'Mad dwarf', 15);
INSERT INTO monsters (monster_id, room_id, name, hp) VALUES (2, 3, 'Giant spider', 30);

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