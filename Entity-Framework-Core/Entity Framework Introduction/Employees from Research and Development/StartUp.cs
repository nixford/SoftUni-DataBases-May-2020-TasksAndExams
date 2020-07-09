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

            //Console.WriteLine(GetEmployeesFullInformation(context));

            //Console.WriteLine(GetEmployeesWithSalaryOver50000(context));

            Console.WriteLine(GetEmployeesFromResearchAndDevelopment(context));
        }

        //public static string GetEmployeesFullInformation(SoftUniContext context)
        //{
        //    StringBuilder sb = new StringBuilder();

        //    var emplyees = context.Employees
        //        .OrderBy(e => e.EmployeeId)
        //        .Select(e => new
        //    {
        //        e.FirstName,
        //        e.LastName,
        //        e.MiddleName,
        //        e.JobTitle,
        //        e.Salary,
        //    }).ToList();

        //    foreach (var employee in emplyees)
        //    {
        //        sb.AppendLine($"{employee.FirstName} " +
        //            $"{employee.LastName} " +
        //            $"{employee.MiddleName} " +
        //            $"{employee.JobTitle} " +
        //            $"{employee.Salary:f2}");
        //    }
        //    return sb.ToString().TrimEnd();
        //}

        //public static string GetEmployeesWithSalaryOver50000(SoftUniContext context)
        //{
        //    StringBuilder sb = new StringBuilder();

        //    var emplyees = context.Employees
        //        .Where(e => e.Salary > 50000)
        //        .OrderBy(e => e.FirstName)
        //        .Select(e => new
        //        {
        //            e.FirstName,
        //            e.Salary,
        //        }).ToList();

        //    foreach (var employee in emplyees)
        //    {
        //        sb.AppendLine
        //            ($"{employee.FirstName} - {employee.Salary:f2}");
        //    }
        //    return sb.ToString().TrimEnd();
        //}


        public static string GetEmployeesFromResearchAndDevelopment(SoftUniContext context)
        {
            StringBuilder sb = new StringBuilder();

            var employees = context.Employees
                .Where(e => e.Department.Name == "Research and Development")                
                .Select(e => new 
                { 
                    e.FirstName,
                    e.LastName,
                    e.Department.Name,
                    e.Salary,
                })
                .OrderBy(e => e.Salary)
                .ThenByDescending(e => e.FirstName)
                .ToList();

            foreach (var employee in employees)
            {
                sb.AppendLine
                    ($"{employee.FirstName} " +
                    $"{employee.LastName} from " +
                    $"{employee.Name} - ${employee.Salary:f2}");
            }
            return sb.ToString().TrimEnd();
        }
    }
}
