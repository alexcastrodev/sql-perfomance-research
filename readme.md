# Perfomance on SQL queries

To testing a perfomance of SQL queries, let's create our own database.

## Create a database

I used a docker container with a PostgreSQL database.

```bash
docker compose up -d
```

if you want to change access to the database, you can do it in the file `docker-compose.yml`.

## Create a table

I used a simple script that creates a table in the database. you can find it in `structure.sql`.

## Insert data

I created 2 seed files with data. You can find them in `seed/` folder.

the first seed (just to test) `first_seed.sql`, and ensure that all works fine.

so, the second seed are 2 scripts inside `seed/` folder.

- users.js => This will generate 1000 users with random data.

- inquiries.js => This will run an infinite loop, that will insert  inquiries with random data.

We are not using any index (for while), so we will get a full table scan.

## Check tables

To get my Database status, I used the following command:

```sql
SELECT (SELECT COUNT(*) FROM users) AS users, (SELECT COUNT(*) FROM inquiries) AS inquiries;
```

The result

```bash
    users | inquiries
----------+-----------
    70679 |   2846209
```

Usage disk

```bash
1 075 191 808 bytes (1,08 GB on disk)
```


### Query 1

By not using select * and using the limit, we can get a better perfomance.

```sql
SELECT * FROM inquiries WHERE user_id = 1;
```

```bash
Time: 1.218s
```

-----

```sql
SELECT inquiry_id, message FROM inquiries WHERE user_id = 1 LIMIT 10;
```

```bash
Time: 0.193s
```

### Query 2

Imagine you need to join with users table, to get the user name.

```sql
select username, message from inquiries 
left join users ON users.user_id = inquiries.user_id
where inquiries.user_id = '1'
```

```bash
Time: ~0.720ms
```

So i ran more 3 queries:

```sql
-- about 0.720ms
select username, message from inquiries 
inner join users ON users.user_id = inquiries.user_id
where inquiries.user_id = '2';

-- about 0.720ms
select username, message from users 
left join inquiries ON users.user_id = inquiries.user_id
where inquiries.user_id = '2';

-- about 0.720ms
select username, message from users 
inner join inquiries ON users.user_id = inquiries.user_id
where inquiries.user_id = '2';
```

As for performance, the INNER JOIN is generally more performant than the LEFT JOIN. 

The reason is that the INNER JOIN only includes rows where there's a match, and thus it can be optimized by the database engine to use indexes efficiently and reduce the number of rows to be processed.

but we are not using any index yet, so let's add some indexes.

We are using users_id and inquiry_id as primary keys, so we don't need to add indexes to them.

`inquiries.user_id` => Since we are using this column in the WHERE clause for filtering, adding an index on this column will likely improve the performance of queries involving user_id-based filtering.

```sql
CREATE INDEX idx_inquiries_user_id ON inquiries (user_id);
``````

Remember that the tradeoff is more space usage and slower writes, but faster reads.

```bash
# From
1 075 191 808 bytes (1,08 GB on disk)

# TO
1 095 118 848 bytes (1,1 GB on disk)
```


Lets run the same queries again.

```sql
-- about 0.720ms
select username, message from inquiries 
left join users ON users.user_id = inquiries.user_id
where inquiries.user_id = '2';

-- about 0.720ms
select username, message from inquiries 
inner join users ON users.user_id = inquiries.user_id
where inquiries.user_id = '2';

-- about 0.720ms
select username, message from users 
left join inquiries ON users.user_id = inquiries.user_id
where inquiries.user_id = '2';

-- about 0.720ms
select username, message from users 
inner join inquiries ON users.user_id = inquiries.user_id
where inquiries.user_id = '2';
```

Lets understand what happened:

```sql
explain select username, message from inquiries 
inner join users ON users.user_id = inquiries.user_id
where inquiries.user_id = '2';

explain select username, message from users 
left join inquiries ON users.user_id = inquiries.user_id
where inquiries.user_id = '2';

explain select username, message from users 
inner join inquiries ON users.user_id = inquiries.user_id
where inquiries.user_id = '2';
```

All of this queries are using the same execution plan.

```bash
| QUERY PLAN                                                 |
| ---------------------------------------------------------- |
| Nested Loop  (cost=8210.34..58641.81 rows=735176 width=55) |
  ->  Index Scan using users_pkey on users  (cost=0.29..8.31 rows=1 width=10)
  ->  Bitmap Heap Scan on inquiries  (cost=8210.04..51281.74 rows=735176 width=53)
    ->  Bitmap Heap Scan on inquiries  (cost=8210.04..51281.74 rows=735176 width=53)
        Recheck Cond: (user_id = 2)
        Index Cond: (user_id = 2)
            ->  Bitmap Index Scan on idx_inquiries_user_id  (cost=0.00..8026.25 rows=735176 width=0)
                Index Cond: (user_id = 2)
```

The primary table being accessed is "users," and it is scanned using an index scan (users_pkey).
The second table being accessed is "inquiries," and it is scanned twice using bitmap heap scan, both with the same condition (user_id = 2).
The Bitmap Index Scan (idx_inquiries_user_id) is used to access the "inquiries" table.

-----------

The first one is different than others.
    
```sql
explain select username, message from inquiries 
left join users ON users.user_id = inquiries.user_id
where inquiries.user_id = '2'
```

```bash
| QUERY PLAN                                                 |
| ---------------------------------------------------------- |
| Nested Loop Left Join  (cost=8210.34..58641.81 rows=735176 width=55) |
  Hash Cond: (inquiries.user_id = users.user_id)
  ->  Bitmap Heap Scan on inquiries  (cost=8210.04..51281.74 rows=735176 width=53)
      Recheck Cond: (user_id = 2)
        ->  Bitmap Index Scan on idx_inquiries_user_id  (cost=0.00..8026.25 rows=735176 width=0)
            Index Cond: (user_id = 2)
  ->  Hash  (cost=8.31..8.31 rows=1 width=10)
         ->  Index Scan using users_pkey on users  (cost=0.29..8.31 rows=1 width=10)
             Index Cond: (user_id = 2)
```

The primary table being accessed is "inquiries," and it is scanned using a bitmap heap scan with the condition (user_id = 2).

The second table being accessed is "users," and it is scanned using an index scan (users_pkey) with the condition (user_id = 2).

The Nested Loop Left Join is performed based on the hash condition (inquiries.user_id = users.user_id).

------------

The big difference is when we use LIMIT:

```sql
-- Time: 0.032s
select username, message from inquiries 
left join users ON users.user_id = inquiries.user_id
where inquiries.user_id = '2' LIMIT 10;

-- Time: 0.020s
select username, message from inquiries 
inner join users ON users.user_id = inquiries.user_id
where inquiries.user_id = '2'  LIMIT 10;

-- Time: 0.020s
select username, message from users 
left join inquiries ON users.user_id = inquiries.user_id
where inquiries.user_id = '2'  LIMIT 10;

-- Time: 0.020s
select username, message from users 
inner join inquiries ON users.user_id = inquiries.user_id
where inquiries.user_id = '2' LIMIT 10;
```


```sql
-- Time: 0.018s
select username, message from inquiries 
left join users ON users.user_id = inquiries.user_id
where inquiries.user_id = '2' LIMIT 10;

-- Time: 0.012s
select username, message from inquiries 
inner join users ON users.user_id = inquiries.user_id
where inquiries.user_id = '2'  LIMIT 10;

-- Time: 0.012s
select username, message from users 
left join inquiries ON users.user_id = inquiries.user_id
where inquiries.user_id = '2'  LIMIT 10;

-- Time: 0.012s
select username, message from users 
inner join inquiries ON users.user_id = inquiries.user_id
where inquiries.user_id = '2' LIMIT 10;
```

# Considerations

We could use Redis with a medium TTL to cache the results of the queries. This would be a good solution if we have a lot of reads and few writes.

# Conclusion

The best solution is when you look at the context, and you understand what you need to do. In this case, We can use a single table with a single index, and we can use a cache to improve the reads.

# References

https://www.cybertec-postgresql.com/en/combined-indexes-vs-separate-indexes-in-postgresql

https://www.postgresql.org/docs/current/indexes-multicolumn.html

https://dba.stackexchange.com/questions/6115/working-of-indexes-in-postgresql