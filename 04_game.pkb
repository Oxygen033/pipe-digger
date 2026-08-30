CREATE OR REPLACE PACKAGE BODY game_pkg AS
    v_beer_passed NUMBER := 0;

    PROCEDURE start_game(p_player_name IN VARCHAR2) IS
        v_player_id NUMBER;
    BEGIN
        INSERT INTO players (name, current_room) VALUES (p_player_name, 1) RETURNING player_id INTO v_player_id;
        DBMS_OUTPUT.PUT_LINE('Welcome, ' || p_player_name || '!');
        DBMS_OUTPUT.PUT_LINE('You are a pipe-digger dwarf. Your job is to dig pipes in mountains to make smoke from forges go up.');
        DBMS_OUTPUT.PUT_LINE('Enough. Get to your underground town and voice your concerns to your superiors about your exhausting work.');
        DBMS_OUTPUT.PUT_LINE(' exhaust pipe  ---> =====:');
        DBMS_OUTPUT.PUT_LINE('                   =%=--##');
        DBMS_OUTPUT.PUT_LINE('           ..%@#.  =%:  *#');
        DBMS_OUTPUT.PUT_LINE('          .#@:.@*. =%:  *#     .::.   <--- mountains');
        DBMS_OUTPUT.PUT_LINE('        .*@=.   ##.=%:  *#   .=@**@=.');
        DBMS_OUTPUT.PUT_LINE('      .=@%@@*:.:=%#+%:  *# .:%@.. .%%:.');
        DBMS_OUTPUT.PUT_LINE('     =@*.  ..=*-:.*@%:  *#.%%:-%@%%@+%%.');
        DBMS_OUTPUT.PUT_LINE('  .-%#.           .*@:  *@@-.    :.   -@#.');
        DBMS_OUTPUT.PUT_LINE('..%%.              =@@.+@#              -@*.');
        DBMS_OUTPUT.PUT_LINE('#@:.               =%#@+*#               .=@');
        DBMS_OUTPUT.PUT_LINE('..                 =%:  *#                 .');
        DBMS_OUTPUT.PUT_LINE('                   =%:  *#  <--- You re here');
        DBMS_OUTPUT.PUT_LINE('                   =%:  #%');
        DBMS_OUTPUT.PUT_LINE('                   =%:  #%');
        DBMS_OUTPUT.PUT_LINE('         :%@@@@@@@@@%:  *@@@@@@=');
        DBMS_OUTPUT.PUT_LINE('         :%=                 :@=');
        DBMS_OUTPUT.PUT_LINE('         :%=                 :@=    <--- blast furnace');
        DBMS_OUTPUT.PUT_LINE('         :%=                 :@=');
        DBMS_OUTPUT.PUT_LINE('         :%=                 :@=');
        DBMS_OUTPUT.PUT_LINE('         :%=                 :@=');
        DBMS_OUTPUT.PUT_LINE('         :%+.................-@=');
        DBMS_OUTPUT.PUT_LINE('          +********************.');
    END start_game;

    PROCEDURE examine IS
        v_description VARCHAR2(500);
        v_player_id NUMBER;
        v_current_room NUMBER;
        v_item_id NUMBER;
        v_item_room NUMBER;
        v_item_name VARCHAR2(50);
        BEGIN
            SELECT player_id INTO v_player_id FROM players WHERE ROWNUM = 1;
            SELECT description INTO v_description FROM rooms WHERE room_id = (SELECT current_room FROM players WHERE player_id = v_player_id);
            DBMS_OUTPUT.PUT_LINE(v_description);
            BEGIN
            SELECT item_id, room_id, name INTO v_item_id, v_item_room, v_item_name FROM items WHERE room_id = (SELECT current_room FROM players WHERE player_id = v_player_id) AND found = 0;
            IF v_item_id IS NOT NULL THEN
                DBMS_OUTPUT.PUT_LINE('You have found a ' || v_item_name);
                UPDATE items SET found = 1 WHERE item_id = v_item_id;
            END IF;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    NULL;
            END;
        END examine;

    PROCEDURE hpcheck IS
        v_player_id NUMBER;
        v_player_hp NUMBER;
        BEGIN
            SELECT player_id, hp INTO v_player_id, v_player_hp FROM players WHERE ROWNUM = 1;
            DBMS_OUTPUT.PUT_LINE('Your HP: ' || v_player_hp);
        END hpcheck;
    
    PROCEDURE move(p_direction IN VARCHAR2) IS
        v_player_id NUMBER;
        v_current_room NUMBER;
        v_next_room NUMBER;
        v_monster_id NUMBER;
        v_monster_name VARCHAR2(50);
        v_monster_hp NUMBER;
        BEGIN
            SELECT player_id, current_room INTO v_player_id, v_current_room FROM players WHERE ROWNUM = 1;
            BEGIN
                SELECT to_room INTO v_next_room FROM room_exits WHERE from_room = v_current_room AND direction = p_direction;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    v_next_room := NULL;
            END;
            IF v_next_room IS NOT NULL THEN
                UPDATE players SET current_room = v_next_room WHERE player_id = v_player_id;
                DBMS_OUTPUT.PUT_LINE('You move ' || p_direction || '.');
                BEGIN
                    SELECT monster_id, name, hp INTO v_monster_id, v_monster_name, v_monster_hp FROM monsters WHERE room_id = v_next_room AND status = 'alive';
                    encounter(v_monster_id);
                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        NULL; 
                END;
            ELSE
                DBMS_OUTPUT.PUT_LINE('You cannot go that way.');
                RETURN;
            END IF;
            CASE v_next_room
                WHEN 9 THEN
                    IF v_beer_passed = 0 THEN
                        DBMS_OUTPUT.PUT_LINE('Redbeard guard stops you.');
                        DBMS_OUTPUT.PUT_LINE('"Not so fast, little digger! Gimme some fresh and foamy first!" - he says');
                    END IF;
                ELSE
                    NULL;
            END CASE;
        END move;
    
    PROCEDURE encounter(p_monster_id IN NUMBER) IS
        v_player_id NUMBER;
        v_current_room NUMBER;
        v_monster_id NUMBER;
        v_monster_name VARCHAR2(50);
        v_monster_hp NUMBER;
        BEGIN
            SELECT player_id, current_room INTO v_player_id, v_current_room FROM players WHERE ROWNUM = 1;
            SELECT name, hp INTO v_monster_name, v_monster_hp FROM monsters WHERE monster_id = p_monster_id;
            DBMS_OUTPUT.PUT_LINE('You encounter a ' || v_monster_name || ' with ' || v_monster_hp || ' HP!');
        END encounter;

    PROCEDURE attack IS
        v_player_id NUMBER;
        v_current_room NUMBER;
        v_monster_id NUMBER;
        v_monster_name VARCHAR2(50);
        v_monster_hp NUMBER;
        v_monster_room NUMBER;
        v_monster_status VARCHAR2(20);
        v_counterattack NUMBER;
        BEGIN
            SELECT player_id, current_room INTO v_player_id, v_current_room FROM players WHERE ROWNUM = 1;
            SELECT monster_id, name, hp, room_id, status INTO v_monster_id, v_monster_name, v_monster_hp, v_monster_room, v_monster_status FROM monsters WHERE room_id = v_current_room;
            IF v_monster_room = v_current_room AND v_monster_status = 'alive' THEN
                v_monster_hp := v_monster_hp - 10;
                UPDATE monsters SET hp = v_monster_hp WHERE monster_id = v_monster_id;
                DBMS_OUTPUT.PUT_LINE('You attack the ' || v_monster_name );
            END IF;
            v_counterattack := DBMS_RANDOM.VALUE(1, 20);
            IF v_counterattack > 10 THEN
                DBMS_OUTPUT.PUT_LINE('The ' || v_monster_name || ' counterattacks!');
                UPDATE players SET hp = hp - 5 WHERE player_id = v_player_id;
                hpcheck;
            END IF;
            -- IF v_monster_hp <= 0 THEN
                -- DBMS_OUTPUT.PUT_LINE('You have defeated the ' || v_monster_name || '!');
                -- UPDATE monsters SET status = 'dead' WHERE monster_id = p_monster_id;
            -- END IF;
        END attack;

    PROCEDURE defend IS
        v_player_id NUMBER;
        v_current_room NUMBER;
        v_monster_id NUMBER;
        v_monster_name VARCHAR2(50);
        v_monster_hp NUMBER;
        v_monster_room NUMBER;
        v_monster_status VARCHAR2(20);
        v_counterattack NUMBER;
        BEGIN
            SELECT player_id, current_room INTO v_player_id, v_current_room FROM players WHERE ROWNUM = 1;
            SELECT monster_id, name, hp, room_id, status INTO v_monster_id, v_monster_name, v_monster_hp, v_monster_room, v_monster_status FROM monsters WHERE room_id = v_current_room;
            IF v_monster_id IS NOT NULL AND v_monster_status = 'alive' THEN
                DBMS_OUTPUT.PUT_LINE('You trying to defend against the ' || v_monster_name);
                v_counterattack := DBMS_RANDOM.VALUE(1, 20);
                IF v_counterattack >= 15 THEN
                    DBMS_OUTPUT.PUT_LINE('You are proceeding counterattack to the ' || v_monster_name || '''s attack!');
                    UPDATE monsters SET hp = hp - 5 WHERE monster_id = v_monster_id;
                ELSIF v_counterattack < 8 THEN
                    DBMS_OUTPUT.PUT_LINE('You fail to defend!');
                    UPDATE players SET hp = hp - 5 WHERE player_id = v_player_id;
                    hpcheck;
                END IF;
            END IF;
        END defend;

    PROCEDURE check_inventory IS
        v_player_id NUMBER;
        v_current_room NUMBER;
        v_item_id NUMBER;
        v_item_name VARCHAR2(50);
        BEGIN
            SELECT player_id, current_room INTO v_player_id, v_current_room FROM players WHERE ROWNUM = 1;
            DBMS_OUTPUT.PUT_LINE('You check your inventory:');
            FOR rec IN (SELECT item_id, name FROM items WHERE found = 1) LOOP
                DBMS_OUTPUT.PUT_LINE('- ' || rec.name);
            END LOOP;
        END check_inventory;

    PROCEDURE use(p_item_name IN VARCHAR2) IS
        v_player_id NUMBER;
        v_current_room NUMBER;
        v_item_id NUMBER;
        v_item_name VARCHAR2(50);
        BEGIN
            SELECT player_id, current_room INTO v_player_id, v_current_room FROM players WHERE ROWNUM = 1;
            SELECT item_id, name INTO v_item_id, v_item_name FROM items WHERE name = p_item_name AND found = 1;
            IF v_item_id IS NOT NULL THEN
                CASE v_item_name
                    WHEN 'Health potion' THEN
                        UPDATE players SET hp = hp + 20 WHERE player_id = v_player_id;
                        DBMS_OUTPUT.PUT_LINE('You used a Health potion. Your HP increased by 20.');
                        hpcheck;
                    WHEN 'Pickaxe' THEN
                        IF v_current_room = 6 THEN
                            DBMS_OUTPUT.PUT_LINE('You used a pickaxe to dig through the collapsed mine. You can now move north.');
                            INSERT INTO room_exits (from_room, direction, to_room) VALUES (6, 'north', 7);
                            DELETE FROM items WHERE item_id = v_item_id; 
                        ELSE
                            DBMS_OUTPUT.PUT_LINE('There is nothing to dig here except for the new exhaust pipe but screw it.');
                        END IF;
                    WHEN 'Beer mug' THEN
                        IF v_current_room = 9 THEN
                            INSERT INTO room_exits (from_room, direction, to_room) VALUES (9, 'north', 10);
                            DBMS_OUTPUT.PUT_LINE('You gave the mug to the guard. He drinks it passionately.');
                            DBMS_OUTPUT.PUT_LINE('"Good stuff!" he says. You may pass now.');
                            v_beer_passed := 1;
                            DELETE FROM items WHERE item_id = v_item_id;
                        ELSE
                            DBMS_OUTPUT.PUT_LINE('You cannot use the beer mug here.');
                        END IF;
                    ELSE
                        DBMS_OUTPUT.PUT_LINE('Useless.');
                END CASE;
            ELSE
                DBMS_OUTPUT.PUT_LINE('You do not have that item.');
            END IF;
        END use;
END game_pkg;
/