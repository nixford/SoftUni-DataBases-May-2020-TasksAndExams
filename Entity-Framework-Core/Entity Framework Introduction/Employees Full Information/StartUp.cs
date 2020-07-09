using SoftUni.Data;
using SoftUni.Models;
using System;
using System.Linq;
using System.Text;

namespace SoftUni
{
    public class StartUp
    {
        public static void Main(string[] args)
        {
            SoftUniContext context = new SoftUniContext();

            Console.WriteLine(GetEmployeesFullInformation(context));
        }

        public static string GetEmployeesFullInformation(SoftUniContext context)
        {
            StringBuilder sb = new StringBuilder();

            var emplyees = context.Employees
                .OrderBy(e => e.EmployeeId)
                .Select(e => new
            {
                e.FirstName,
                e.LastName,
                e.MiddleName,
                e.JobTitle,
                e.Salary,
            }).ToList();

            foreach (var employee in emplyees)
            {
                sb.AppendLine($"{employee.FirstName} " +
                    $"{employee.LastName} " +
                    $"{employee.MiddleName} " +
                    $"{employee.JobTitle} " +
                    $"{employee.Salary:f2}");
            }
            return sb.ToString().TrimEnd();
        }
    }
}
