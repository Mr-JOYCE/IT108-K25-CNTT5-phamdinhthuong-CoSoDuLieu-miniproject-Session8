CREATE DATABASE StudentDB;
USE StudentDB;

-- 1. Bảng Khoa
CREATE TABLE Department (
    DeptID VARCHAR(5) PRIMARY KEY,
    DeptName VARCHAR(50) NOT NULL
);

-- 2. Bảng SinhVien
CREATE TABLE Student (
    StudentID VARCHAR(6) PRIMARY KEY,
    FullName VARCHAR(50),
    Gender VARCHAR(10),
    BirthDate DATE,
    DeptID VARCHAR(5),
    FOREIGN KEY (DeptID) REFERENCES Department(DeptID)
);

-- 3. Bảng MonHoc
CREATE TABLE Course (
    CourseID VARCHAR(6) PRIMARY KEY,
    CourseName VARCHAR(50),
    Credits INT
);

-- 4. Bảng DangKy
CREATE TABLE Enrollment (
    StudentID VARCHAR(6),
    CourseID VARCHAR(6),
    Score DECIMAL(4,2), 
    PRIMARY KEY (StudentID, CourseID),
    FOREIGN KEY (StudentID) REFERENCES Student(StudentID),
    FOREIGN KEY (CourseID) REFERENCES Course(CourseID)
);

-- Chèn dữ liệu mẫu
INSERT INTO Department VALUES
('IT','Information Technology'),
('BA','Business Administration'),
('ACC','Accounting');

INSERT INTO Student VALUES
('S00001','Nguyen An','Male','2003-05-10','IT'),
('S00002','Tran Binh','Male','2003-06-15','IT'),
('S00003','Le Hoa','Female','2003-08-20','BA'),
('S00004','Pham Minh','Male','2002-12-12','ACC'),
('S00005','Vo Lan','Female','2003-03-01','IT'),
('S00006','Do Hung','Male','2002-11-11','BA'),
('S00007','Nguyen Mai','Female','2003-07-07','ACC'),
('S00008','Tran Phuc','Male','2003-09-09','IT');

INSERT INTO Course (CourseID, CourseName, Credits) VALUES
('CS101', 'C Programming', 3),
('CS102', 'Database Management', 4),
('BA201', 'Principles of Marketing', 3),
('ACC301', 'Financial Accounting', 3),
('CS103', 'Java Programming', 4),
('C00001', 'Database Systems', 4);

INSERT INTO Enrollment (StudentID, CourseID, Score) VALUES
-- Sinh viên IT học lập trình và cơ sở dữ liệu
('S00001', 'CS101', 8.5),
('S00001', 'CS102', 7.0),
('S00002', 'CS101', 9.0),
('S00002', 'CS103', 8.0),
('S00005', 'CS102', 6.5),
('S00008', 'CS101', 7.5),

-- Sinh viên BA học Marketing
('S00003', 'BA201', 8.0),
('S00006', 'BA201', 7.5),

-- Sinh viên ACC học Kế toán
('S00004', 'ACC301', 9.5),
('S00007', 'ACC301', 8.0),

-- Dang ky mon Database Systems (C00001) cho sinh vien khoa IT
('S00001', 'C00001', 8.0),
('S00002', 'C00001', 9.5),
('S00005', 'C00001', 7.0),
('S00008', 'C00001', 9.5);


-- Phan A:

-- Cau 1:
CREATE OR REPLACE VIEW ViewStudentBasic AS
	SELECT s.StudentID, s.FullName, d.DeptName
    FROM Student s
    INNER JOIN Department d ON d.DeptID = s.DeptID;

-- Truy van toan bo du lieu tu View
SELECT * FROM ViewStudentBasic;

-- Cau 2:
CREATE INDEX idxFullName ON Student(FullName);

-- Cau 3:

DROP PROCEDURE IF EXISTS GetStudentsIT;
DELIMITER //

CREATE PROCEDURE GetStudentsIT()
BEGIN
	SELECT s.*, d.DeptName
    FROM Student s
    INNER JOIN Department d ON d.DeptID = s.DeptID
    WHERE d.DeptName = 'Information Technology';
END //

DELIMITER ;

-- Kiem tra thu tuc
CALL GetStudentsIT();


-- PHAN B – KHA

-- Cau 4a
CREATE OR REPLACE VIEW ViewStudentCountByDept AS
SELECT d.DeptName, COUNT(s.StudentID) AS TotalStudents
FROM Student s
INNER JOIN Department d ON d.DeptID = s.DeptID
GROUP BY d.DeptID, d.DeptName;

-- Cau 4b: Khoa co nhieu sinh vien nhat (bao gom truong hop hoa)
SELECT DeptName, TotalStudents
FROM ViewStudentCountByDept
WHERE TotalStudents = (SELECT MAX(TotalStudents) FROM ViewStudentCountByDept);

-- Cau 5a
DROP PROCEDURE IF EXISTS GetTopScoreStudent;
DELIMITER //

CREATE PROCEDURE GetTopScoreStudent(IN varCourseID VARCHAR(6))
BEGIN
	SELECT s.StudentID, s.FullName, d.DeptName, e.CourseID, c.CourseName, e.Score
    FROM Enrollment e
    INNER JOIN Student s ON s.StudentID = e.StudentID
    INNER JOIN Department d ON d.DeptID = s.DeptID
    INNER JOIN Course c ON c.CourseID = e.CourseID
    WHERE e.CourseID = varCourseID
      AND e.Score = (
          SELECT MAX(e2.Score)
          FROM Enrollment e2
          WHERE e2.CourseID = varCourseID
      );
END //

DELIMITER ;

-- Cau 5b: Sinh vien diem cao nhat mon Database Systems (C00001)
CALL GetTopScoreStudent('C00001');


-- ========== PHAN C – GIOI ==========

-- Cau 6a
CREATE OR REPLACE VIEW ViewITEnrollmentDB AS
SELECT e.StudentID, e.CourseID, e.Score
FROM Enrollment e
INNER JOIN Student s ON s.StudentID = e.StudentID
WHERE s.DeptID = 'IT' AND e.CourseID = 'C00001'
WITH CHECK OPTION;

-- Cau 6b
DROP PROCEDURE IF EXISTS UpdateScoreITDB;
DELIMITER //

CREATE PROCEDURE UpdateScoreITDB(
    IN varStudentID VARCHAR(6),
    INOUT inoutNewScore DECIMAL(4,2)
)
BEGIN
	IF inoutNewScore > 10 THEN
		SET inoutNewScore = 10;
	END IF;

	UPDATE ViewITEnrollmentDB
    SET Score = inoutNewScore
    WHERE StudentID = varStudentID;
END //

DELIMITER ;

-- Cau 6c: Kiem tra (bien session @newScore)
SET @newScore := 11.50;

CALL UpdateScoreITDB('S00001', @newScore);

-- Hien thi lai diem sau INOUT (da cat neu > 10)
SELECT @newScore AS ScoreSauCapNhat;

-- Kiem tra du lieu trong View
SELECT * FROM ViewITEnrollmentDB;

