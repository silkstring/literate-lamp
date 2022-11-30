/*
 *	DEPARTMENTS 테이블에 총원(EMP_TOTAL) 컬럼을 추가하여 부서별 인원을 기록할 수 있도록 수정한다.
 *
 *	사원 추가(PROC_ADD_EMPLOYEE) 프로시져를 생성하여 사원을 추가할 때 다음의 기능이 동작하도록 한다.
 *		- EMPLOYEES 테이블에 사원을 추가할 수 있는 최소한의 정보를 이용하여 프로시져가 동작하게 한다.
 *		- 추가된 사원의 부서에 맞추어 DEPARTMENTS 테이블의 EMP_TOTAL 컬럼의 총원을 증가시키도록 한다.
 *
 *	사원 수정(PROC_MOD_EMPLOYEE) 프로시져와 사원 삭제(PROC_DEL_EMPLOYEE) 프로시져를 생성하여
 *	다음의 기능이 동작하도록 한다.
 *		- EMPLOYEES 테이블의 사원정보를 수정/삭제할 수 있는 최소한의 정보를 이용하여 프로시져가 동작하게 한다.
 *		- 사원의 정보를 수정할 때는 급여, 직무, 부서만 수정할 수 있게 한다.
 *		- 수정/삭제된 사원의 부서에 맞추어 DEPARTMENTS 테이블의 EMP_TOTAL 커럼의 총원을 증가 혹은 감소시키도록 한다.
 *
 *	TRIGGER로도 생성하여 만들어본다.
 *	TRIGGER로 생성하고 테스트할 때에는 직접 INSERT, UPDATE, DELETE 쿼리문을 만들어서 실행해야 한다.
 */
ALTER TABLE DEPARTMENTS ADD EMP_TOTAL NUMBER DEFAULT(0);
SELECT * FROM DEPARTMENTS;
SELECT * FROM EMPLOYEES;

UPDATE DEPARTMENTS D1
   SET EMP_TOTAL = (SELECT CNT
   					  FROM (SELECT DEPARTMENT_ID AS DEPT_ID
   								 , COUNT(*) AS CNT
   							  FROM EMPLOYEES E1
   							 GROUP BY DEPARTMENT_ID)
					 WHERE DEPT_ID = D1.DEPARTMENT_ID);

CREATE OR REPLACE PROCEDURE PROC_ADD_EMPLOYEE(
	   IN_DEPT_ID IN NUMBER
	 , IN_FNAME IN VARCHAR2
	 , IN_LNAME IN VARCHAR2
	 , IN_EMAIL IN VARCHAR2
	 , IN_JOB_ID IN VARCHAR2)
IS 
	VAR_EMP_ID NUMBER;
	VAR_SALARY NUMBER;
	EXISTS_JOB VARCHAR(30);
	EXISTS_DEPT NUMBER;
BEGIN 
	SELECT MAX(EMPLOYEE_ID) + 1 INTO VAR_EMP_ID FROM EMPLOYEES;
	SELECT JOB_ID, MIN_SALARY INTO EXISTS_JOB, VAR_SALARY FROM JOBS WHERE JOB_ID = IN_JOB_ID;
	SELECT DEPARTMENT_ID INTO EXISTS_DEPT FROM DEPARTMENTS WHERE DEPARTMENT_ID = IN_DEPT_ID;
	
	INSERT INTO EMPLOYEES(EMPLOYEE_ID, DEPARTMENT_ID, FIRST_NAME, LAST_NAME
						, EMAIL, HIRE_DATE, JOB_ID, SALARY) 
				VALUES(VAR_EMP_ID, IN_DEPT_ID, IN_FNAME, IN_LNAME
					 , IN_EMAIL, SYSDATE, IN_JOB_ID, VAR_SALARY);

	UPDATE DEPARTMENTS 
	   SET EMP_TOTAL = EMP_TOTAL + 1
	 WHERE DEPARTMENT_ID = IN_DEPT_ID;
	COMMIT;
EXCEPTION
	WHEN NO_DATA_FOUND THEN
		DBMS_OUTPUT.PUT_LINE('직무 코드 또는 부서 ID가 존재하지 않습니다.');
		ROLLBACK;
END;
SELECT * FROM USER_ERRORS;

BEGIN
	PROC_ADD_EMPLOYEE(70, '홍', '길동', 'HGILDONG', 'IT_PROG');
END;

CREATE OR REPLACE PROCEDURE PROC_MOD_EMPLOYEE(
	    IN_EMP_ID IN NUMBER
	  , IN_SALARY IN NUMBER
	  , IN_DEPT_ID IN NUMBER
	  , IN_JOB_ID IN VARCHAR2)
IS 
	VAR_DEPT_ID NUMBER;
BEGIN 
	SELECT DEPARTMENT_ID INTO VAR_DEPT_ID FROM EMPLOYEES WHERE EMPLOYEE_ID = IN_EMP_ID;

	IF VAR_DEPT_ID <> IN_DEPT_ID THEN
		UPDATE DEPARTMENTS 
		   SET EMP_TOTAL = EMP_TOTAL - 1
		 WHERE DEPARTMENT_ID = VAR_DEPT_ID;
		
		UPDATE DEPARTMENTS 
		   SET EMP_TOTAL = EMP_TOTAL + 1
		 WHERE DEPARTMENT_ID = IN_DEPT_ID;
	END IF;

	UPDATE EMPLOYEES 
	   SET SALARY = IN_SALARY
	   	 , JOB_ID = IN_JOB_ID
	   	 , DEPARTMENT_ID = IN_DEPT_ID
	 WHERE EMPLOYEE_ID = IN_EMP_ID;
	COMMIT;
EXCEPTION
	WHEN NO_DATA_FOUND THEN
		DBMS_OUTPUT.PUT_LINE('해당 사원이 존재하지 않습니다.');
		ROLLBACK;
END;
SELECT * FROM USER_ERRORS;

BEGIN
	PROC_MOD_EMPLOYEE(213, 4500, 90, 'AD_VP');
END;

CREATE OR REPLACE PROCEDURE PROC_DEL_EMPLOYEE(
	    IN_EMP_ID IN NUMBER)
IS 
	VAR_DEPT_ID NUMBER;
BEGIN 
	SELECT DEPARTMENT_ID INTO VAR_DEPT_ID FROM EMPLOYEES WHERE EMPLOYEE_ID = IN_EMP_ID;

	DELETE FROM EMPLOYEES WHERE EMPLOYEE_ID = IN_EMP_ID;

	UPDATE DEPARTMENTS 
	   SET EMP_TOTAL = EMP_TOTAL - 1
	 WHERE DEPARTMENT_ID = VAR_DEPT_ID;
	
	COMMIT;
EXCEPTION
	WHEN NO_DATA_FOUND THEN
		DBMS_OUTPUT.PUT_LINE('해당 사원이 존재하지 않습니다.');
		ROLLBACK;
END;
SELECT * FROM USER_ERRORS;

BEGIN
	PROC_DEL_EMPLOYEE(213);
END;