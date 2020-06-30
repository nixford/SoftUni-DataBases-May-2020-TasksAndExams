using Microsoft.Data.SqlClient;
using System;
using System.IO;
using System.Linq;
using System.Text;


namespace _1._Initial_Setup
{
    class StartUp
    {

        static void Main(string[] args)
        {
            SqlConnection sqlConnection = new SqlConnection
                (@"Server=.\SQLEXPRESS;
                Database=master; 
                Integrated Security=true");
            
                sqlConnection.Open();

            using (sqlConnection)
            {
                string createDatabase = "CREATE DATABASE MinionDB";
                ExecuteCommand(createDatabase, sqlConnection);

                string use = "USE MinionDB";
                ExecuteCommand(use, sqlConnection);

                string createCountriesSql = "CREATE TABLE Countries (Id INT PRIMARY KEY IDENTITY, Name VARCHAR(50))";
                string createTownsSql = "CREATE TABLE Towns (Id INT PRIMARY KEY IDENTITY, Name VARCHAR(50), CountryId INT NOT NULL, CONSTRAINT FK_TownCountry FOREIGN KEY (CountryId) REFERENCES Countries(Id))";
                string createMinionsSql = "CREATE TABLE Minions (Id INT PRIMARY KEY IDENTITY, Name VARCHAR(50), Age INT, TownId INT, CONSTRAINT FK_Towns FOREIGN KEY (TownId) REFERENCES Towns(Id))";
                string createEvilnessFactorsSql = "CREATE TABLE EvilnessFactors (Id INT PRIMARY KEY, Name VARCHAR(10) UNIQUE NOT NULL)";
                string createVillainsSql = "CREATE TABLE Villains (Id INT PRIMARY KEY IDENTITY, Name VARCHAR(50), EvilnessFactorId INT, CONSTRAINT FK_VillainEvilnessFactor FOREIGN KEY (EvilnessFactorId) REFERENCES EvilnessFactors(Id))";
                string createMinionsVillainsSql = "CREATE TABLE MinionsVillains(MinionId INT, VillainId INT, CONSTRAINT FK_Minions FOREIGN KEY (MinionId) REFERENCES Minions(Id), CONSTRAINT  FK_Villains FOREIGN KEY (VillainId) REFERENCES Villains(Id), CONSTRAINT PK_MinionsVillains PRIMARY KEY(MinionId, VillainId))";

                ExecuteCommand(createCountriesSql, sqlConnection);
                ExecuteCommand(createTownsSql, sqlConnection);
                ExecuteCommand(createMinionsSql, sqlConnection);
                ExecuteCommand(createEvilnessFactorsSql, sqlConnection);
                ExecuteCommand(createVillainsSql, sqlConnection);
                ExecuteCommand(createMinionsVillainsSql, sqlConnection);

                string insertCountriesSql = "INSERT INTO Countries VALUES ('Bulgaria'), ('United Kingdom'), ('United States of America'), ('France')";
                string insertTownsSql = "INSERT INTO Towns (Name, CountryId) VALUES ('Sofia',1), ('Burgas',1), ('Varna', 1), ('London', 2),('Liverpool', 2),('Ocean City', 3),('Paris', 4)";
                string insertMinionsSql = "INSERT INTO Minions (Name, Age, TownId) VALUES ('bob',10,1),('kevin',12,2),('stuart',9,3), ('rob',22,3), ('michael',5,2),('pep',3,2)";
                string insertEvilnessFactorsSql = "INSERT INTO EvilnessFactors VALUES (1, 'Super Good'), (2, 'Good'), (3, 'Bad'), (4, 'Evil'), (5, 'Super Evil')";
                string insertVillainsSql = "INSERT INTO Villains (Name, EvilnessFactorId) VALUES ('Gru', 2),('Victor', 4),('Simon Cat', 3),('Pusheen', 1),('Mammal', 5)";
                string insertMinionsVillainsSql = "INSERT INTO MinionsVillains VALUES (1, 2), (3, 1), (1, 3), (3, 3), (4, 1), (2, 2), (1, 1), (3, 4), (1, 4), (1, 5), (5, 1)";

                ExecuteCommand(insertCountriesSql, sqlConnection);
                ExecuteCommand(insertTownsSql, sqlConnection);
                ExecuteCommand(insertMinionsSql, sqlConnection);
                ExecuteCommand(insertEvilnessFactorsSql, sqlConnection);
                ExecuteCommand(insertVillainsSql, sqlConnection);
                ExecuteCommand(insertMinionsVillainsSql, sqlConnection);
            }
        }

        private static void ExecuteCommand(string text, SqlConnection sqlConnection)
        {
            SqlCommand command = new SqlCommand(text, sqlConnection);
            command.ExecuteNonQuery();
        }
    }
}
