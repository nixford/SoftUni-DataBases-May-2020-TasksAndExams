using Microsoft.Data.SqlClient;
using System;
using System.Collections.Generic;

namespace _7._Print_All_Minion_Names
{
    public class StartUp
    {
        static void Main(string[] args)
        {
            SqlConnection connection = new SqlConnection(@"Server=.\SQLEXPRESS;Database=MinionDB;Integrated Security = true");
            connection.Open();

            using (connection)
            {
                SqlCommand command = new SqlCommand("SELECT Name FROM Minions", connection);
                SqlDataReader reader = command.ExecuteReader();

                List<string> names = new List<string>();
                while (reader.Read())
                {
                    string name = (string)reader["Name"];
                    names.Add(name);
                }

                for (int i = 0; i < names.Count / 2; i++)
                {
                    Console.WriteLine(names[i]);
                    Console.WriteLine(names[names.Count - 1 - i]);
                }
                if (names.Count % 2 == 1)
                {
                    Console.WriteLine(names[names.Count / 2]);
                }
            }
        }
    }
}
