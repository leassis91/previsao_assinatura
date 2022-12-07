with tb_lobby AS (

    SELECT *
    FROM tb_lobby_stats_player
    WHERE dtCreatedAt < '2022-02-01'
    AND dtCreatedAt > DATE('2022-02-01', '-30 day')

),

tb_stats AS (

    SELECT idPlayer,
            count(DISTINCT idLobbyGame) as qtPartidas,
            count(DISTINCT case when qtRoundsPlayed < 16 then idLobbyGame end) as qtPartidasMenos16,
            count(DISTINCT date(dtCreatedAt)) as qtDias,
            1.0 * count(DISTINCT idLobbyGame) / count(DISTINCT date(dtCreatedAt)) as mediaPartidas,
            AVG(qtKill) AS avgQtKill,
            AVG(qtAssist) AS avgQtAssist,
            AVG(qtDeath) AS avgQtDeath,
            avg(1.0 *(qtKill + qtAssist)/qtDeath) as avgKDA,
            1.0 * sum(qtKill + qtAssist)/sum(qtDeath) as KDAgeral,
            avg(1.0 *(qtKill + qtAssist)/qtRoundsPlayed) as avgKARound,
            1.0 * sum(qtKill + qtAssist)/sum(qtRoundsPlayed) as KARoundgeral,
            AVG(qtHs) AS avgQtHs,
            AVG(1.0 * qtHS/ qtKill) as avgHsRate,
            1.0 * sum(qtHs)/sum(qtKill) as txHsGeral,
            AVG(qtBombeDefuse) AS avgQtBombeDefuse,
            AVG(qtBombePlant) AS avgQtBombePlant,
            AVG(qtTk) AS avgQtTk,
            AVG(qtTkAssist) AS avgQtTkAssist,
            AVG(qt1Kill) AS avgQt1Kill,
            AVG(qt2Kill) AS avgQt2Kill,
            AVG(qt3Kill) AS avgQt3Kill,
            AVG(qt4Kill) AS avgQt4Kill,
            sum(qt4Kill) AS sumQt4Kill,
            AVG(qt5Kill) AS avgQt5Kill,
            sum(qt5Kill) AS sumQt5Kill,
            AVG(qtPlusKill) AS avgQtPlusKill,
            AVG(qtFirstKill) AS avgQtFirstKill,
            AVG(vlDamage) AS avgVlDamage,
            AVG(1.0 * vlDamage/qtRoundsPlayed) AS avgDamageRound,
            1.0 * sum(vlDamage) / sum(qtRoundsPlayed) AS DamageRoundGeral,
            AVG(qtHits) AS avgQtHits,
            AVG(qtShots) AS avgQtShots,
            AVG(qtLastAlive) AS avgQtLastAlive,
            AVG(qtClutchWon) AS avgQtClutchWon,
            AVG(qtRoundsPlayed) AS avgQtRoundsPlayed,
            AVG(vlLevel) AS avgVlLevel,
            AVG(qtSurvived) AS avgQtSurvived,
            AVG(qtTrade) AS avgQtTrade,
            AVG(qtFlashAssist) AS avgQtFlashAssist,
            AVG(qtHitHeadshot) AS avgQtHitHeadshot,
            AVG(qtHitChest) AS avgQtHitChest,
            AVG(qtHitStomach) AS avgQtHitStomach,
            AVG(qtHitLeftAtm) AS avgQtHitLeftAtm,
            AVG(qtHitRightArm) AS avgQtHitRightArm,
            AVG(qtHitLeftLeg) AS avgQtHitLeftLeg,
            AVG(qtHitRightLeg) AS avgQtHitRightLeg,
            AVG(flWinner) AS avgFlWinner,
            count(distinct case when descMapName = 'de_mirage' then idLobbyGame end) as qtMiragePartida,
            count(distinct case when descMapName = 'de_mirage' and flWinner = 1 then idLobbyGame end) as qtMirageVitorias,
            count(distinct case when descMapName = 'de_nuke' then idLobbyGame end) as qtNukePartida,
            count(distinct case when descMapName = 'de_nuke' and flWinner = 1 then idLobbyGame end) as qtNukeVitorias,
            count(distinct case when descMapName = 'de_inferno' then idLobbyGame end) as qtInfernoPartida,
            count(distinct case when descMapName = 'de_inferno' and flWinner = 1 then idLobbyGame end) as qtInfernoVitorias,
            count(distinct case when descMapName = 'de_vertigo' then idLobbyGame end) as qtVertigoPartida,
            count(distinct case when descMapName = 'de_vertigo' and flWinner = 1 then idLobbyGame end) as qtVertigoVitorias,
            count(distinct case when descMapName = 'de_ancient' then idLobbyGame end) as qtAncientPartida,
            count(distinct case when descMapName = 'de_ancient' and flWinner = 1 then idLobbyGame end) as qtAncientVitorias,
            count(distinct case when descMapName = 'de_dust2' then idLobbyGame end) as qtDust2Partida,
            count(distinct case when descMapName = 'de_dust2' and flWinner = 1 then idLobbyGame end) as qtDust2Vitorias,
            count(distinct case when descMapName = 'de_train' then idLobbyGame end) as qtTrainPartida,
            count(distinct case when descMapName = 'de_train' and flWinner = 1 then idLobbyGame end) as qtTrainVitorias,
            count(distinct case when descMapName = 'de_overpass' then idLobbyGame end) as qtOverpassPartida,
            count(distinct case when descMapName = 'de_overpass' and flWinner = 1 then idLobbyGame end) as qtOverpassVitorias

    FROM tb_lobby

    GROUP BY idPlayer
),

tb_lvl_atual as (

    select idPlayer, 
        vlLevel

    from (
        select idLobbyGame,
            idPlayer,
            vlLevel,
            dtCreatedAt,
            row_number() over (PARTITION BY idPlayer ORDER BY dtCreatedAt DESC) as rn

        from tb_lobby
        )
    where rn =1
)

SELECT t1.*,
        t2.vlLevel as vlLevelAtual

FROM tb_stats as t1

LEFT JOIN tb_lvl_atual as t2 ON t1.idPlayer = t2.idPlayer