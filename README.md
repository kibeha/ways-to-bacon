# Ways to the Bacon

This repository accompanies the presentation "Ways to the Bacon" ( https://bit.ly/ways-to-bacon ) by Kim Berg Hansen.
This branch (New2023) represents updated version co-created and co-presented with Hans Viehmann of Oracle.

This is purely for demonstration. Use it at your own risk and be sure to understand it before using.

# Usage

Folder scripts contain:

* bacon_setup.sql - One method to load 3 files into tables via apex_web_service.make_rest_request. Read script for file URLs. You can load files another way if you want.

* bacon_normalize.sql - Create normalized tables from the raw data.

* bacon_counts.sql - Simple counts of table contents.

* bacon_sql.sql - Solution based on pure SQL with recursive subquery factoring.

* bacon_plsql_1.sql - Solution implementing Breadth First Search in pure PL/SQL.

* bacon_plsql_2.sql - Modified version with less use of PL/SQL collection and more use of index table lookups.

* bacon_plsql_3.sql - Further modification attempting to reduce PGA usage by pipelining.

* bacon_plsql_3b.sql - Even further modification attempting to reduce PGA even more by skipping connection path.

* bacon_plsql_4.sql - Version that accepts both start and end actor and uses BFS from both ends until they meet.

* bacon_timing.sql - Script for multiple executions of each version to compage average execution times.

Folder notebooks contain:

* Bacon_bacon_small.dsnb - Zeppelin Notebook for Graph Studio with PGQL queries for small dataset

* bacon_small_pgql.txt - Text file with just the PGQL queries from the notebooks

* Bacon_bacon_top250.dsnb - Zeppelin Notebook for Graph Studio with PGQL queries for top250 dataset

* bacon_top250_pgql.txt - Text file with just the PGQL queries from the notebooks

* Bacon_bacon_full.dsnb - Zeppelin Notebook for Graph Studio with PGQL queries for full dataset

* bacon_full_pgql.txt - Text file with just the PGQL queries from the notebooks

* OUG Norway_Six Degrees of Kevin Bacon - Movies only.dsnb - Zeppelin Notebook for Graph Studio with more advanced PGQL

* ImDB.json - Companion template to improve look-and-feel of actor/movie graphs
