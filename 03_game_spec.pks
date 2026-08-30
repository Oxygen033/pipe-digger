CREATE OR REPLACE PACKAGE game_pkg AS
    PROCEDURE start_game(p_player_name IN VARCHAR2);
    PROCEDURE examine;
    PROCEDURE move(p_direction IN VARCHAR2);
    PROCEDURE encounter(p_monster_id IN NUMBER);
    PROCEDURE attack;
    PROCEDURE defend;
END game_pkg;
/