namespace MiniORM.App
{
    using System.Linq;
    using Data;
    using Data.Entities;

    public class StartUp
    {
        public static void Main()
        {
            SoftUniDbContext db = new SoftUniDbContext(@"Server=.\SQLEXPRESS;Database=Service;Integrated Security=true");
            


            db.Employees.Add(new Employee
                ("Gosho", 
                "Inserted", 
                db.Departments.First().Id, true)
            );

            Employee employee = db.Employees.Last();
            employee.FirstName = "Modified";

            db.SaveChanges();
        }
    }
}