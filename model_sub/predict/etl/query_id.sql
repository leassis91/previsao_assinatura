with tb_max_date AS(
    
    SELECT MAX(dtRef) as date_score
    FROM tb_book_players_leassis
    WHERE idPlayer = {id_player}
)

SELECT * FROM tb_book_players_leassis
WHERE idPlayer = {id_player}
AND dtRef = (SELECT date_score FROM tb_max_date)