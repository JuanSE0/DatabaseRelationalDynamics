-----------------
-----QUERY 1-----
-----------------

WITH SOLOIST AS
(
  SELECT ARTISTS.NAME name FROM ARTISTS
  LEFT OUTER JOIN
  MEMBERS ON ARTISTS.NAME = MEMBERS.GROUP_NAME
  WHERE
  MEMBERS.GROUP_NAME IS NULL
),
P_ARTIST AS
(
  SELECT DISTINCT WRITER name FROM PLAYBACKS
  NATURAL JOIN TRACKS
),
NOT_BY_MYSELF AS
(
  SELECT name from SOLOIST
  MINUS
  SELECT name from P_ARTIST
)
SELECT * FROM NOT_BY_MYSELF;

-----------------
-----QUERY 2-----
-----------------

WITH GROUPS_WITH_DISCS AS
(
  SELECT artist, isvn FROM (SELECT DISTINCT group_name artist FROM MEMBERS)
  JOIN DISCS USING (artist)
),
PLAYBACK_GROUPS AS
(
  SELECT artist, playdatetime lastplayed FROM PLAYBACKS
  JOIN GROUPS_WITH_DISCS USING(isvn)
)
SELECT artist, MAX(lastplayed) FROM PLAYBACK_GROUPS GROUP BY artist;


-----------------
-----QUERY 3-----
-----------------

WITH avgbroadcaster AS
(
  SELECT station, ((sysdate-median(rel_date))/365.2422) avg FROM discs d
    JOIN playbacks p ON (p.ISVN = d.ISVN)
  GROUP BY station
),
oldbroadcaster AS
(
  SELECT station, COUNT('X') Count_old FROM discs d
    JOIN playbacks p ON (p.ISVN = d.ISVN)
  WHERE ((sysdate-rel_date)/365.2422)>30
  GROUP BY station
)
SELECT station FROM (SELECT * FROM avgbroadcaster ORDER BY avg DESC)
  WHERE rownum = 1
UNION ALL
SELECT station FROM (SELECT * FROM oldbroadcaster ORDER BY count_old DESC)
  WHERE rownum = 1;

-----------------
-----QUERY 4-----
-----------------

SELECT title_s FROM PLAYBACKS
JOIN SINGLES ON (playbacks.isvn = singles.isvn)
JOIN TRACKS ON (playbacks.isvn = tracks.isvn)
  WHERE playdatetime >= SYSDATE -110
  GROUP BY title_s ORDER BY COUNT('X') DESC;

-----------------
-----QUERY 5-----
-----------------

WITH bands AS (
  SELECT artist FROM discs WHERE artist
  IN (SELECT Group_name FROM Members WHERE (artist=group_name))
),
band_ages AS (
  SELECT artist,(MAX(rel_date)-MIN(rel_date))/365.2422 age
  FROM bands JOIN discs USING (artist) GROUP BY artist
)
SELECT * FROM (SELECT * FROM band_ages ORDER BY age DESC) WHERE rownum=1;
