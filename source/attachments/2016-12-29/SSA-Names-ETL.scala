// Databricks notebook source
// MAGIC %md
// MAGIC # SSA Names ETL
// MAGIC 
// MAGIC This notebook uses Apache Spark and Databricks to download a zip file of first name statistics from the Social Security Administration's web site, unpack the file, load the contents, and save the final data as a single Parquet file which is more suitable for data analysis. 
// MAGIC 
// MAGIC The SSA data describes the frequency of first names by year. See <https://www.ssa.gov/OACT/babynames/limits.html> for further information.
// MAGIC 
// MAGIC **NOTE:** You _must_ run this notebook on a Spark 2.0 or 2.1 cluster. 

// COMMAND ----------

// MAGIC %md 
// MAGIC ## Setup
// MAGIC 
// MAGIC First, let's define some constants. You can change these things to redirect where the data is eventually written. If you want to save the data to your own S3 bucket, you can mount the bucket as a DBFS directory. See <https://docs.databricks.com/user-guide/dbfs-databricks-file-system.html#mounting-an-s3-bucket> for details.

// COMMAND ----------

val LocalTmpFile = "/tmp/names.zip"           // Where to save the downloaded zip file
val LocalTmpDir  = "/tmp/names"               // Directory into which to unpack the zip file temporarily
val DBFSTmpDir   = "dbfs:/tmp/names"          // Where to copy the unzipped contents, so they'll be accessible to Spark
val DBFSParquet  = "dbfs:/tmp/names.parquet"  // Where to write the final Parquet file. You'll probably want to change this.

// COMMAND ----------

// MAGIC %md We'll use the `scala.sys.process._` DSL to run shell commands.

// COMMAND ----------

import scala.sys.process._

// COMMAND ----------

// MAGIC %md 
// MAGIC ## Download the raw data
// MAGIC 
// MAGIC We're downloading the the [national data](https://www.ssa.gov/OACT/babynames/names.zip) file. Rather than write a bunch of Java code to download the file, we can just use the _curl_(1) command via the shell.
// MAGIC 
// MAGIC This might take awhile.

// COMMAND ----------

s"rm -rf $LocalTmpFile $LocalTmpDir".!!

// COMMAND ----------

s"curl -o $LocalTmpFile -s https://www.ssa.gov/OACT/babynames/names.zip".!!

// COMMAND ----------

print(s"ls -l $LocalTmpFile".!!)

// COMMAND ----------

// MAGIC %md 
// MAGIC ## Unpack the raw data
// MAGIC 
// MAGIC Next, we'll use the _unzip_(1) command on the server to unpack the zip file into the temporary directory.

// COMMAND ----------

s"mkdir $LocalTmpDir".!!

// COMMAND ----------

s"unzip -d $LocalTmpDir -q $LocalTmpFile".!!

// COMMAND ----------

s"ls -l $LocalTmpDir".!!.split("\n").foreach(println)

// COMMAND ----------

// MAGIC %md 
// MAGIC ## Copy to DBFS
// MAGIC 
// MAGIC The next step is to copy the contents to DBFS. DBFS (the "Databricks File System") is a distributed file system backed by Amazon's S3. Putting the contents in DBFS allows this notebook to run on clusters that actually have multiple machines. (Databricks Community Edition uses a Spark Local Mode cluster, so all the work is done in the Spark Driver. Strictly speaking, we don't
// MAGIC need DBFS there, but I want this notebook to be usable in any cluster.)

// COMMAND ----------

dbutils.fs.rm(DBFSTmpDir, recurse=true)

// COMMAND ----------

dbutils.fs.mkdirs(DBFSTmpDir)

// COMMAND ----------

// This might take awhile.
val keep = """^(yob\d\d\d\d\.txt)$""".r
val files = "ls -1 /tmp/names".!!.split("""\n""").collect { case keep(filename) => filename }
for (f <- files) {
  dbutils.fs.cp(s"file:/tmp/names/$f", s"dbfs:/tmp/names/$f")
}

// COMMAND ----------

display(dbutils.fs.ls(DBFSTmpDir))

// COMMAND ----------

// MAGIC %md 
// MAGIC ## ETL
// MAGIC 
// MAGIC This part's tricky. The year is part of each file name, but it's _not_ part of the data. That means we need to reach each file, one at a time, extract the year from the file name, and merge it into the data.

// COMMAND ----------

println(dbutils.fs.head(DBFSTmpDir + "/" + files(0)))

// COMMAND ----------

// MAGIC %md The following code creates a single DataFrame from all the files in a directory (by progressively combining individual DataFrames with `union`), ensuring that the year is pulled from the file name and added to each DataFrame. The final DataFrame is a union of a lot of different DataFrames.
// MAGIC 
// MAGIC Read the code carefully, if you want to understand how it works. Otherwise, just accept that it does.

// COMMAND ----------

import scala.annotation.tailrec
import org.apache.spark.sql._
import org.apache.spark.sql.functions._
import org.apache.spark.sql.types._

val ExtractYear = """^.*yob(\d{4})\.txt""".r
val InputSchemaFields = List(StructField("firstName", StringType, true),
                             StructField("gender", StringType, true),
                             StructField("total", IntegerType, true))
val InputSchema = StructType(InputSchemaFields)
val FinalSchema = StructType(InputSchemaFields :+ StructField("year", IntegerType, true))

/** Load a sequence of SSA name files into one DataFrame, ensuring that the
  * year is extracted from the file name and contained (as data) in the resulting
  * DataFrame.
  *
  * @param dir    the directory (presumably on DBFS)
  * @param files  the sequence of file names
  *
  * @return a DataFrame that will concatenate the data from all the files
  */
def loadFiles(dir: String, files: Seq[String]): DataFrame = {
  
  @tailrec def loadNext(dir: String, files: List[String], currentDF: DataFrame): DataFrame = {
    files match {
      case Nil => 
        // End of the list of files. We're done.
        currentDF
      
      case (f @ ExtractYear(year)) :: rest =>
        // File matches regular expression. Load it, add the "year" column, and union it with the
        // current DataFrame.
        val dfTemp = spark.read.schema(InputSchema).csv(s"$dir/$f").select($"*", lit(year).as("year"))
        val newDF = currentDF.union(dfTemp)
        // Move on to the next file.
        loadNext(dir, rest, newDF)

      case f :: rest =>
        // File doesn't match. Skip it and move it.
        println(s"WARNING: Skipping $f")
        loadNext(dir, rest, currentDF)
    }
  }
  
  loadNext(dir, files.toList, spark.createDataFrame(sc.emptyRDD[Row], FinalSchema))
}

// COMMAND ----------

// MAGIC %md Load 'em up. 

// COMMAND ----------

val files = dbutils.fs.ls("dbfs:/tmp/names").map(_.name)
val df = loadFiles("dbfs:/tmp/names", files)
println(s"Loaded ${df.count} records.")
println()

// COMMAND ----------

// MAGIC %md Now, write the results to a Parquet file. We'll partition by year.

// COMMAND ----------

df.write.partitionBy("year").mode(SaveMode.Overwrite).parquet(DBFSParquet)

// COMMAND ----------

display(dbutils.fs.ls(DBFSParquet))

// COMMAND ----------

// MAGIC %md
// MAGIC ## Verification
// MAGIC 
// MAGIC It doesn't hurt to run a few tests on the final Parquet file.

// COMMAND ----------

val df = spark.read.parquet(DBFSParquet)

// COMMAND ----------

df.rdd.partitions.length

// COMMAND ----------

df.count

// COMMAND ----------

df.select($"year").distinct.orderBy($"year").show()

// COMMAND ----------

display(df.describe())

// COMMAND ----------

// MAGIC %md 
// MAGIC ## Clean up
// MAGIC 
// MAGIC Time to clean up our temporary stuff.

// COMMAND ----------

s"rm -rf $LocalTmpFile $LocalTmpDir".!!
dbutils.fs.rm(DBFSTmpDir, recurse=true)
