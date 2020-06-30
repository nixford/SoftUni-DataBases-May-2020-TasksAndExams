using Microsoft.Data.SqlClient;
using System;
using System.Linq;

namespace _9._Increase_Age_Stored_Procedure
{
    public class StartUp
    {
        static void Main(string[] args)
        {
            int[] ids = Console.ReadLine()
                .Split(new[] { ' ' }, 
                StringSplitOptions.RemoveEmptyEntries)
                .Select(int.Parse)
                .ToArray();

            SqlConnection connection = new SqlConnection(@"Server=.\SQLEXPRESS;Database=MinionDB;Integrated Security = true");
            connection.Open();

            using (connection)
            {
                foreach (int id in ids)
                {
                    SqlCommand command = new SqlCommand("EXEC usp_GetOlder @id", connection);
                    command.Parameters.AddWithValue("@id", id);
                    command.ExecuteNonQuery();
                }

                SqlCommand selectCommand = new SqlCommand("SELECT * FROM Minions", connection);
                SqlDataReader reader = selectCommand.ExecuteReader();
                while (reader.Read())
                {
                    Console.WriteLine($"{reader["Name"]} - {reader["Age"]} old years old");
                }
            }
        }
    }
}
