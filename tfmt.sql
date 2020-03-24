DELIMITER $$

DROP FUNCTION IF EXISTS __tfmt__FMSingle$$
CREATE FUNCTION __tfmt__FMSingle (rawTime int)
RETURNS varchar(50) DETERMINISTIC
BEGIN
  RETURN CONCAT(rawTime);
END$$

DROP FUNCTION IF EXISTS __tfmt__FMAverage$$
CREATE FUNCTION __tfmt__FMAverage (rawTime int)
RETURNS varchar(50) DETERMINISTIC
BEGIN
  RETURN CONCAT(rawTime DIV 100, ".", LPAD(CONCAT(rawTime % 100), 2, "0"));
END$$

DROP FUNCTION IF EXISTS __tfmt__normalTime$$
CREATE FUNCTION __tfmt__normalTime (rawTime int)
RETURNS varchar(40) DETERMINISTIC
BEGIN
  DECLARE ret CHAR(40);
  SET ret = CONCAT((rawTime DIV 100) % 60, ".", LPAD(CONCAT(rawTime % 100), 2, "0"));
  SET ret = IF(rawTime >= 6000, CONCAT((rawTime DIV 6000) % 60, ":", LPAD(ret, 5, "0")), ret);
  SET ret = IF(rawTime >= 360000, CONCAT(rawTime DIV 360000, ":", LPAD(ret, 8, "0")), ret);
  RETURN ret;
END$$

DROP FUNCTION IF EXISTS __tfmt__MBimpl$$
CREATE FUNCTION __tfmt__MBimpl (solved int, attempted int, timeInSeconds int)
RETURNS varchar(50) DETERMINISTIC
BEGIN
  DECLARE timeString CHAR(40);
  SET timeString = __tfmt__normalTime(timeInSeconds * 100);
  RETURN CONCAT(solved, "/", attempted, " ", SUBSTRING(timeString, 1, LENGTH(timeString) - 3));
END$$
        
DROP FUNCTION IF EXISTS __tfmt__MBF$$
CREATE FUNCTION __tfmt__MBF (rawTime int)
RETURNS varchar(50) DETERMINISTIC
BEGIN
  DECLARE difference INT;
  DECLARE timeInSeconds INT;
  DECLARE missed INT;
  SET difference = 99 - (rawTime DIV 10000000);
  SET timeInSeconds = (rawTime % 10000000) DIV 100;
  SET missed = rawTime % 100;
  RETURN __tfmt__MBimpl (difference + missed, difference + missed + missed, timeInSeconds);
END$$

DROP FUNCTION IF EXISTS __tfmt__MBO$$
CREATE FUNCTION __tfmt__MBO (rawTime int)
RETURNS varchar(50) DETERMINISTIC
BEGIN
  DECLARE solved INT;
  DECLARE attempted INT;
  DECLARE timeInSeconds INT;
  SET solved = 99 - (rawTime DIV 10000000) % 100;
  SET attempted = (rawTime DIV 100000) % 100;
  SET timeInSeconds = (rawTime % 100000);
  RETURN __tfmt__MBimpl (solved, attempted, timeInSeconds);
END$$

DROP FUNCTION IF EXISTS tfmt$$
CREATE FUNCTION tfmt (rawTime int, eventId varchar(50))
RETURNS varchar(50) DETERMINISTIC
BEGIN
  RETURN CASE
    WHEN rawTime = -1 THEN
      "DNF"
    WHEN rawTime = -2 THEN
      "DNS"
    WHEN rawTime = 0 THEN
      ""
    WHEN eventId = "333fm" AND rawTime < 1000 THEN
      __tfmt__FMSingle(rawTime)
    WHEN eventId = "333fm" AND rawTime >= 1000 THEN
      __tfmt__FMAverage(rawTime)
    WHEN eventId = "333mbf" THEN
      __tfmt__MBF(rawTime)
    WHEN eventId = "333mbo" THEN
      __tfmt__MBO(rawTime)
    ELSE
      __tfmt__normalTime(rawTime)
    END;
END$$

DELIMITER ;
