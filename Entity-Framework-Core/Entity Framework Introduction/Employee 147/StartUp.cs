using SoftUni.Data;
using SoftUni.Models;
using System;
using System.Globalization;
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

            //Console.WriteLine(GetEmployeesFromResearchAndDevelopment(context));

            //Console.WriteLine(AddNewAddressToEmployee(context));

            //Console.WriteLine(GetEmployeesInPeriod(context));

            //Console.WriteLine(GetAddressesByTown(context));

            Console.WriteLine(GetEmployee147(context));
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


        //public static string AddNewAddressToEmployee(SoftUniContext context)
        //{
        //    StringBuilder sb = new StringBuilder();

        //    Address newAddres = new Address()
        //    {
        //        AddressText = "Vitoshka 15",
        //        TownId = 4
        //    };

        //    Employee employeeNakov = context.Employees
        //        .First(e => e.LastName == "Nakov");

        //    employeeNakov.Address = newAddres;

        //    context.SaveChanges();

        //    var employees = context
        //        .Addresses
        //        .OrderByDescending(e => e.AddressId)
        //        .Take(10);

        //    foreach (var employee in employees)
        //    {
        //        sb.AppendLine
        //            ($"{employee.AddressText}");
        //    }
        //    return sb.ToString().TrimEnd();
        //}


        public static string GetEmployeesInPeriod(SoftUniContext context)
        {
            StringBuilder sb = new StringBuilder();

            var employees = context.Employees
                .Where(e => e.EmployeesProjects
                    .Any(ep => ep.Project.StartDate.Year >= 2001 &&
                               ep.Project.StartDate.Year <= 2003))
                .Take(10)
                .Select(e => new
                {
                    e.FirstName,
                    e.LastName,
                    ManagerFirstName = e.Manager.FirstName,
                    ManagerLastName = e.Manager.LastName,
                    Projects = e.EmployeesProjects
                        .Select(ep => new
                        {
                            PrjectName = ep.Project.Name,
                            StartDate = ep.Project
                                .StartDate
                                .ToString("M/d/yyyy h:mm:ss tt",
                                CultureInfo.InvariantCulture),
                            EndDate = ep.Project.EndDate.HasValue ?
                                ep.Project
                                    .EndDate
                                    .Value.ToString("M/d/yyyy h:mm:ss tt",
                                CultureInfo.InvariantCulture) : "not finished"
                        }).ToList(),
                }).ToList(); 

            foreach (var employee in employees)
            {
                sb.AppendLine($"{employee.FirstName} {employee.LastName} - Manager: " +
                    $"{employee.ManagerFirstName} {employee.ManagerLastName}");

                foreach (var project in employee.Projects)
                {
                    sb
                        .AppendLine($"--{project.PrjectName} - {project.StartDate} - {project.EndDate}");
                }
            }
            return sb.ToString().TrimEnd();
        }


        public static string GetAddressesByTown(SoftUniContext context)
        {
            StringBuilder sb = new StringBuilder();

            var addresses = context
                .Addresses                
                .Select(a => new
                {
                    AddressText = a.AddressText,
                    TownName = a.Town.Name,
                    EmployeesCount = a.Employees.Count
                })
                .OrderByDescending(e => e.EmployeesCount)
                .ThenBy(e => e.TownName)
                .ThenBy(e => e.AddressText)
                .Take(10)
                .ToList();

            foreach (var a in addresses)
            {
                sb
                   .AppendLine($"{a.AddressText}, {a.TownName} - {a.EmployeesCount} employees");
            }

            return sb.ToString().TrimEnd();
        }


        public static string GetEmployee147(SoftUniContext context)
        {
            StringBuilder sb = new StringBuilder();

            var employee147 = context
                .Employees
                .Where(e => e.EmployeeId == 147)
                .Select(e => new
                {
                    FirstName = e.FirstName,
                    LastName = e.LastName,
                    JobTitle = e.JobTitle,
                    Projects = e.EmployeesProjects
                                    .Select(ep => ep.Project.Name)
                                    .OrderBy(pn => pn)
                                    .ToList()
                })
                .Single();

            sb
                .AppendLine($"{employee147.FirstName} " +
                $"{employee147.LastName} - {employee147.JobTitle}");

            sb.AppendLine(string.Join(Environment.NewLine, employee147.Projects));
                       
            return sb.ToString().TrimEnd();
        }
    }
}
