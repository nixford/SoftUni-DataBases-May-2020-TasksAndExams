using Microsoft.Data.SqlClient;
using System;
using System.Text;

namespace _3._Minion_Names
{
    public class StartUp
    {
        private const string ConnectionString = @"Server=.\SQLEXPRESS;Database=MinionDB;Integrated Security = true";

        static void Main(string[] args)
        {
            using SqlConnection sqlConnection = new SqlConnection
                (ConnectionString);

            sqlConnection.Open();

            int villianId = int.Parse(Console.ReadLine());
            string result = GetMinionsInfoAboutVillian(sqlConnection, villianId);

            Console.WriteLine(result);
        }

        private static string GetMinionsInfoAboutVillian(SqlConnection sqlConnection, int villianId)
        {
            StringBuilder sb = new StringBuilder();

            string getVillianNameQuerryText = @"SELECT [Name] FROM Villains WHERE Id = @villianId";

            using SqlCommand getVillianNameCmd = new SqlCommand
                (getVillianNameQuerryText, sqlConnection);
            getVillianNameCmd.Parameters
                .AddWithValue("@villianId", villianId);

            string villianName = getVillianNameCmd
                .ExecuteScalar()?
                .ToString();

            if (villianName == null)
            {
                sb.AppendLine($"No villain with ID {villianId} exists in the database.");
            }
            else
            {
                sb.AppendLine($"Villain: {villianName}");

                string getMinionsInfoQuerryText = @"SELECT m.[Name], m.[Age]
                       FROM Villains AS v
                       LEFT OUTER JOIN MinionsVillains AS mv ON v.Id = mv.VillainId
                       LEFT OUTER JOIN Minions AS m ON mv.MinionId = m.Id
                       WHERE v.[Name] = 'Gru'
                       ORDER BY m.[Name]";

                SqlCommand getMinionsInfoCommand = new SqlCommand
                    (getMinionsInfoQuerryText, sqlConnection);
                getMinionsInfoCommand.Parameters
                    .AddWithValue("@villianName", villianName);

                using SqlDataReader reader = getMinionsInfoCommand
                    .ExecuteReader();

                if (reader.HasRows)
                {
                    int rowNum = 1;
                    while (reader.Read())
                    {
                        string minionName = reader["Name"]?.ToString();
                        string minionAge = reader["Age"]?.ToString();

                        sb.AppendLine($"{rowNum}. {minionName} {minionAge}");
                        rowNum++;
                    }
                }
                else
                {
                    sb.AppendLine("(no minions)");
                }
            }

            return sb.ToString().TrimEnd();
        }
    }
}
