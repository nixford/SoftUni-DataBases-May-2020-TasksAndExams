using Microsoft.Data.SqlClient;
using System;
using System.Collections.Generic;
using System.Linq;

namespace ADO_NET_Exercises
{
    class StartUp
    {
        static void Main(string[] args)
        {

            SqlConnection sqlConnection = new SqlConnection
                (@"Server=.\SQLEXPRESS;
                Database=MinionDB; 
                Integrated Security=true");
            {
                sqlConnection.Open();

                using (sqlConnection)
                {
                    List<Minion> minions = new List<Minion>();

                    SqlCommand command = new SqlCommand("SELECT v.Name AS [VillainName], m.Name AS[MinionName] " +
                                                        "FROM Villains v " +
                                                        "INNER JOIN MinionsVillains mv " +
                                                        "ON mv.VillainId = v.Id " +
                                                        "INNER JOIN Minions m " +
                                                        "ON m.Id = mv.MinionId", sqlConnection);

                    SqlDataReader reader = command.ExecuteReader();
                    while (reader.Read())
                    {
                        var minionName = (string)reader["MinionName"];
                        var villainName = (string)reader["VillainName"];
                        var minion = new Minion(minionName, villainName);
                        minions.Add(minion);
                    }

                    List<IGrouping<string, Minion>> groupMinions = minions
                        .GroupBy(m => m.VillainName)
                        .OrderByDescending(v => v.Count())
                        .ToList();

                    foreach (IGrouping<string, Minion> group in groupMinions)
                        Console.WriteLine($"{group.Key} - {group.Count()}");
                }
            }
        }
    }
}
