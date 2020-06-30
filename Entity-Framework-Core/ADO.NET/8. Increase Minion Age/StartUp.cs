using Microsoft.Data.SqlClient;
using System;
using System.Linq;

namespace _8._Increase_Minion_Age
{
    public class StartUp
    {
        static void Main(string[] args)
        {
            SqlConnection connection = new SqlConnection(@"Server=.\SQLEXPRESS;Database=MinionDB;Integrated Security = true");
            connection.Open();

            int[] ids = Console.ReadLine()
                .Split(new[] { ' ' }, 
                StringSplitOptions.RemoveEmptyEntries)
                .Select(int.Parse)
                .ToArray();

            using (connection)
            {
                foreach (int id in ids)
                {
                    SqlCommand command = new SqlCommand("UPDATE Minions SET Age += 1 WHERE Id = @id", connection);
                    command.Parameters.AddWithValue("@id", id);
                    command.ExecuteNonQuery();
                }

                SqlCommand selectCommand = new SqlCommand("SELECT * FROM Minions", connection);
                SqlDataReader reader = selectCommand.ExecuteReader();

                while (reader.Read())
                {
                    Console.WriteLine($"{reader["Name"]} - {reader["Age"]}");
                }
            }
        }
    }
}
