# Ways to the Bacon

This repository accompanies the presentation "Ways to the Bacon" ( https://bit.ly/bacon_pptx ) by Kim Berg Hansen.
This branch (New2023) represents updated version co-created and co-presented with Hans Viehmann of Oracle.

This is purely for demonstration. Use it at your own risk and be sure to understand it before using.

# Usage

Folder scripts contain:

* bacon_setup.sql - One method to load 3 files into tables via cloud storage. Read script for file URLs. You can load files another way if you want.

* bacon_normalize.sql - Create normalized tables from the raw data.

* bacon_counts.sql - Simple counts of table contents.

* bacon_sql.sql - Solution based on pure SQL with recursive subquery factoring.

* bacon_plsql_1.sql - Solution implementing Breadth First Search in pure PL/SQL.

* bacon_plsql_2.sql - Modified version with less use of PL/SQL collection and more use of index table lookups.

* bacon_plsql_3.sql - Further modification attempting to reduce PGA usage by pipelining.

* bacon_plsql_4.sql - Version that accepts both start and end actor and uses BFS from both ends until they meet.

Folder notebooks contain:

* bacon_small.dsnb - Zeppelin Notebook for Graph Studio with PGQL queries

* bacon_small_pgql.txt - Text file with just the PGQL queries from the notebooks

* bacon_top250.dsnb - Zeppelin Notebook for Graph Studio with PGQL queries

* bacon_top250_pgql.txt - Text file with just the PGQL queries from the notebooks

