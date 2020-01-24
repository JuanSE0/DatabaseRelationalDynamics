------------------
----NO refund-----
------------------

CREATE OR REPLACE VIEW salelineview AS(
SELECT isvn, e_mail, order_s, qtty, delivery FROM SALE_LINE
WHERE dlt_date is null
);

--DROP TRIGGER No_Refund;
CREATE OR REPLACE TRIGGER No_Refund
INSTEAD OF DELETE ON salelineview
FOR EACH ROW
BEGIN
  IF :OLD.DELIVERY is not null
    THEN RAISE_APPLICATION_ERROR(-20001, 'Refund of already delivered orders is not possible');
  ELSE UPDATE SALE_LINE set dlt_date=SYSDATE
    WHERE isvn=:OLD.isvn AND e_mail=:OLD.e_mail AND qtty=:OLD.qtty AND order_s=:OLD.order_s AND delivery=:OLD.delivery;
  END IF;
END;

------------------
----EMPTY VINYL---
------------------

/*
CREATE OR REPLACE TRIGGER in_up_empty_vinyl
BEFORE INSERT OR UPDATE ON DISCS
DECLARE var NUMBER(2);
BEGIN
      SELECT DISTINCT SIDE into var FROM tracks WHERE isvn=:NEW.isvn;
  IF var < 2 THEN
    RAISE_APPLICATION_ERROR(-20001, 'DISC its empty');
  END IF;
END;
*/

------------------
----PERIODS II----
------------------

--DROP TRIGGER nu_periods_end;
CREATE OR REPLACE TRIGGER nu_periods_end
BEFORE UPDATE OF END_G ON members
BEGIN
  RAISE_APPLICATION_ERROR(-20001, 'Cannot update END_G after it has been inserted');
END;

--DROP TRIGGER nu_periods_start;
CREATE OR REPLACE TRIGGER nu_periods_start
BEFORE UPDATE OF START_G ON members
BEGIN
  RAISE_APPLICATION_ERROR(-20001, 'Cannot update START_G after it has been inserted');
END;
