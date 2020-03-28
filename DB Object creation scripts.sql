Creation of Tables and views

1.Books
CREATE TABLE BOOKS (
    ISBN10 VARCHAR2(256 BYTE) NOT NULL UNIQUE, 
	ISBN13 NUMBER(15,0) NOT NULL , 
	TITLE VARCHAR2(256 BYTE),
	COVER VARCHAR2(256),
    PUBLISHER VARCHAR2(256),
    PAGES VARCHAR2(256),
    CONSTRAINT ISBN13_PK PRIMARY KEY (ISBN13)
);

2. AUTHORS
CREATE TABLE AUTHORS (
    AUTHOR_ID  NUMBER (6,0),
    AUTHOR_NAME VARCHAR2 (50 CHAR) NOT NULL,
    CONSTRAINT AUTHORS_PK PRIMARY KEY (AUTHOR_ID) 
    
);

3. BOOKS_AUTHORS
CREATE TABLE BOOKS_AUTHORS (
    AUTHOR_ID NUMBER (6,0) NOT NULL , 
    ISBN13 NUMBER(15,0) NOT NULL ,
    CONSTRAINT AUTHORS_BK_AUTH_PK PRIMARY KEY (AUTHOR_ID,ISBN13),
    CONSTRAINT AUTHORS_BK_AUTH_FK FOREIGN KEY (AUTHOR_ID) REFERENCES AUTHORS(AUTHOR_ID),
    CONSTRAINT ISBN_BK_AUTH_FK FOREIGN KEY (ISBN13) REFERENCES BOOKS(ISBN13)
);

4.LIBRARY_BRANCH
CREATE TABLE LIBRARY_BRANCH (
    BRANCH_ID NUMBER (6,0) NOT NULL,
    BRANCH_NAME VARCHAR2 (50 CHAR) NOT NULL,
    BRANCH_ADDRESS VARCHAR2 (50 CHAR) NOT NULL ,
    CONSTRAINT BRANCH_ID_PK PRIMARY KEY (BRANCH_ID)
);

5.BOOK_COPIES
CREATE TABLE BOOK_COPIES (
    BOOK_ID NUMBER (15,0) NOT NULL,
    ISBN10 NUMBER(15,0) NOT NULL,
    BRANCH_ID NUMBER (6,0) NOT NULL ,    
    NO_OF_COPIES NUMBER(2,0),
    CONSTRAINT BK_COPIES_PK PRIMARY KEY (BOOK_ID),
	CONSTRAINT BK_CO_IS_FK FOREIGN KEY (ISBN10) REFERENCES BOOKS (ISBN10S),
	CONSTRAINT BK_LOAN_BRID_FK FOREIGN KEY (BRANCH_ID) REFERENCES LIBRARY_BRANCH (BRANCH_ID)
);

6.BORROWER
CREATE TABLE BORROWER (
    CARD_NO VARCHAR2 (20 BYTE) NOT NULL,
    SSN NUMBER (9,0) NOT NULL,
    FNAME VARCHAR2 (256 BYTE) NOT NULL, 
    LNAME VARCHAR2 (256 BYTE) NOT NULL,
    BORR_ADDRESS VARCHAR2 (256 BYTE) NOT NULL,
    PHONE NUMBER (10,0) NOT NULL,
    EMAIL VARCHAR2 (256 BYTE),
    CITY VARCHAR2 (256 BYTE),
    STATE VARCHAR2 (256 BYTE),
    CONSTRAINT BORR_PK PRIMARY KEY (CARD_NO) 
);

7.BOOK_LOANS
CREATE TABLE BOOK_LOANS (
    LOAN_ID NUMBER (5,0) NOT NULL,
    BOOK_ID NUMBER (15,0) NOT NULL,
    CARD_NO VARCHAR2 (20 BYTE) NOT NULL,
    Date_Out DATE NOT NULL ,
    Date_In DATE NOT NULL ,
    DUE_DATE DATE NOT NULL,    
    CONSTRAINT BK_LOANID_PK PRIMARY KEY (LOAN_ID),
    CONSTRAINT BK_LOAN_IDBK_FK FOREIGN KEY (BOOK_ID) REFERENCES BOOK_COPIES(BOOK_ID),
    CONSTRAINT BK_LOAN_CDNO_FK FOREIGN KEY (CARD_NO) REFERENCES BORROWER(CARD_NO)
);

8.FINES
CREATE TABLE FINES (
    LOAN_ID NUMBER (5,0) NOT NULL,
    FINE_AMT NUMBER (10,3) ,
    PAID VARCHAR2 (10 BYTE),
    CONSTRAINT FN_LOANID_PK PRIMARY KEY (LOAN_ID),
	CONSTRAINT BK_LOAN_FK FOREIGN KEY (LOAN_ID) REFERENCES BOOK_LOANS(LOAN_ID)
);

9.FINE_DETAILS
CREATE  VIEW  FINE_DETAILS (CARD_NO, FNAME, LNAME, TITLE, BRANCH_ID, LOAN_ID, FINE_AMT, PAID, DATE_IN, DATE_OUT, DUE_DATE) AS 
  select b.card_no,b.fname,b.lname,bk.title,bc.branch_id,f.loan_id,f.fine_amt,f.paid,bl.date_in,bl.date_out,bl.due_date from borrower b,books bk, fines f,book_loans bl,book_copies bc
where f.loan_id=bl.loan_id and bl.card_no=b.card_no and bl.book_id=bc.book_id and bc.isbn10=bk.isbn10;


10.MOST_BOOKS_BORROWED
CREATE  VIEW  MOST_BOOKS_BORROWED (BOOK_COUNT, MONTH) AS 
  select count(*) as book_count, t.month from (
select book_id, cast(Substr(date_out,4,3) as varchar(5)) as month from book_loans ) t
group by t.month
order by t.month desc;


11.PREFERRED_BOOKS
CREATE  VIEW  PREFERRED_BOOKS (COUNT(*), BOOK_ID, ISBN10, TITLE) AS 
  select COUNT(*),BOOK_ID,ISBN10,TITLE from (
select count(*), bl.book_id,bc.isbn10,b.title from book_loans bl
inner join book_copies bc
on bc.book_id=bl.book_id
inner join books b
on b.isbn10=bc.isbn10
group by bl.book_id,bc.isbn10,b.title
order by count(*) desc) where ROWNUM<11;


12.BRANCHWISE_BOOKS
CREATE  VIEW  BRANCHWISE_BOOKS (COUNT, BRANCH_ID, BRANCH_NAME) AS 
  select sum(no_of_copies) as count ,b.branch_id,l.branch_name from book_copies b
inner join library_branch l
on l.branch_id=b.branch_id
group by b.branch_id,l.branch_name 
order by sum(no_of_copies) desc;

------------------------------------------------------------------------------------------------------------------------------------------
Table load and Data generation

------**AUTHORS**--------
--Steps
1) Create temp table
create table BOOKS_LOAD(
ISBN10 char(10), 
ISBN13 char(13),
Title varchar2(300),
Authro varchar2(200),
Cover varchar2(200),
Publisher varchar2(200),
Pages number(5));

2) Load data into temp table - the file is tab delmited

3) Use below to generate insert statements into Authors table


--Queries
--table to take author names from file
create table test_author (
Author VARCHAR2 (200 BYTE));

--table to get distinct authors' name
create table author_test (
Author VARCHAR2 (200 BYTE));

--query to get distinct authors' name
insert into author_test (
select part_1 from (
SELECT b.*
,REGEXP_SUBSTR (author, '[^,]+', 1, 1) AS part_1
, REGEXP_SUBSTR (author, '[^,]+', 1, 2) AS part_2
, REGEXP_SUBSTR (author, '[^,]+', 1, 3) AS part_3
, REGEXP_SUBSTR (author, '[^,]+', 1, 4) AS part_4
, REGEXP_SUBSTR (author, '[^,]+', 1, 5) AS part_5
FROM test_author b) 
union
select part_2 from (
SELECT b.*
,REGEXP_SUBSTR (author, '[^,]+', 1, 1) AS part_1
, REGEXP_SUBSTR (author, '[^,]+', 1, 2) AS part_2
, REGEXP_SUBSTR (author, '[^,]+', 1, 3) AS part_3
, REGEXP_SUBSTR (author, '[^,]+', 1, 4) AS part_4
, REGEXP_SUBSTR (author, '[^,]+', 1, 5) AS part_5
FROM test_author b) where part_2 is not null
union
select part_3 from (
SELECT b.*
,REGEXP_SUBSTR (author, '[^,]+', 1, 1) AS part_1
, REGEXP_SUBSTR (author, '[^,]+', 1, 2) AS part_2
, REGEXP_SUBSTR (author, '[^,]+', 1, 3) AS part_3
, REGEXP_SUBSTR (author, '[^,]+', 1, 4) AS part_4
, REGEXP_SUBSTR (author, '[^,]+', 1, 5) AS part_5
FROM test_author b) where part_3 is not null
union
select part_4 from (
SELECT b.*
,REGEXP_SUBSTR (author, '[^,]+', 1, 1) AS part_1
, REGEXP_SUBSTR (author, '[^,]+', 1, 2) AS part_2
, REGEXP_SUBSTR (author, '[^,]+', 1, 3) AS part_3
, REGEXP_SUBSTR (author, '[^,]+', 1, 4) AS part_4
, REGEXP_SUBSTR (author, '[^,]+', 1, 5) AS part_5
FROM test_author b) where part_4 is not null
union
select part_5 from (
SELECT b.*
,REGEXP_SUBSTR (author, '[^,]+', 1, 1) AS part_1
, REGEXP_SUBSTR (author, '[^,]+', 1, 2) AS part_2
, REGEXP_SUBSTR (author, '[^,]+', 1, 3) AS part_3
, REGEXP_SUBSTR (author, '[^,]+', 1, 4) AS part_4
, REGEXP_SUBSTR (author, '[^,]+', 1, 5) AS part_5
FROM test_author b) where part_5 is not null
);

--delete irrelevant data and nulls
delete from author_test where length(author_name)<3 and  length(author_name) is null;
delete from author_test where author like '%None%' or author like '%none%'

--create sequence number for author_id
create sequence seq_author_id 
START with 1
INCREMENT BY 1;

--insert data to AUTHORS table using seq created and distinct authors name
insert into authors (author_id,author_name)  
select seq_author_id.nextval,author from (select distinct author from author_test)

insert into authors (author_id,author_name)  
select seq_author_id.nextval,author from (select distinct trim(author) as author from author_test)

----------------------------------------------------------------------------------------------------------------------------------------------------------------
------**BOOKS_AUTHORS**--------

create table books_authors_tmp1 (isbn13 number(15),author_name varchar2(100 BYTE));

create table books_authors_tmp2 (isbn13 number(15),author_name varchar2(100 BYTE),part_1 varchar2(100 BYTE),
part_2 varchar2(100 BYTE),part_3 varchar2(100 BYTE),part_4 varchar2(100 BYTE),part_5 varchar2(100 BYTE));


insert into books_authors_tmp2 (isbn13,author_name,part_1,part_2,part_3,part_4,part_5)
select isbn13,author_name,REGEXP_SUBSTR (author_name, '[^,]+', 1, 1) AS part_1, REGEXP_SUBSTR (author_name, '[^,]+', 1, 2) AS part_2,
REGEXP_SUBSTR (author_name, '[^,]+', 1, 3) AS part_3,REGEXP_SUBSTR (author_name, '[^,]+', 1, 4) AS part_4,
REGEXP_SUBSTR (author_name, '[^,]+', 1, 5) AS part_5 from books_authors_tmp1

select * from(
select isbn13,part_1 from books_authors_tmp2
union
select isbn13,part_2 from books_authors_tmp2 where part_2 is not null
union 
select isbn13,part_3 from books_authors_tmp2 where part_3 is not null
union
select isbn13,part_4 from books_authors_tmp2 where part_4 is not null
union
select isbn13,part_5 from books_authors_tmp2 where part_5 is not null) order by isbn13

create table books_authors_tmp3 (isbn13 number(15),author_name varchar2(100 BYTE))

insert into books_authors_tmp3 (isbn13,author_name)
(select isbn13,part_1 from books_authors_tmp2
union
select isbn13,part_2 from books_authors_tmp2 where part_2 is not null
union 
select isbn13,part_3 from books_authors_tmp2 where part_3 is not null
union
select isbn13,part_4 from books_authors_tmp2 where part_4 is not null
union
select isbn13,part_5 from books_authors_tmp2 where part_5 is not null)

delete from books_authors_tmp3 where length(author_name)<3

insert into books_authors (author_id,isbn13)
select author_id,b.isbn13 from books_authors_tmp3 b,authors a
where b.author_name=a.author_name

---------------------------------------------------------------------------------------------------------------------------------------------------------------
------**BOOK_COPIES**--------

Name         Null     Type       
------------ -------- ---------- 
BOOK_ID      NOT NULL NUMBER(15) - SEQUENCE
ISBN13       NOT NULL NUMBER(15) - BOOKS
BRANCH_ID    NOT NULL NUMBER(6)  - LIBRARY_BRANCH
NO_OF_COPIES          NUMBER(2)  - FILES

create sequence seq_BOOK_ID 
START with 1
INCREMENT BY 1;

create table book_copies_tmp (isbn10 varchar2(256 BYTE),branch_id number(6),no_of_copies number(2))


create sequence seq2
START with 1
INCREMENT BY 1

drop sequence seq2

delete from book_copies

insert into book_copies(book_id,isbn10,branch_id,no_of_copies)
select seq2.nextval,a.isbn10,a.branch_id,no_of_copies from book_copies_tmp a,books b,library_branch l
where a.isbn10=b.isbn10 and a.branch_id=l.branch_id

---------------------------------------------------------------------------------------------------------------------------------------------------------------
------**BOOK_LOANS**--------


create sequence date_seq 
START with 1
INCREMENT BY 1

create sequence book_seq 
START with 1
INCREMENT BY 1

create sequence card_seq 
START with 1
INCREMENT BY 1

create table random_date 
(date_out date,due_date date,date_in date,loan_id number(10,0))

create table random_tmp
(book_id number(15,0),cardno varchar2(100 BYTE),loan_id number(10,0))

create table random_books_tmp
(book_id number(15,0),loan_id number(10,0))

create table random_borrower_tmp
(card_no varchar2(100 BYTE), loan_id number(10,0))

insert into random_borrower_tmp (loan_id,card_no)
select card_seq.nextval, card_no from (select card_no from borrower where rownum<201 order by dbms_random.value) 

insert into random_books_tmp (loan_id,book_id)
select book_seq.nextval, book_id from (select book_id from book_copies where rownum<201 order by dbms_random.value) 

--Random dates insert

begin
  for l in 1..500 loop
    insert into random_date (date_out,due_date,date_in,loan_id)  
    (
    select d,d+14,TO_DATE(TRUNC(DBMS_RANDOM.VALUE(TO_CHAR(d,'J'),TO_CHAR(d+20,'J'))),'J') as date_in,date_seq.nextval
    from (SELECT TO_DATE(TRUNC(DBMS_RANDOM.VALUE(TO_CHAR(DATE '2018-01-01','J'),TO_CHAR(DATE '2018-11-30','J'))),'J') 
    as d FROM DUAL)
    );
  end loop;
end;

insert into random_books_tmp (book_id,loan_ID)
select book_id from book_copies where rownum<201 order by dbms_random.value

insert into random_tmp (book_id,card_no) 
(select book_id,cardno from random_books_tmp a, random_borrower_tmp b where a.loan_id=b.loan_id)

insert into book_loans (loan_id,book_id,card_no,date_out,date_in,due_date)
select a.loan_id,book_id,card_no,date_out,date_in,due_date from  random_tmp1 a,random_date b
where a.loan_id=b.loan_id
order by loan_id



---------------------------------------------------------------------------------------------------------------------------------------------------------------
------**FINES**--------


create sequence fines_seq
start with 1
increment by 1;

create sequence fines_seq1
start with 1
increment by 1;

create table ind_test (inc varchar2(100 BYTE))

create table fines_tmp1
(id number(10,3),ind varchar2(100 BYTE))

create table fines_tmp (loan_id number(10,0),amt number(10,0),paid varchar2(100 BYTE),id number(10,3))

create table fines_tmp1 (id number(10,3),ind varchar2(100 BYTE))



declare
indicator number;
loop_test number;
begin
    select count(*) into loop_test from book_loans where date_in>due_date;
    for l in 1..loop_test loop
        select floor(DBMS_RANDOM.VALUE(0,2)) into indicator from dual;
        IF indicator=1 THEN
            insert into fines_tmp1 (id,ind) values (fines_seq1.nextval,'Y');
        ELSE
            insert into fines_tmp1 (id,ind) values (fines_seq1.nextval,'N');
        END IF;
    end loop;
end;
)

insert into fines_tmp (loan_id,amt,id)
select loan_id,(date_in - due_date)*0.25,fines_seq.nextval from book_loans where date_in>due_date

insert into fines (loan_id,fine_amt,paid)
select loan_id,amt,ind from fines_tmp a,fines_tmp1 b
where a.id=b.id
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

APEX QUERIES

------**SEARCH RESULTS**--------

SELECT B.ISBN10,B.TITLE,A.AUTHOR_NAME,BC.NO_OF_COPIES,L.BRANCH_ID
FROM BOOKS B
INNER JOIN BOOKS_AUTHORS BA
ON BA.ISBN13=B.ISBN13
INNER JOIN AUTHORS A
ON A.AUTHOR_ID=BA.AUTHOR_ID
INNER JOIN BOOK_COPIES BC ON
BC.ISBN10=B.ISBN10
INNER JOIN LIBRARY_BRANCH L 
ON L.BRANCH_ID=BC.BRANCH_ID
where (B.ISBN10 LIKE ('%' || :BOOKS_SEARCH || '%') or B.Title LIKE ('%' || :BOOKS_SEARCH || '%') or A.AUTHOR_NAME LIKE ('%' || :BOOKS_SEARCH || '%')) and (L.BRANCH_ID= :ALL_BRANCHES) and BC.NO_OF_COPIES>0;


------**NEW BORROWER**--------

DECLARE
CHECK_SSN NUMBER;
BEGIN
    IF :APEX$ROW_STATUS= 'C' then
    select count(*) into check_ssn from borrower where ssn= :SSN;
    end if;
    if check_ssn=1 then
    return 'SSN Exists. Enter another SSN';
    end if;
end;

------**BOOK CHECKOUT**--------
declare
loan_id_no number;
date_out date;
Paid_status char;
book_id_no number;
borrowed_bk_no number;
past_due number;
today date;
bk_availability number;
begin
    select count(*) into Paid_status from book_loans a,fines b where a.loan_id=b.loan_id and paid='N' and card_no=:CARD_NO;
    if Paid_status=0 then
        select sysdate into today from dual;
        select count(*) into past_due from book_loans where card_no=:CARD_NO and today>due_date and date_in is NULL;
        if past_due>0 then
            RAISE_APPLICATION_ERROR(-20001,'Borrower ' || :CARD_NO || ' has past due books');
        else
            select count(card_no) into borrowed_bk_no from book_loans where card_no=:CARD_NO and date_in is NULL;
            if borrowed_bk_no<3 then
                select no_of_copies into bk_availability from book_copies where branch_id=:BRANCH_ID and isbn10=:ISBN10;
                if bk_availability>0 then
                    select (max(loan_id) + 1) into loan_id_no from book_loans;
                    select sysdate into date_out from dual;
                    select book_id into book_id_no from book_copies where isbn10=:ISBN10  and branch_id=:BRANCH_ID and no_of_copies>0;
                    insert into book_loans values (loan_id_no,book_id_no,:CARD_NO,date_out,NULL,date_out+14);
                    update book_copies set no_of_copies=bk_availability-1 where branch_id=:BRANCH_ID and isbn10=:ISBN10;
                else
                    RAISE_APPLICATION_ERROR(-20001,'Book ' || :ISBN10 || ' not available in the branch');
                end if;
            else
                RAISE_APPLICATION_ERROR(-20001,'Books borrowed by ' || :CARD_NO || ' is already 3');
            end if;
        end if;
    else
        RAISE_APPLICATION_ERROR(-20001,'Borrower ' || :CARD_NO || ' has unpaid fine ');   
    end if;
end;

------**FINES**--------
SELECT (FNAME || ' ' || LNAME || ' : ' || CARD_NO) AS NAME ,CARD_NO FROM BORROWER
WHERE CARD_NO IN (SELECT BL.CARD_NO FROM BOOK_LOANS BL,FINES F WHERE BL.LOAN_ID=F.LOAN_ID)
ORDER BY CARD_NO ;

select CARD_NO,
       FNAME,
       LNAME,
       TITLE,
       BRANCH_ID,
       LOAN_ID,
       FINE_AMT,
       PAID,
       DATE_IN,
       DATE_OUT,
       DUE_DATE
  from FINE_DETAILS
  where card_no=:CARD_NO1
  
  select b.card_no,b.fname,b.lname,bk.title,bc.branch_id,bl.date_in,bl.date_out,bl.due_date 
  from borrower b,books bk,book_loans bl,book_copies bc
where bl.card_no=b.card_no and bl.book_id=bc.book_id and bc.isbn10=bk.isbn10 and bl.date_in is null and sysdate> due_date
order by b.fname asc, b.lname asc;

begin
update fines set paid='Y' where loan_id=:LOAN_ID;
end;

------**BOOK CHECKIN**--------
select LOAN_ID,
       BOOK_ID,
       CARD_NO,
       DATE_OUT,
       DATE_IN,
       DUE_DATE
  from BOOK_LOANS
  where date_in is null;
  
select loan_id,book_id,card_no,date_out,due_date,date_in from book_loans 
where date_in like (sysdate);

select loan_id,loan_id*1 as loan_id1 from book_loans 
where date_in like (sysdate);


declare 
today date;
fine_check number;
fine_amount number(10,3);
fine_loan_id number(15);
begin
select count(*) into fine_check from book_loans where loan_id=:ADD_FINE and date_in>due_date;
if fine_check=1 then
    select (date_in-due_date)*0.25 into fine_amount from book_loans where loan_id=:ADD_FINE;
    insert into fines values (:ADD_FINE,fine_amount,'N');
    end if;
END;;


-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
REPORTS

Most borrowed books month wise
select count(*) as Number_of_Books, t.month as Month from (
select book_id , cast(substr(date_out,4,3) as varchar(5)) as month from book_loans ) t
group by t.month
order by t.month desc;


The branch containing the most to the least number of books
select sum(no_of_copies) as Total_books, Branch_id 
from book_copies
group by branch_id
order by Total_books desc;

Top 10 preferred books
select "COUNT(*)","BOOK_ID","ISBN10","TITLE" from (
select count(*), bl.book_id,bc.isbn10,b.title from book_loans bl
inner join   bc
on bc.book_id=bl.book_id
inner join books b
on b.isbn10=bc.isbn10
group by bl.book_id,bc.isbn10,b.title
order by count(*) desc) where ROWNUM<11;

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
