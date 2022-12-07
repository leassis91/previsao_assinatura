
with tb_lobby AS (

    SELECT *
    FROM tb_lobby_stats_player
    WHERE dtCreatedAt < '{date}'
    AND dtCreatedAt > DATE('{date}', '-30 day')

),


tb_stats AS (

    SELECT idPlayer,
            count(DISTINCT idLobbyGame) as qtPartidas,
            count(DISTINCT case when qtRoundsPlayed < 16 then idLobbyGame end) as qtPartidasMenos16,
            count(DISTINCT date(dtCreatedAt)) as qtDias,
            min(julianday('{date}') - julianday(dtCreatedAt)) as qtDiasUltimaLobby,
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
),




tb_book_lobby AS (
    SELECT t1.*,
            t2.vlLevel as vlLevelAtual
    FROM tb_stats as t1
    LEFT JOIN tb_lvl_atual as t2 
    ON t1.idPlayer = t2.idPlayer
),



tb_medals AS (
    
    SELECT * 
    FROM tb_players_medalha as t1
    left join tb_medalha as t2
    on t1.idMedal = t2.idMedal

    where dtCreatedAt < dtExpiration
    and dtCreatedAt < '{date}'
    and coalesce(dtRemove, dtExpiration) > date('{date}', '-30 days')
),




tb_book_medal as (

    SELECT idPlayer,
        SUM(DISTINCT idMedal) as qtMedalhaDistinta,
        COUNT(DISTINCT CASE WHEN dtCreatedAt > DATE('{date}', '-30 DAYS') THEN idMedal END) AS qtMedalhaAdquiridas,
        SUM(CASE WHEN descMedal = 'Membro Premium' THEN 1 ELSE 0 END) AS qtPremium,
        SUM(CASE WHEN descMedal = 'Membro Plus' THEN 1 ELSE 0 END) AS qtPlus,
        MAX(CASE WHEN descMedal IN ('Membro Premium', 'Membro Plus') 
                AND COALESCE(dtRemove, dtExpiration) >= '{date}'
                THEN 1 ELSE 0 END) AS AssinaturaAtiva

    from tb_medals
    GROUP BY idPlayer

)

INSERT INTO tb_book_players_leassis

SELECT '{date}' as dtRef,
       t1.*,
       coalesce(t2.qtMedalhaDistinta, 0) as qtMedalhaDistinta,
       coalesce(t2.qtMedalhaAdquiridas, 0) as qtMedalhaAdquiridas,
       coalesce(t2.qtPremium, 0) as qtPremium,
       coalesce(t2.qtPlus, 0) as qtPlus,
       coalesce(t2.AssinaturaAtiva, 0) as AssinaturaAtiva,
       t3.flFacebook,
       t3.flTwitter,
       t3.flTwitch,
       t3.descCountry,
       t3.dtBirth,
       ((JulianDay('{date}'))- JulianDay(t3.dtBirth))/365.25 as vlIdade,
       ((JulianDay('{date}'))- JulianDay(t3.dtRegistration)) as vlDiasCadastro


FROM tb_book_lobby as t1

LEFT JOIN tb_book_medal as t2
ON t1.idPlayer = t2.idPlayer

LEFT JOIN tb_players as t3
ON t2.idPlayer = t3.idPlayer