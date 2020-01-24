-----------------
-----VIEW 1------
-----------------

CREATE OR REPLACE VIEW TopBannedSongs AS
WITH sales_antijoint_playbacks AS
(
SELECT ISVN, ORDER_S FROM SALE_LINE s
                      WHERE  (NOT EXISTS ( SELECT 1
                      FROM   PLAYBACKS p WHERE  p.ISVN = s.ISVN))
),
Sol AS
(
SELECT TITLE_S as Song, SINGLES.ISVN as ISVN FROM sales_antijoint_playbacks s
                  JOIN SINGLES ON (SINGLES.ISVN = s.ISVN)
                  JOIN TRACKS ON (TRACKS.ISVN = s.ISVN)
            WHERE (ORDER_S >= SYSDATE -160
                  AND ORDER_S <= CURRENT_DATE)
                GROUP BY TITLE_S, SINGLES.ISVN ORDER BY COUNT('X') DESC
)
SELECT * FROM SOL WHERE rownum <= 3 ;

-----------------
-----VIEW 2------
-----------------

CREATE OR REPLACE VIEW top_five_week AS
WITH playbackslastweek AS
(
  SELECT ISVN FROM PLAYBACKS p
        WHERE (p.PLAYDATETIME >= SYSDATE -199)
)
SELECT * FROM
(
SELECT ARTIST
FROM DISCS JOIN playbackslastweek ON DISCS.ISVN=playbackslastweek.ISVN
GROUP BY ARTIST ORDER BY COUNT('X') DESC
)
WHERE rownum<=5;

-----------------
-----VIEW 3------
-----------------

CREATE OR REPLACE VIEW SoundBoss AS
WITH mngwithmonth AS
(
  SELECT MNG_NAME "Name", MNG_SURN1 "Surname", EXTRACT(month FROM PLAYBACKS.PLAYDATETIME) "Month" FROM DISCS NATURAL JOIN PLAYBACKS
  WHERE EXISTS (SELECT DISCS.MNG_NAME FROM DISCS)
)
SELECT "Month", "Name", "Surname"
FROM (SELECT "Month", "Name", "Surname", row_number()
    OVER (PARTITION BY "Month" ORDER BY COUNT(*) DESC) AS RN
    FROM mngwithmonth
    GROUP BY "Month", "Name", "Surname") mngwithmonth
WHERE RN = 1;

-----------------
-----VIEW 4------
-----------------

CREATE OR REPLACE VIEW WRECKHIT AS
WITH singleswithmonth AS
(
  SELECT TRACKS.TITLE_S "SingleName",
  EXTRACT(month FROM PLAYBACKS.PLAYDATETIME) "Month"
  FROM (PLAYBACKS JOIN TRACKS ON (TRACKS.ISVN = PLAYBACKS.ISVN))
  JOIN SINGLES ON (SINGLES.ISVN = PLAYBACKS.ISVN)
)
SELECT "Month", "SingleName"
FROM (SELECT "Month", "SingleName", row_number()
    OVER (PARTITION BY "Month" ORDER BY COUNT(*) ) AS RN
    FROM singleswithmonth
    GROUP BY "Month", "SingleName") singleswithmonth
WHERE RN = 1;
