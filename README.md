# tfmt: WCA time formatting in MySQL
A library for formatting WCA times in MySQL, so that you don't have to divide by 6000 in your head to read times over 1 minute.

## Instructions
To set up, load the functions into your database:

```bash
$ mysql -u root -p wca_development < tfmt.sql
```

To use, invoke the function `TFMT`:

```sql
SELECT
  eventId, roundTypeId, TFMT(best, eventId) AS b
FROM
  Results
WHERE
  competitionId="WC2017" AND personId="2005REYN01"
ORDER BY eventId, roundTypeId;
```

```
+---------+-------------+-----------+
| eventId | roundTypeId | b         |
+---------+-------------+-----------+
| 222     | d           | 6.63      |
| 333     | 1           | 11.32     |
| 333     | 2           | 12.18     |
| 333bf   | 1           | 1:23.13   |
| 333bf   | 2           | 2:19.40   |
| 333fm   | f           | 29        |
| 333mbf  | c           | 4/7 52:47 |
| 333oh   | 1           | 23.07     |
| 444     | 1           | 52.31     |
| 444bf   | f           | 16:42.00  |
| 555     | 1           | 1:33.66   |
| clock   | 1           | 9.71      |
| pyram   | d           | 5.13      |
| skewb   | 1           | 6.86      |
+---------+-------------+-----------+
```
