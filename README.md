<h1>1. The Containers</h1>

Docker containers are a form of operating system-level virtualization that allow developers to package an application with all of its dependencies into a standardized unit for software development. How Docker Containers Work:

Containers are built from Docker images, which are read-only templates with instructions for creating a Docker container. When a container is run from an image, it adds a read-write layer on top of the image, which is where the application and its dependencies are stored. Containers are isolated from each other and from the host system, ensuring that they do not interfere with each other or with the host system. Docker uses the host system's kernel, which means containers can start much faster than VMs and use fewer resources.

In summary, Docker containers are best for deploying lightweight, scalable applications and microservices, while VMs are better suited for scenarios requiring strong isolation, security, and compatibility with different operating systems. The choice between Docker containers and VMs depends on the specific needs of the application and the environment in which it will be deployed.

<h2>1.1. MariaDB</h2>

MariaDB Server is one of the most popular database servers in the world, known for its performance, stability, and openness. It is part of most cloud offerings and the default in most Linux distributions. It was created by some of the original developers of MySQL, who forked it due to concerns over its acquisition by Oracle Corporation in 2009. MariaDB aims to <strong>maintain high compatibility with MySQL</strong>, including exact matching with MySQL APIs and commands, allowing it to function as a drop-in replacement for MySQL in many cases. MariaDB is developed as <strong>open-source software</strong> and provides an SQL interface for accessing data. It is used by notable organizations such as Wikipedia, WordPress.com, and Google, and is included by default in several Linux distributions and BSD operating systems.

<h3>1.1.1. Dockerfile</h3>

<ol>
<li>Use debian 11 (bullseye) image.</li>
<li>Indicate that this container will be listening on port 3306.</li>
<li>Update and install mariadb-server only</li>
	<ul>
	<li><code>apt update</code> update the package list for upgrades and new package installations.</li>
	<li><code>apt install -y</code>install the the specified packages. The <code>-y</code>flag automatically answers 'yes' to prompt and run non-interactively, which is great for scripting or automation.</li>
	<li><code>--no-install-recommends</code>Do not install recommended packages, which are packages that can enhances the functionatily of the installed packages but are not essential.</li>
	<li><code>--no-install-suggests</code>Similar to previous commands, prevents the installation of suggested packages.</li>
	<li><code>rm -rf /var/lib/apt/lists/*</code>Removes all the files in the /var/lib/apt/lists. Ensure that apt update will fetch fresh package lists the next time it's run.</li>
	</ul>
<li>copy the configuration file to the container.</li>
<li>copy the setup script to the container.</li>
<li>changes the permission of the setup script.</li>
<li>specifies the default command to execute when the container starts. In this case, it runs the setup script followed by mysqld_safe, which is the MariaDB server daemon. The mysqld_safe command starts the MariaDB server in a safe mode, which includes features like automatic restart on failure.</li>
</ol>

<h3>1.1.2. 50-server.cnf</h3>

This configuration file is crucial for customizing the behavior of the MariaDB server to suit specific needs, such as performance tuning, security settings, and resource allocation. It's used to configure various aspects of the MariaDB server.

<ol>
<li><code>[server]</code> used to configure server-wide settings.</li>
<li><code>[mysqld]</code> is used to configure the MariaDB server daemon. It includes the followings:<li>
	<ul>
	<li><code>user = mysql</code>specifies the user under which the MariaDB server runs.</li>
	<li><code>pid-file = /run/mysqld/mysqld.pid</code> specifies the location of the PID file, which contains the process ID of the MariaDB server.</li>
	<li><code>socket = /run/mysqld/mysqld.sock</code> specifies the location of the Unix socket file used for local connections.</li>
	<li><code>port = 3306</code> specifies the TCP/IP port on which the MariaDB server listens for connections.</li>
	<li><code>basedir = /usr</code> specifies the base directory of the MariaDB installation.</li>
	<li><code>datadir = /var/lib/mysql</code> specifies the directory where the database files are stored.</li>
	<li><code>tmpdir = /tmp</code> specifies the directory for temporary files.</li>
	<li><code>lc-messages-dir = /usr/share/mysql</code> specifies the directory for message files.</li>
	<li><code>query_cache_size = 16M</code> specifies the size of the query cache.</li>
	<li><code>expire_logs_days = 10</code> specifies the number of days to keep log files.</li>
	<li><code>log_error = /var/log/mysql/error.log</code> specifies the location of the error log file.</li>
	<li><code>character-set-server = utf8mb4</code> specifies the default character set for the server.</li>
	<li><code>collation-server = utf8mb4_general_ci</code> specifies the default collation for the server.</li>
	</ul>
<li><code>[embedded]</code> used to configure setting for the embedded server library.</li>
<li><code>[mariadb]</code> is used to configure MariaDB-specific settings.</li>
<li><code>[mariadb-10.3]</code> is used to configure settings specific to MariaDB version 10.3.</li>
</ol>

It's a default file without the commented lines.

<h3>1.1.3. setup.sh</h3>

This script is designed to automate the process of starting a MariaDB service, creating a database and users with specific privileges, and then stopping the service. Let's break down each line:
<ol>
<li><code>service mariadb start</code> starts the MariaDB service. It's a common way to manage services on Linux systems, ensuring that the MariaDB server is running before proceeding with the script.</li>
<li><code>mariadb -v -u root << EOF</code> initiates a MariaDB command-line session as the root user. The <code>-v</code> flag is used to enable verbose output, which can be helpful for debugging. The <code><< EOF</code> syntax indicates the start of a "here document" in shell scripting, which allows for multi-line input to be passed to the command.</li>
<li><code>CREATE DATABASE IF NOT EXISTS $DB_NAME;</code> this SQL command creates a new database with the name stored in the <code>$DB_NAME</code> environment variable, if it does not already exist.</li>
<li><code>CREATE USER IF NOT EXISTS '$DB_USER'@'%' IDENTIFIED BY '$DB_PASSWORD';</code> this command creates a new user with the username stored in <code>$DB_USER</code>, if it does not already exist. The user can connect from any host <code>%</code>, and the password is specified by <code>$DB_PASSWORD</code>.</li>
<li><code>GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'%' IDENTIFIED BY '$DB_PASSWORD';</code> This command grants all privileges on the newly created database to the user specified by <code>$DB_USER</code>. The <code>IDENTIFIED BY '$DB_PASSWORD'</code> part is redundant here since the user was already created with this password, but it's included for clarity.</li>
<li><code>GRANT ALL PRIVILEGES ON $DB_NAME.* TO 'root'@'%' IDENTIFIED BY '$DB_PASS_ROOT';</code> this command grants all privileges on the database to the root user, allowing root to access the database from any host. The password for the root user is specified by <code>$DB_PASS_ROOT.</code></li>
<li><code>SET PASSWORD FOR 'root'@'localhost' = PASSWORD('$DB_PASS_ROOT');</code> this command changes the password for the root user when connecting from localhost to the password specified by <code>$DB_PASS_ROOT</code>.</li>
<li><code>EOF</code> this marks the end of the "here document" started earlier, indicating that the SQL commands are complete.</li>
<li><code>sleep 5</code> this command pauses the script for 5 seconds. This can be useful to ensure that the MariaDB service has fully started and is ready to accept connections before proceeding.</li>
<li><code>service mariadb stop</code> this command stops the MariaDB service. It's typically used to clean up after the script has completed its tasks.</li>
<li><code>exec $@</code> this command restart the server with the command passed as argument in the Dockerfile.</li>
</ol>

<h3>1.1.4. Access the container</h3>

Now, you can build your container and tests it. Inside the folder mariadb, run the following command. build is the command to build the image, and -t is the tag name and mariadb is the name and . indicates that the Dockerfile is in the current folder.

<code>docker build -t mariadb .</code>

Then, run the container with the following command. run is the command to run the container, -d is the flag to run the container in background, and mariadb is the name of the image that we want to run.

<code>docker run -d mariadb</code>

<code>docker ps -a</code>

With the ID copied, run the next command to get inside the container. exec is the command to execute a command inside the container, -it is the flag to run the command in interactive mode, and ID is the ID of the container and /bin/bash is the command that we want to execute, in this case we want to use its terminal.

<code>docker exec -it $ID /bin/bash</code>

<code>mysql -u $DB_USER -p $DB_NAME</code>

if you see the the prompt <code>MariaDB [$DB_NAME]></code> it means that all is ok. Too see the tables, run the following command. For now, we don't have any table, so it'll return an empty set, But at the end of the project, it'll have some tables created by wordpress.

<code>SHOW TABLES;</code>

Now, to exit mysql, run exit then run exit again to exit the container. So it's all working, then we'll clean our container test. To stop the container, remove it and the image run the following commands.

<code>docker rm -f $(docker ps -aq) &&  docker rmi -f $(docker images -aq)</code>

<h2>1.2. Wordpress</h2>

WordPress is a free, <strong>open-source</strong> content management system (CMS) that allows users to create and manage websites and blogs without needing to know how to code. It powers over 42.7% of all websites on the internet, making it the most popular CMS available. The platform is highly customizable, with thousands of themes and plugins available to extend its functionality. WordPress is known for its simplicity, making it accessible even to beginners. It allows for quick publishing and building of website content, and it's extendable with plugins for added features. The platform is also highly secure, with a vigilant security team and a community that continuously works on improving its security.

<h3>1.2.1. Dockerfile</h3>

<ol>
<li>Use debian 11 (bullseye) image.</li>
<li>Indicate that this container will be listening on port 9000.</li>
<li>Set a variable to use in the next commands.</li>
<li>Update and install the ca-certificates, php7.4-fpm, php7.4-mysql, wget and tar only.</li>
	<ul>
	<li><code>apt update</code> update the package list for upgrades and new package installations.</li>
	<li><code>apt install -y</code>install the the specified packages. The <code>-y</code>flag automatically answers 'yes' to prompt and run non-interactively, which is great for scripting or automation.</li>
	<li><code>--no-install-recommends</code>Do not install recommended packages, which are packages that can enhances the functionatily of the installed packages but are not essential.</li>
	<li><code>--no-install-suggests</code>Similar to previous commands, prevents the installation of suggested packages.</li>
	<li><code>rm -rf /var/lib/apt/lists/*</code>Removes all the files in the /var/lib/apt/lists. Ensure that apt update will fetch fresh package lists the next time it's run.</li>
	</ul>
<li></li>
<li>After the php installation, it's running, so we need to stop it to change the configuration file</em>.</li>
<li>Copy the configuration file to the php folder, then change some values in the php config files.</li>
<li>Download the wordpress CLI, change its permissions and move it to the bin/wp folder.</li>
<li>Create some folders needed by the wordpress files and change its owner to www-data user.</li>
<li>sets the default command to run when the container starts. It executes the setup script with arguments to start PHP-FPM 7.4 without daemonizing, which is suitable for Docker environments.</li>
</ol>

<h3>1.2.2. wwww.conf</h3>

It's a default file without the commented lines. This configuration is <em>optimized for a dynamic environment</em> where the load on the PHP-FPM pool can vary significantly. It ensures that there are always enough child processes to handle incoming requests without using excessive resources.

<ol>
<li><code>[www]</code> is the name of the pool.</li>
<li><code>group = www-data</code> specifies the user under which the pool will run. This is typically the user that the web server runs as, ensuring that the PHP processes have the correct permissions to access necessary files and directories.</li>
<li><code>user = www-data</code> specifies the group under which the pool will run. This is usually the same as the user for consistency and security reasons.</li>
<li><code>listen = 9000</code> defines the address on which the pool will listen for incoming requests. This is typically a Unix socket or a TCP port.</li>
<li><code>pm = dynamic</code> sets the process manager to "dynamic", which means the number of child processes is set dynamically based on the following directives. This is a flexible approach that adjusts the number of child processes to the current load.</li>
<li><code>pm.max_children = 30</code> specifies the maximum number of child processes that can be alive at the same time. This is the upper limit for the number of concurrent PHP processes.</li>
<li><code>pm.start_servers = 3</code> defines the number of child processes created on startup. This is the initial number of processes that will be started when the pool is initialized.</li>
<li><code>pm.min_spare_servers = 3</code> sets the minimum number of idle child processes. If the number of idle processes is less than this number, some children will be created. This ensures that there are always a sufficient number of idle processes ready to handle requests.</li>
<li><code>pm.max_spare_servers = 10</code> specifies the maximum number of idle child processes. If the number of idle processes is greater than this number, some children will be killed. This prevents the pool from using too many resources when there are fewer requests.</li>
<li><code>pm.max_requests = 1000</code> sets the maximum number of requests that a child process should serve before it is respawned. This helps to prevent memory leaks and other issues that can accumulate over time.</li>
<li><code>pm.status_path = /status</code> defines the path for the status page. This is used by the PHP-FPM status page to provide information about the pool's status.</li>
<li><code>clear_env = no</code> by default, PHP-FPM clears the environment for security reasons. Setting this to "no" prevents PHP-FPM from clearing the environment, which can be useful if you need to pass certain environment variables to your PHP scripts.</li>
</ol>

<h3>1.2.3. wp-config.php</h3>

This is the wp-config.php file, which is a crucial part of a WordPress installation. This file contains the base configuration for WordPress, including database settings, secret keys, and other essential configurations.

<ol>
<li><strong>Database Settings</strong> that define the connection details for your WordPress database. They use the <code>getenv</code> function to retrieve environment variables from the <strong>.env file</strong>, which is a common practice for managing sensitive information like database credentials securely.</li>
<li><strong>Secret Keys and Salts</strong> are used for security purposes, such as encrypting user cookies and passwords. WordPress provides a service to generate these keys and salts.</li>
<li><strong>Database Table Prefix</strong> This is a prefix added to the names of all database tables used by WordPress. It's useful for allowing multiple WordPress installations to share the same database.</li>
<li><strong>ABSPATH</strong> This constant defines the absolute path to the WordPress directory. It's used by WordPress to include files and to construct URLs.</li>
<li><strong>WP_DEBUG</strong> This constant enables or disables WordPress's debugging mode. When enabled, it displays PHP errors, warnings, and notices, which can be helpful during development but should be disabled on a live site to prevent exposing sensitive information.</li>
<li><strong>Custom Values</strong> The file allows for custom values to be added between the comments. This is where you can add additional configuration settings or custom code.</li>
<li><strong>Require wp-settings.php</strong> This line includes the wp-settings.php file, which sets up the WordPress environment. It's a crucial step in the WordPress bootstrapping process.</li>
</ol>

<h3>1.2.4. setup.sh</h3>

This script is designed to automate the setup of a WordPress site using WP-CLI, a command-line interface for WordPress.

<ol>
<li><code>chown -R www-data:www-data /var/www/inception/</code> changes the ownership of the <code>/var/www/inception/</code> directory and all its contents to the <code>www-data user</code> and group. </li>
<li><code>if [ ! -f "/var/www/inception/wp-config.php" ]; then</code> checks if the <code>wp-config.php<code> file does not exist in the <code>/var/www/inception/<code> directory. If it doesn't, the script proceeds to the next command.</li>
<li><code>mv /tmp/wp-config.php /var/www/inception/</code> If the <code>wp-config.php</code> file does not exist, this command moves it from the <code>/tmp</code> directory to the <code>/var/www/inception/</code> directory. </li>
<li><code>sleep 10</code> pauses the script for 10 seconds. It's used to ensure that all previous commands have completed before proceeding.</li>
<li><code>wp --allow-root --path="/var/www/inception/" core download || true</code> uses WP-CLI to download the latest version of WordPress to the <code>/var/www/inception/</code> directory. The <code>--allow-root</code> flag allows the command to be run as the root user, and the <code>--path</code> option specifies the installation directory. The <code>|| true</code> part ensures that the script continues even if the command fails.</li>
<li><code>if ! wp --allow-root --path="/var/www/inception/" core is-installed; then</code> checks if WordPress is not already installed in the <code>/var/www/inception/ </code>directory. If it's not installed, the script proceeds to the next command.</li>
<li><code>wp --allow-root --path="/var/www/inception/" core install ...</code> If WordPress is not installed, this command uses WP-CLI to install WordPress with the specified parameters, such as the site URL, title, admin user, password, and email from the <strong>.env</strong>.</li>
<li><code>if ! wp --allow-root --path="/var/www/inception/" user get $WP_USER; then</code> checks if a user with the specified username <code>$WP_USER</code> does not exist in the WordPress installation. If the user does not exist, the script proceeds to the next command.</li>
<li><code>wp --allow-root --path="/var/www/inception/" user create ...</code> If the user does not exist, this command uses WP-CLI to create a new user with the specified username, email, password, and role from the <strong>.env</strong>.</li>
<li><code>wp --allow-root --path="/var/www/inception/" theme install raft --activate</code> uses WP-CLI to install and activate the <code>"Raft"</code> theme in the WordPress installation.</li>
<li><code>exec $@</code> executes any additional commands passed to the script. It's often used in Docker containers to run the main process of the container.</li>
</ol>

<h3>1.2.5 Access the container</h3>

Go to the wordpress folder and run the following command.

<code>docker build -t wordpress .</code>

<code>docker run -d wordpress</code>

<code>docker ps -a</code>

<code>docker exec -it copiedID /bin/bash</code>


Now, you are inside the container. Run the following command to check if the wordpress files are there. The sleep here is used to give time to the container to download the files.

<code>sleep 30 && ls /var/www/inception/</code>

If you see the wordpress files, it means that all is ok. Exits the container and let's clean our container test.

<code>docker rm -f $(docker ps -aq) &&  docker rmi -f $(docker images -aq)</code>

<h2>1.3. NGINX</h2>

<h3>1.3.1. The Dockerfile</h3>

<ol>
<li>Use debian 11 (bullseye) image.</li>
<li>Indicate that this container will be listening on port 443.</li>
<li>Update and install the nginx and openssl only.</li>
	<ul>
	<li><code>apt update</code> update the package list for upgrades and new package installations.</li>
	<li><code>apt install -y</code>install the the specified packages. The <code>-y</code>flag automatically answers 'yes' to prompt and run non-interactively, which is great for scripting or automation.</li>
	<li><code>--no-install-recommends</code>Do not install recommended packages, which are packages that can enhances the functionatily of the installed packages but are not essential.</li>
	<li><code>--no-install-suggests</code>Similar to previous commands, prevents the installation of suggested packages.</li>
	<li><code>rm -rf /var/lib/apt/lists/*</code>Removes all the files in the /var/lib/apt/lists. Ensure that apt update will fetch fresh package lists the next time it's run.</li>
	</ul>
<li>Use the <code>ARG</code> command to use variable from the <em>.env file.</em></li>
<li>Create the folder for the certificates and generates them.
	<ul>
	<li><code>openssl req</code> tells <strong>OpenSSL</strong> to create a certificate signing request or a self-signed certificate.</li>
	<li><code>-newkey rsa:4096</code> creates a new private key and a new <strong>Certificate signing request</strong> (CSR) using RSA encryption with a key size of 4096 bits.It is a standard between security and perfomance.</li>
	<li><code>-x509</code> output a self-signed certificate request instead of a certificate request.</li>
	<li><code>-sha256</code> specifies the hash algorithm to be used for the certificate's signature. The <strong>SHA-256</strong> is a secure hash algorithm that is widely used for digital signatures.</li>
	<li><code>-days 365</code> set the validity period of the certificate to 365 days. </li>
	<li><code>-nodes</code> tells <strong>OpenSSL</strong> not to encrypt the private key with a passphrase. This is useful for automation.</li>
	<li><code>-subj</code> will be used to set the certificate informations.</li>
	</ul>
<li>Copy the configuration files to the container and complete the <em>server.conf file</em> with variables that will be passed by the <em>.env file</em>.</li>
<li>Create the folder the wordpress files and change its owner to <code>www-data</code> user. This user is a special user account that the web server uses to run its processes. This user is typically used to ensure that the web server has the necessary permissions to read, write, and execute files within the web server's document root directory, where WordPress is installed.</li>
<li>Start the nginx server in the foreground. This setup is considered a best practice for Docker containers, as it simplifies container management and ensures that the container's main process is the NGINX server. However, it's important to note that when running NGINX with <code>daemon off;</code>, the non-stop upgrade feature is not available. This means that you cannot use the <code>nginx -s reload</code> command to reload the configuration without stopping and starting the NGINX process</li>
</ol>

<h3>1.3.2. server.conf</h3>

This Nginx configuration document is designed to set up a secure and efficient web server for a specific website, ensuring that it only accepts HTTPS connections and uses TLSv1.2 for encryption. Here's a line-by-line explanation of what each part of the document does:

<ol>
<li><code>listen 443 ssl;</code> && <code>listen [::]:443 ssl</code> are telling <strong>Nginx</strong> to listen on port 443 (the standard port for HTTPS traffic) for both IPV4 and IPV6 addresses.</li>
<li><code>ssl_protocols TLSv1.2</code> specifies that only TSLv1.2 should be used for the SSL connection. <strong>TLS 1.2</strong>, or Transport Layer Security version 1.2, is a cryptographic protocol designed to provide secure communication over a network. It is the successor to SSL (Secure Sockets Layer) and its use in securing web traffic, email, and other online services helps protect sensitive information from eavesdropping and unauthorized access.We both the 1.2 and 1.3 versions due to compatibility reasons, since not all servers and browsers support TSLv1.3</li>
<li><code>server_name</code> routes request to this server block based on the <code>Host</code> header of the incoming request.</li>
<li><code>root /var/www/inception/;</code> && <code>index index.php index.html;</code> sets the root directory for the website and specifies the default files to serve when a directory is requested.</li>
<li><code>location /</code> block defines how to handle requests for the root directory and all subdirectories. </li>
<li><strong>FastCGI</strong> is used to translate client requests for an application server that <em>does not</em> or <em>should not</em> handle client request directly. It is used to efficiently interface with a server that processes requests for dynamic content. Unlike Apache, which can handle PHP processing directly with the use of the <code>mod_php</code> module, Nginx must rely on a separate PHP processor to handle PHP requests. Most often, this processing is handled with <code>php-fpm</code>, a PHP processor that has been extensively tested to work with Nginx.</li>
<li><strong>robots.txt</strong> is a text file that webmasters create to instruct <em>web robots</em> (typically search engine robots) how to crawl pages on their website. It is part of the <strong>Robots Exclusion Protocol</strong> (REP), a set of web standards that regulate how robots crawl the web, access and index content, and serve that content to users.</li>
<li><strong>Favicon</strong> short for <em>"favorite icon"</em> is a small icon that represents a website or brand and is displayed in various places on the web, such as the browser's address bar, page tabs, bookmarks menu, and search engine results pages.</li>
</ol>

At the end, the file has missing lines that will be completed in the Dockerfile. These are the information about the certificates that will be passed by the .env file. It's important that we never public files with confidential information.

<h3>1.3.3. nginx.conf</h3>

This Nginx configuration file is designed to set up a web server with specific settings for handling requests, logging, and including additional configuration files. Here's a line-by-line explanation:

<ol>
<li><code>user www-data;</code> specified that Nginx should runs as the <strong>www-data</strong> user, a common practice for security reasons. It limits the potential damages as it limits the permission of the Nginx process to those of the www-data user.</li>
<li><code>worker_processes auto;</code> tells Nginx to autocatically determine the optimal number of worker processes based on the number of CPU core available. Each worker process is a <em>single-threaded process</em> responsible for handling client requests. The optimal number of worker processes depends on the nature of the work Nginx is doing and the hardware it's running on. If Nginx is performing CPU-intensive tasks such as SSL processing or gzip compression, you might set it equal to the number of CPU cores. This allows Nginx to utilize all available CPU cores for processing, improving performance.</li>
<li><code>error_log /var/log/nginx/error.log warn;</code> configures the <em>error log file</em> location and set the log level to <strong>warn</strong>. The error log records the errors that occurs while Nginx is running.</li>
<li><code>pid /var/run/nginx.pid;</code> specifies the files where Nginx whill write its <em>Process ID</em> (PID), which can be useful for managing the Nginx process, such as stopping or restarting the server.</li>
<li><code>worker_connections 1024;</code> sets the maximum number of simultaneous connections that each worker process can handle. It is located inside the <code>events</code> context, which contains directives that affect how Nginx handles connections.</li>
<li><code>include /etc/nginx/mime.types;</code> includes the <strong>MIME type</strong> which maps files extensions to their corresponding MIME types. A MIME (Multipurpose Internet Mail Extensions) is a standard way to indicate the nature and format of a document, file, or assortment of bytes. They are essential for web browsers and servers to understand how to handle different types of content. </li>
<li><code>default_type application/octet-stream;</code> set the default <strong>MIME type</strong> if the file type is not recognized.</li>
<li><code>log_format main</code> defines a <em>custom log</em> format named main. This format includes various pieces of information about each request, such as the client IP address, request time, and user agent.</li>
<li><code>access_log /var/log/nginx/access.log main;</code> specifies the access log file location and uses the main log format.</li>
<li><code>sendfile on;</code> enables the use of <code>sendfile()</code>, a system call that allows Nginx to serve files more efficiently by transferring data directly from the file system to the network</li>
<li><code>keepalive_timeout 65;</code> sets the timeout for keep-alive connections with clients. This is the time Nginx will wait for a new request on a keep-alive connection before closing it.</li>
<li><code>server wordpress:9000;</code> specifies that request should be passed to a server named <strong>wordpress</strong> on <strong>port 9000</strong>. This is located inside the <code>upstream block</code>, named <code>php7.4-fpm</code>, which is used to define a server that Nginx can pass requests to when processing php files.</li>
<li><code>include /etc/nginx/conf.d/*.conf;</code> includes all configuration files in the <code>/etc/nginx/conf.d/</code> directory. This is a common practice for organizing server block configurations for different sites or applications.</li>
<li><code>server_tokens off;</code> disables the display of the Nginx version number in error messages and the Server response header. This is a security measure to prevent potential attackers from determining the version of Nginx in use.</li>
</ol>

<h3>1.3.4. Access the container</h3>

Go to the nginx folder and run the following command. We don't run the container because it need to connect with the wordpress container. And we'll do it with the compose file. We'll the built command only to check if the image is ok then we'll remove it.

<code>docker build -t nginx .</code>

<code>docker images</code>

<code>docker rmi -f nginx</code>


<h1>2. Docker-compose</h1>

Docker Compose is a tool designed to simplify the definition and management of multi-container Docker applications. It allows developers to define their application's services, networks, and volumes in a single YAML file, making it easier to manage and replicate the application environment.

<h2>2.1. docker-compose.yml</h2>

The Docker Compose configuration provided outlines a multi-container application setup that includes MariaDB, WordPress, and Nginx containers, along with volume and network configurations.

<ol>
<li><strong>MariaDB Container</strong>  This is the only container that no depend on the others, so its the first to be created. Its fields are self-explanatory. <em>Build</em> is where the Dockerfile is, <em>volumes</em> is where the database files will be saved in the container, <em>networks</em> is the network that the container will use, <<em>init</em> is used to run the setup.sh script, <em>restart</em> is used to restart the container if it fails, and <em>env_file</em> is the file that contains the variables that will be used in the container.</li>
<li><strong>The wordpress service</strong> is similar to the mariadb service, but it has a <em>depends_on</em> field that indicates that the wordpress container will only start after the mariadb container is running and volume and the build path are different.</li>
<li><strong>The NGINX service</strong> depends on the wordpress service and has a <em>ports field</em> that indicates that the container will be listening on port <code>443</code>. The build field beyond the path, it has some arguments that will be used in the Dockerfile given by the .env file.</li>
<li><strong>The volumes</strong> define the local host folder that will be used to save the database and the wordpress files. This volumes will work like a shared folder between the host and the containers.</li>
<li><strong>The networks</strong> define the network that the containers will use to communicate with each other. This is like a virtual switch that will connect the containers.</li>
</ol>

<h2>2.2. .env</h2>

This file will hold every variables we'll use in the docker-compose file as credential.

<h2>2.3. Test the docker-compose</h2>

Simply run the makefile.

<h1>3. Makefile</h1>

Install the hostsed package to make easy the way to put our host url in the /etc/hosts file. Run the following command:

<code>sudo apt-get install hostsed</code>

> hostsed is:
>> Tool for editing hosts file(default /etc/hosts), you can add or delete a DNS entry via command line shell. Hotsed provides an idemponent command line experience with its ‘add’ and ‘delete’ commands avoiding duplicated or missing entries in the hosts file.

In summary, using hostsed in your Docker Compose Makefile can help manage DNS entries more efficiently, ensuring consistency, streamlining your development workflow, and improving collaboration and reproducibility.

<h1>4. The VM</h1>

<h2>4.1. VM creation</h2>

<ol>
<li>Download debian image. <a href=" https://cdimage.debian.org/cdimage/archive/11.7.0/amd64/iso-cd/debian-11.7.0-amd64-netinst.iso"> Try this link</a></li>
<li>Open the VirtualBox and create a new VM as Linux Debian 64 bits.</li>
<li>Set the RAM to 4096 MB</li>
<li>Create a dynamic VDI with at least 30 GB</li>
<li>Go to the VM settings > System > Motherboard and set the boot order to Optical, Hard Disk, Network.</li>
<li>Then at processor tab, set the number of processors to 4.</li>
<li>In the display menu, set the video memory to 128 MB.</li>
<li>In the audio menu, disable the audio.</li>
<li>In the network menu, set the network to NAT.</li>
<li>In the storage, select the CD icon and select the debian image that you downloaded.</li>
<li>Now start your VM.</li>
</ol>

<h2>4.2. Debian installation</h2>

<ol>
<li>Select install</li>
<li>then follow the normal installation steps, choosing region, user, password, etc. Nothing special here.</li>
<li>In the partition menu, select the guided - use entire disk - LVM</li>
<li>After that, select separate var/ tmp/ home/ partitions and Confirm it.</li>
<li>In the software selection, select only XFCE, Webserver, SSH server and standard system utilities.</li>
<li>In the GRUB menu, select yes and select the disk that you created.</li>
<li>At the end, your VM will reboot with the debian installed.</li>
</ol>

<h2>4.3. VM setup</h2>

<h3>4.3.1. Add user as Sudo</h3>

Log in as root. Access the sudoers file via <code>nano /etc/sudoers</code>, then add the user after the root. Now, reboot the VM.

<h3>4.3.2. Enable the shared folder</h3>

<ol>
<li>In your main PC, create a folder in your home directory called shared . This folder will be used to share files between your main PC and the VM.</li>
<li>In the VirtualBox settings > Shared Folders, add a new shared folder with the name shared and the path to the folder that you created in your main PC and check the auto-mount and make permanent options.</li>
<li>Now, in the VM, at the VirtualBox menu > Devices > select insert Guest Additions CD image.</li>
<li>Open the terminal in the CD folder and run the following command.<code>sudo sh VBoxLinuxAdditions.run \sudo reboot</code></li>
<li>Add your user to the vboxsf group and define your user as owner of the shared folder. <code>sudo usermod -a -G vboxsf your_user \sudo chown -R your_user:users /media/</code></li>
<li>Logout and login again to apply the changes. Now, you can see the shared folder in the <code>/media</code> folder as a external device.</li>
</ol>

<h3>4.3.3. Install Docker and Docker-compose</h3>

Prepare the docker repository installation

>//Add Docker's official GPG key:
>sudo apt-get update
>sudo apt-get install ca-certificates curl gnupg
>sudo install -m 0755 -d /etc/apt/keyrings
>curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
>sudo chmod a+r /etc/apt/keyrings/docker.gpg
>
>//Add the repository to Apt sources:
>echo \
>  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
> "$(. /etc/os-release && echo "bullseye")" stable" | \
> sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
>sudo apt-get update

Then install docker and plugins

>sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

Now add your user to the docker group. It's important use the docker commands without sudo.

>sudo usermod -aG docker your_user
>su - your_user
>sudo reboot

Now check if the docker is working well with the following command:

>docker run hello-world

<h3>4.3.4. Install make and hostsed</h3>

>sudo apt-get install -y make hostsed

___
___

Et voila! Everything should be just fine.


___
<h1>Sources</h1>

<h2>Docker</h2>

<p><a href="https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-ubuntu-22-04">Install and use</a></p>
<p><a href="https://www.docker.com/resources/what-container/">What is a Docker Container</a></p>
<p><a href="https://docs.docker.com/get-started/08_using_compose/">How to Use Docker Compose</a></p>
<p><a href="https://docs.docker.com/compose/intro/features-uses/">Why Use Docker Compose</a></p>
<p><a href="https://www.freecodecamp.org/news/docker-vs-vm-key-differences-you-should-know/">Differences between a VM and a docker containers</a></p>

<h2>MariaDB</h2>

<p><a href="https://mariadb.org/about/">About MariaDB</a></p>
<p><a href="https://mariadb.com/kb/en/configuring-mariadb-with-option-files/">Configure MariaDB with Option files</a></p>
<p><a href="https://docs.bitnami.com/google-templates/infrastructure/mariadb/get-started/understand-default-config-mariadb/">Default MariaDB Configuration</a></p>
<p><a href="https://www.beekeeperstudio.io/blog/how-to-create-a-user-in-mariadb">A guide to Create an User in MariaDB</a></p>
<p><a href="https://phoenixnap.com/kb/how-to-create-mariadb-user-grant-privileges">How to Grant Privileges to an User</a></p>

<h2>Wordpress</h2>

<p><a href="https://kinsta.com/knowledgebase/what-is-wordpress/">What is Wordpress</a></p>
<p><a href="https://www.digitalocean.com/community/tutorials/php-fpm-nginx">Set up php-fpm and Nginx<</a></p>
<p><a href="https://solidwp.com/blog/wordpress-wp-config-php-file-explained/#:~:text=php%20file%20provides%20the%20base,WordPress%20database%20MySQL%20connection%20settings">wp-config.php File Explained</a></p>
<p><a href="https://wordpress.org/documentation/article/editing-wp-config-php/">Editing wp-config.php</a></p>


<h2>Nginx</h2>

<p><a href="https://nginx.org/en/docs/beginners_guide.html">Beginner's guide to Nginx</a></p>
<p><a href="https://www.freecodecamp.org/news/the-nginx-handbook/">Nginx Handbook</a></p>
<p><a href="https://www.digitalocean.com/community/tutorials/understanding-and-implementing-fastcgi-proxying-in-nginx">Nginx and FastCGI proxying</a></p>
<p><a href="https://developers.google.com/search/docs/crawling-indexing/robots/intro">Robots.txt</a></p>
<p><a href="https://cheapsslsecurity.com/blog/what-is-tls-1-2-a-look-at-the-secure-protocol/">TSLv1.2</a></p>
<p><a href="https://www.a10networks.com/glossary/key-differences-between-tls-1-2-and-tls-1-3/#:~:text=The%20differences%20between%20TLS%201.2,continued%20suitability%20for%20enterprise%20use.">TLSv1.2 or TLSv1.3</a></p>
<p><a href="https://developer.mozilla.org/en-US/docs/Web/HTTP/Basics_of_HTTP/MIME_Types">MIME types</a></p>
<p><a href="https://www.digitalocean.com/community/tutorials/understanding-the-nginx-configuration-file-structure-and-configuration-contexts">Nginx configurations files</a></p>

<h2>Misc</h2>
<p><a href="https://github.com/socrateslee/hostsed">Hostsed and the 3 hours quests to find out what this fucking does</a></p>
<p><a href="https://docs.docker.com/engine/install/debian/">Install docker on debian 11</a></p>
<p><a href="https://github.com/waltergcc/42-inception/tree/main">Ma Muse</a></p>