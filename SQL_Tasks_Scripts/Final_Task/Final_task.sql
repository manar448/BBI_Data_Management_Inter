--Qes1 How many customers have more than 2 contracts? 
SELECT COUNT(*) AS "customers have more than 2 contracts"
FROM(
SELECT CUSTOMER_ID
FROM TESTT.contract_all
GROUP BY CUSTOMER_ID
HAVING COUNT(*)>2
);

--Qes2 How many customers do not have any contracts?
SELECT COUNT(*) AS "customers do not have any contracts"
From TESTT.CUSTOMER_ALL c
WHERE NOT EXISTS(SELECT 1 FROM TESTT.contract_all t WHERE c.customer_id=t.customer_id);

--Qes3 How many customers have all their bills closed?
--this will return 3 records
SELECT COUNT(*) AS "CUSTOMERS All their bills closed"
FROM(
SELECT CUSTOMER_ID
FROM TESTT.ORDERHDR_ALL
GROUP BY CUSTOMER_ID
HAVING SUM(CASE WHEN OHOPNAMT_DOC <> 0 THEN 1 ELSE 0 END)=0
);

--Qes4 How many customers have all their bills open? 
--this will return  record
SELECT COUNT(*) AS "All bills Open"
FROM (
  SELECT CUSTOMER_ID
  FROM TESTT.ORDERHDR_ALL
  GROUP BY CUSTOMER_ID
  HAVING SUM(CASE WHEN NVL(OHOPNAMT_DOC,0) = 0 THEN 1 ELSE 0 END) = 0
);

--Qes5 How many customers do not have any bills?
SELECT COUNT(*) AS "NO BILLs"
FROM TESTT.CUSTOMER_ALL c
WHERE NOT EXISTS (
  SELECT 1 FROM ORDERHDR_ALL o WHERE o.CUSTOMER_ID = c.CUSTOMER_ID
);

--Qes6 How many customer have some of their bills open and some closed? 
--this willl return 1 record
SELECT COUNT(*) AS "Some Closed some Open"
FROM (
  SELECT CUSTOMER_ID
  FROM TESTT.ORDERHDR_ALL
  GROUP BY CUSTOMER_ID
  HAVING SUM(CASE WHEN OHOPNAMT_DOC <> 0 THEN 1 ELSE 0 END) > 0
     AND SUM(CASE WHEN NVL(OHOPNAMT_DOC,0) = 0 THEN 1 ELSE 0 END) > 0
);

--Qes7 What is the total open amount for customers who have more than 1 contracts but less than 3 contracts?
SELECT NVL(SUM(o.OHOPNAMT_DOC), 0) AS "Total open amount"
FROM TESTT.ORDERHDR_ALL o
WHERE o.CUSTOMER_ID IN (
  SELECT CUSTOMER_ID
  FROM TESTT.CONTRACT_ALL
  GROUP BY CUSTOMER_ID
  HAVING COUNT(*) > 1 AND COUNT(*) < 3
);

--Qes8 How many contracts belong to customers with open bills? 
SELECT COUNT(*) AS "contracts belong to customers with open bills"
FROM TESTT.contract_all c
WHERE c.CUSTOMER_ID IN(
 SELECT DISTINCT CUSTOMER_ID
  FROM TESTT.ORDERHDR_ALL
  WHERE OHOPNAMT_DOC <> 0
);

--Qes9 How many customers have all the bills closed with payment made before 01-Jan-2007?
SELECT COUNT(DISTINCT C.CUSTOMER_ID) AS "CUSTOMERS ALL BILLS CLOSED PAID BEFORE 2007"
FROM TESTT.CUSTOMER_ALL C
WHERE NOT EXISTS (
    SELECT 1
    FROM TESTT.ORDERHDR_ALL O
    WHERE O.CUSTOMER_ID = C.CUSTOMER_ID
    AND O.OHOPNAMT_DOC <> 0
)
AND EXISTS (
    SELECT 1
    FROM TESTT.CASHRECEIPTS_ALL CR
    WHERE CR.CUSTOMER_ID = C.CUSTOMER_ID
    AND CR.CAENTDATE < TO_DATE('01-JAN-2007', 'DD-MON-YYYY')
);

--Qes10 How many customers have only 1 contract but have more than 1000 open amount? 
SELECT COUNT(*)AS"CUSTOMERS 1 CONTRACT OVER 1000 OPEN"
FROM (
    SELECT o.CUSTOMER_ID
    FROM TESTT.ORDERHDR_ALL o
    WHERE o.OHOPNAMT_DOC <> 0
    GROUP BY o.CUSTOMER_ID
    HAVING SUM(o.OHOPNAMT_DOC) > 1000
       AND o.CUSTOMER_ID IN (
           SELECT con.CUSTOMER_ID
           FROM TESTT.CONTRACT_ALL con
           GROUP BY con.CUSTOMER_ID
           HAVING COUNT(*) = 1
       )
);

--Qes11 How many customers have bills that are paid partially i.e. bill has payment but still open?
SELECT COUNT(DISTINCT o.CUSTOMER_ID) AS "CUSTOMERS WITH PARTIALLY PAID BILLS"
FROM TESTT.ORDERHDR_ALL o
WHERE o.OHOPNAMT_DOC <> 0
  AND EXISTS (
    SELECT 1 FROM TESTT.CASHRECEIPTS_ALL d WHERE d.CUSTOMER_ID = o.CUSTOMER_ID
  );
  