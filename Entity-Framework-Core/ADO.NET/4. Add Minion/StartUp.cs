using Microsoft.Data.SqlClient;
using System;
using System.Linq;
using System.Text;

namespace _4._Add_Minion
{
    public class StartUp
    {
        private const string ConnectionString = @"Server=.\SQLEXPRESS;Database=MinionDB;Integrated Security = true";

        static void Main(string[] args)
        {
            using SqlConnection sqlConnection = new SqlConnection
               (ConnectionString);

            sqlConnection.Open();


            string[] minionsInput = Console.ReadLine()
                .Split(": ", StringSplitOptions.RemoveEmptyEntries)
                .ToArray();

            string[] minionsInfo = minionsInput[1]
                .Split(' ', StringSplitOptions.RemoveEmptyEntries)
                .ToArray();

            string[] villianInput = Console.ReadLine()
                .Split(": ", StringSplitOptions.RemoveEmptyEntries)
                .ToArray();

            string[] villianInfo = villianInput[1]
              .Split(' ', StringSplitOptions.RemoveEmptyEntries)
              .ToArray();

            string result = AddMinionToDatabase(sqlConnection, minionsInfo, villianInfo);

            Console.WriteLine(result);
        }

        private static string AddMinionToDatabase(SqlConnection sqlConnection, 
            string[] minionsInfo, string[] villianInfo)
        {
            StringBuilder output = new StringBuilder();

            string minionName = minionsInfo[0];
            string minionAge = minionsInfo[1];
            string minionTown = minionsInfo[2];
            //string townCountry = minionsInfo[3];

            string villainName = villianInfo[0];

            string townId = EnsureTownExist(sqlConnection, minionTown,
                output);
            string villiandId = EnsureVillainExists(sqlConnection, villainName,
                output);

            string insertMinionQueryText = @"INSERT INTO Minions([Name], Age, TownId) 
                        VALUES(@minionName, @minionAge, @townId)";

            using SqlCommand insertMinionCmd = new SqlCommand
                (insertMinionQueryText, sqlConnection);
            insertMinionCmd.Parameters.AddRange(values: new[]
            {
                new SqlParameter("@minionName", minionName),
                new SqlParameter("@minionAge", minionAge),
                new SqlParameter("@townId", townId)
            });

            insertMinionCmd.ExecuteNonQuery();

            string getMinionIdQueryText = @"SELECT Id FROM Minions
                                            WHERE [Name] = @minionName";

            using SqlCommand getMinionIdCmd = new SqlCommand
                (getMinionIdQueryText, sqlConnection);
            getMinionIdCmd.Parameters.AddWithValue("@minionName", minionName);

            string minionId = getMinionIdCmd.ExecuteScalar().ToString();

            string insetIntoMappingQueryText = @"INSERT INTO MinionsVillains(MinionId, VillainId) VALUES(@minionId, @villainId)";

            using SqlCommand insertIntoMappingCmd = new SqlCommand
                (insetIntoMappingQueryText, sqlConnection);

            insertIntoMappingCmd.Parameters.AddRange(values: new[]
            {
                new SqlParameter("@minionId", minionId),
                new SqlParameter("@villainId", villiandId),
            });

            insertIntoMappingCmd.ExecuteNonQuery();

            output.AppendLine($"Successfully added {minionName} to be minion of {villainName}.");

            return output.ToString().TrimEnd();
        } 

        private static string EnsureVillainExists(SqlConnection sqlConnection, string villainName, StringBuilder output)
        {
            string getVillainIdQueryText = "SELECT Id FROM Villains WHERE[Name] = '@name'";
            using SqlCommand getVillainIdCmd = new SqlCommand
                (getVillainIdQueryText, sqlConnection);
            getVillainIdCmd.Parameters
                .AddWithValue("@name", villainName);

            string villainId = getVillainIdCmd.ExecuteScalar()?.ToString();

            if (villainId == null)
            {
                string getFactorIdQueryText = @"SELECT Id FROM EvilnessFactors WHERE [Name] = 'Evil'";

                using SqlCommand getFactorIdCmd = new SqlCommand
                    (getFactorIdQueryText, sqlConnection);

                string factorId = getFactorIdCmd.ExecuteScalar()?.ToString();

                string insertVillainQuerryText = "INSERT INTO Villains([Name], EvilnessFactorId) VALUES(@villainName, @factor)";
                using SqlCommand insertVillainCmd = new SqlCommand
                    (insertVillainQuerryText, sqlConnection);
                insertVillainCmd.Parameters.AddWithValue("@villainName", villainName);
                insertVillainCmd.Parameters.AddWithValue("@factor", factorId);

                insertVillainCmd.ExecuteNonQuery();

                villainId = getVillainIdCmd.ExecuteScalar().ToString();

                output.AppendLine($"Villain {villainName} was added to the database.");
            }

            return villainId;
        }

        private static string EnsureTownExist(SqlConnection sqlConnection, 
            string minionTown, StringBuilder output)
        {
            string getTownIdQueryText = "SELECT Id FROM Towns WHERE [Name] = @townName";

            using SqlCommand getTownIdCmd = new SqlCommand
                (getTownIdQueryText, sqlConnection);
            getTownIdCmd.Parameters
                .AddWithValue("@townName", minionTown);

            string townId = getTownIdCmd.ExecuteScalar()?.ToString();

            if (townId == null)
            {
                string insertTownQuerryText = @"INSERT INTO Towns([Name], 
                                  CountryCode) VALUES (@townName, 1)";

                using SqlCommand insertTownCmd = new SqlCommand
                    (insertTownQuerryText, sqlConnection);
                insertTownCmd.Parameters.AddWithValue
                    ("@townName", minionTown);

                insertTownCmd.ExecuteNonQuery();

                townId = getTownIdCmd.ExecuteScalar().ToString();

                output.AppendLine($"Town {minionTown} was added to the database.");
            }

            return townId;
        }
    }
}
