using Microsoft.Data.SqlClient;
using System;

namespace ADO_NET_Lab
{
    class Program
    {
        static void Main(string[] args)
        {
            Console.Write("Username: ");
            string username = Console.ReadLine();
            Console.Write("Password: ");
            string password = Console.ReadLine();

            string connectionString = @"Server=.\SQLEXPRESS;Database=Service;Integrated Security=true";
            using (SqlConnection sqlConnection = new SqlConnection(connectionString))
            {
                sqlConnection.Open();

                string command = "SELECT COUNT(*) FROM [Users] WHERE Username = '@Username' AND Password = '@Password';";
                SqlCommand sqlCommand = new SqlCommand(command, sqlConnection);
                sqlCommand.Parameters.AddWithValue("@Username", username);
                sqlCommand.Parameters.AddWithValue("@Password", password);

                int usersCount = (int)sqlCommand.ExecuteScalar();
                if (usersCount > 0)
                {
                    Console.WriteLine("Welcome to our secret data.");
                }
                else
                {
                    Console.WriteLine("Access forbiden.");
                }
            }            
        }
    }
}
