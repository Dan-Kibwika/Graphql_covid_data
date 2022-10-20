
import ballerina/graphql;


// {"date"": "12/09/2021","region": "Khomas","deaths": 39,"confirmed_cases": 465"recoveries": 67"tested": 1200}


// ==============================
// DATASET
// ==============================

public type CovidStatisticRecord record {|

string date ;
readonly string region;
decimal deaths;
decimal confirmed_cases;
decimal recoveries;
decimal tested;

|};

// ==============================
// DATASET ENDS HERE
// ==============================


// ==============================
// TABLE
// ==============================

isolated table <CovidStatisticRecord> key(region) covidTable = table [

{date: "12/09/2021",region: "Khomas",deaths: 39,confirmed_cases: 465,recoveries: 67,tested: 1200 }

 ];

// ==============================
// TABLE ENDS HERE
// ==============================



// ==============================
// MY TYPES HERE 
// ==============================


isolated service class CovidData {



   private final readonly & CovidStatisticRecord entryRecord;


   isolated function init(CovidStatisticRecord entryRecord) {


      self.entryRecord = entryRecord.cloneReadOnly();

    
   }


    isolated resource function get  date () returns string {
        
        lock{
            return self.entryRecord.date;
        }
    }

    isolated resource function get region () returns string {

               lock {

                return self.entryRecord.region;
               }

    }



isolated resource function get deaths () returns decimal {

               lock{

            if self.entryRecord.deaths is decimal?{
            return self.entryRecord.deaths / 1000;
        }
        

        }

    }



    isolated resource function get  confirmed_cases () returns decimal?{

        lock{

            if self.entryRecord.confirmed_cases is decimal?{
            return self.entryRecord.confirmed_cases / 1000;
        }
    

        }
    }



    isolated resource function get  recoveries () returns decimal {

         lock{

            if self.entryRecord.recoveries is decimal?{
            return self.entryRecord.recoveries / 1000;
        }
        

        }

    }


    isolated resource function get tested () returns decimal {

        lock{

            if self.entryRecord.tested is decimal?{
            return self.entryRecord.tested ;
        }
        

        }

    }


    


}





service /covid19 on new graphql:Listener(8080){


 isolated resource function get allData() returns CovidData[]{


        lock{
           CovidStatisticRecord[] covidEntries = covidTable.clone().toArray().cloneReadOnly();
           return covidEntries.clone().map(entry => new CovidData(entry));
        }
 }


 isolated resource function get DataFilter(string region) returns CovidData?{


        lock {

            CovidStatisticRecord? covidIn = covidTable[region].clone();
            if  covidIn  is  CovidStatisticRecord{
                return new(covidIn);

            }

            return;
        }
 }


 isolated remote function add(CovidStatisticRecord entry) returns CovidData?{


        lock {
            covidTable.clone().add(entry.clone());
            return new CovidData(entry.clone());
        }
 }


}

// curl -X POST -H "Content-type: application/json" -H "scope: unknown" -d '{ "query": "query { all { country cases active} }" }''http://localhost:9000/covid19'