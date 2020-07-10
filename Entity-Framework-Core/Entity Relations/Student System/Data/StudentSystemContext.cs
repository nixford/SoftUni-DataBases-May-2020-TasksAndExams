using Microsoft.EntityFrameworkCore;
using P01_StudentSystem.Data.Models;
using System;
using System.Collections.Generic;
using System.Text;

namespace P01_StudentSystem.Data
{
    public class StudentSystemContext : DbContext
    {
        public StudentSystemContext()
        {

        }

        public StudentSystemContext(DbContextOptions options)
            : base(options)
        {

        }

        public virtual DbSet<Student> Students { get; set; }
        public virtual DbSet<Course> Courses { get; set; }
        public virtual DbSet<Resource> Resources { get; set; }
        public virtual DbSet<Homework> HomeworkSubmissions { get; set; }
        public virtual DbSet<StudentCourse> StudentCourses { get; set; }

        protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
        {
            if (!optionsBuilder.IsConfigured)
            {
#warning To protect potentially sensitive information in your connection string, you should move it out of source code. See http://go.microsoft.com/fwlink/?LinkId=723263 for guidance on storing connection strings.
                optionsBuilder.UseSqlServer("Server=.\\SQLEXPRESS;Database=StudentSystem;Integrated Security=True;");
            }
        }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<Course>(entity =>
            {
                entity
                    .HasKey(c => c.CourseId);

                entity
                    .Property(n => n.Name)
                    .IsRequired()                    
                    .IsUnicode()
                    .HasMaxLength(80);

                entity
                    .Property(d => d.Description)
                    .IsRequired(false)
                    .IsUnicode();

                entity
                    .Property(s => s.StartDate)
                    .IsRequired();

                entity
                    .Property(e => e.EndDate)
                    .IsRequired();

                entity
                    .Property(p => p.Price)
                    .IsRequired();
            });

            modelBuilder.Entity<Homework>(entity =>
            {
                entity
                    .HasKey(x => x.HomeworkId);

                entity
                    .Property(x => x.Content)
                    .IsUnicode(false);

                entity
                    .Property(x => x.ContentType)
                    .IsRequired();

                entity
                    .Property(x => x.ContentType)
                    .IsRequired();

                entity
                    .HasOne(x => x.Student)
                    .WithMany(x => x.HomeworkSubmissions)
                    .HasForeignKey(x => x.StudentId);

                entity
                    .HasOne(x => x.Course)
                    .WithMany(x => x.HomeworkSubmissions)
                    .HasForeignKey(x => x.CourseId);
                    
            });

            modelBuilder.Entity<Resource > (entity => 
            {
                entity
                    .HasKey(x => x.ResourceId);

                entity
                    .Property(x => x.Name)
                    .IsUnicode()
                    .HasMaxLength(50);

                entity
                    .Property(x => x.Url)
                    .IsUnicode(false);

                entity
                    .Property(x => x.ResourceType)
                    .IsRequired();

                entity
                    .HasOne(x => x.Course)
                    .WithMany(x => x.Resources)
                    .HasForeignKey(x => x.CourseId);
            });

            modelBuilder.Entity<Student>(entity => 
            {
                entity
                    .HasKey(x => x.StudentId);

                entity
                    .Property(x => x.Name)
                    .IsUnicode()
                    .HasMaxLength(100);

                entity
                    .Property(x => x.PhoneNumber)
                    .IsRequired(false)
                    .IsUnicode(false)
                    .HasDefaultValueSql("CHAR(10)");

                entity
                    .Property(x => x.RegisteredOn)
                    .IsRequired();

                entity
                    .Property(x => x.Birthday)
                    .IsRequired(false);
            });

            modelBuilder.Entity<StudentCourse>(entity =>
            {
                entity
                    .HasKey(x => new { x.StudentId, x.CourseId });

                entity
                    .HasOne(s => s.Student)
                    .WithMany(s => s.StudentsCoursesEnrollments)
                    .HasForeignKey(x => x.StudentId);

                entity
                    .HasOne(s => s.Course)
                    .WithMany(s => s.StudentsEnrolled)
                    .HasForeignKey(x => x.CourseId);
            });
        }

    }
}
