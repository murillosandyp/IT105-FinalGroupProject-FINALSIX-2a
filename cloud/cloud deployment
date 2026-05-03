# Cloud Deployment Documentation

## Platform Used
For this cloud deployment, We used Railway.app because it offers a free tier that does not require a credit card. It is easy to use and integrates well with MySQL databases.

## Connection Details
The MySQL instance was successfully created on Railway with the following connection parameters:
- Host: nozomi.proxy.rlwy.net
- Port: 48293
- Database name: railway
- Username: root
- Password: (kept secure, not shown for security purposes)

## Deployment Process
The following steps were performed to deploy the database to the cloud:

First, we created a new MySQL instance on Railway.app by clicking "New Project" and selecting "Provision MySQL". After a few minutes, the database was ready and we obtained the MYSQL_PUBLIC_URL which contained the connection details.

Second, we opened Command Prompt and navigated to my MySQL bin folder located at "C:\Program Files\MySQL\MySQL Server 9.6\bin".

Third, we used the mysql command line client to upload my backup.sql file to the cloud database using the command: mysql.exe --host=nozomi.proxy.rlwy.net --port=48293 -u root -p[PASSWORD] railway < D:\onlineShop_backup.sql

Fourth, after the upload completed, we verified that all tables were successfully created by running: mysql.exe --host=nozomi.proxy.rlwy.net --port=48293 -u root -p[PASSWORD] -e "SHOW TABLES" railway

## Verification Results
The SHOW TABLES query returned the following tables, confirming that the deployment was successful:
- auditlog
- category
- customer
- order
- orderitem
- payment
- product
- user

## Screenshot
The screenshot file named "cloud_deployment.png" shows the actual output of the SHOW TABLES command executed on the Railway cloud database.

## Conclusion
The cloud deployment was completed successfully. The database is now hosted on Railway.app and can be accessed remotely using the connection details provided above.
