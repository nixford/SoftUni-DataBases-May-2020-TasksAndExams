using System;
using System.Collections.Generic;
using System.Text;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;


namespace P01_StudentSystem.Data.Models
{
    public class Student
    {

        public Student()
        {
            this.HomeworkSubmissions = new HashSet<Homework>();
            this.StudentsCoursesEnrollments = new HashSet<StudentCourse>();
        }
        public int StudentId { get; set; }        
        
        public string Name { get; set; }
        
        public string? PhoneNumber { get; set; }
       
        public DateTime RegisteredOn { get; set; }
        
        public DateTime? Birthday { get; set; }

        public ICollection<Homework> HomeworkSubmissions { get; set; }

        public ICollection<StudentCourse> StudentsCoursesEnrollments { get; set; }


    }
}
