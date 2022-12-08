
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
            coalesce(avg(1.0 *(qtKill + qtAssist)/coalesce(qtDeath,1)), 0) as avgKDA,
            coalesce(1.0 * sum(qtKill + qtAssist)/sum(coalesce(qtDeath, 1)), 0) as KDAgeral,
            avg(1.0 *(qtKill + qtAssist)/qtRoundsPlayed) as avgKARound,
            1.0 * sum(qtKill + qtAssist)/sum(qtRoundsPlayed) as KARoundgeral,
            AVG(qtHs) AS avgQtHs,
            coalesce(AVG(1.0 * qtHS/ qtKill), 0) as avgHsRate,
            coalesce(1.0 * sum(qtHs)/sum(qtKill), 0) as txHsGeral,
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
            coalesce(AVG(qtSurvived), 0) AS avgQtSurvived,
            AVG(qtTrade) AS avgQtTrade,
            coalesce(AVG(qtFlashAssist), 0) AS avgQtFlashAssist,
            coalesce(AVG(qtHitHeadshot), 0) AS avgQtHitHeadshot,
            coalesce(AVG(qtHitChest), 0) AS avgQtHitChest,
            coalesce(AVG(qtHitStomach), 0) AS avgQtHitStomach,
            coalesce(AVG(qtHitLeftAtm), 0) AS avgQtHitLeftArm,
            coalesce(AVG(qtHitRightArm), 0) AS avgQtHitRightArm,
            coalesce(AVG(qtHitLeftLeg), 0) AS avgQtHitLeftLeg,
            coalesce(AVG(qtHitRightLeg), 0) AS avgQtHitRightLeg,
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
        t1.idPlayer,
        t1.qtPartidas,
        t1.qtPartidasMenos16,
        t1.qtDias,
        t1.qtDiasUltimaLobby,
        t1.mediaPartidas,
        t1.avgQtKill,
        t1.avgQtAssist,
        t1.avgQtDeath,
        t1.avgKDA,
        t1.KDAgeral,
        t1.avgKARound,
        t1.KARoundgeral,
        t1.avgQtHs,
        t1.avgHsRate,
        t1.txHsGeral,
        t1.avgQtBombeDefuse,
        t1.avgQtBombePlant,
        t1.avgQtTk,
        t1.avgQtTkAssist,
        t1.avgQt1Kill,
        t1.avgQt2Kill,
        t1.avgQt3Kill,
        t1.avgQt4Kill,
        t1.sumQt4Kill,
        t1.avgQt5Kill,
        t1.sumQt5Kill,
        t1.avgQtPlusKill,
        t1.avgQtFirstKill,
        t1.avgVlDamage,
        t1.avgDamageRound,
        t1.DamageRoundGeral,
        t1.avgQtHits,
        t1.avgQtShots,
        t1.avgQtLastAlive,
        t1.avgQtClutchWon,
        t1.avgQtRoundsPlayed,
        t1.avgVlLevel,
        t1.avgQtSurvived,
        coalesce(t1.avgQtTrade, 0) as avgQtTrade,
        t1.avgQtFlashAssist,
        t1.avgQtHitHeadshot,
        t1.avgQtHitChest,
        t1.avgQtHitStomach,
        t1.avgQtHitLeftArm,
        t1.avgQtHitRightArm,
        t1.avgQtHitLeftLeg,
        t1.avgQtHitRightLeg,
        t1.avgFlWinner,
        t1.qtMiragePartida / t1.qtPartidas as propMiragePartida,
        t1.qtMirageVitorias / t1.qtMiragePartida as winRateMirage,
        t1.qtNukePartida / t1.qtPartidas as propNukePartida,
        t1.qtNukeVitorias / t1.qtNukePartida as winRateNuke,
        t1.qtInfernoPartida / t1.qtPartidas as propInfernoPartida,
        t1.qtInfernoVitorias / t1.qtInfernoPartida as winRateInferno,
        t1.qtVertigoPartida / t1.qtPartidas as propVertigoPartida,
        t1.qtVertigoVitorias / t1.qtVertigoPartida as winRateVertigo,
        t1.qtAncientPartida / t1.qtPartidas as propAncientPartida,
        t1.qtAncientVitorias / t1.qtAncientPartida as winRateAncient,
        t1.qtDust2Partida / t1.qtPartidas as propDust2Partida,
        t1.qtDust2Vitorias / t1.qtDust2Partida as winRateDust2,
        t1.qtTrainPartida / t1.qtPartidas as propTrainPartida,
        t1.qtTrainVitorias / t1.qtTrainPartida as winRateTrain,
        t1.qtOverpassPartida / t1.qtPartidas as propOverpassPartida,
        t1.qtOverpassVitorias / t1.qtOverpassPartida as winRateOverpass,
        t1.vlLevelAtual,
       coalesce(t2.qtMedalhaDistinta, 0) as qtMedalhaDistinta,
       coalesce(t2.qtMedalhaAdquiridas, 0) as qtMedalhaAdquiridas,
       coalesce(t2.qtPremium, 0) as qtPremium,
       coalesce(t2.qtPlus, 0) as qtPlus,
       coalesce(t2.AssinaturaAtiva, 0) as AssinaturaAtiva,
       t3.flFacebook,
       t3.flTwitter,
       t3.flTwitch,
       t3.descCountry,
       ((JulianDay('{date}'))- JulianDay(t3.dtBirth))/365.25 as vlIdade,
       ((JulianDay('{date}'))- JulianDay(t3.dtRegistration)) as vlDiasCadastro


FROM tb_book_lobby as t1

LEFT JOIN tb_book_medal as t2
ON t1.idPlayer = t2.idPlayer

LEFT JOIN tb_players as t3
ON t1.idPlayer = t3.idPlayer;