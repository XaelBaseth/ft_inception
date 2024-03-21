<h1>1. The Containers</h1>

Docker containers are a form of operating system-level virtualization that allow developers to package an application with all of its dependencies into a standardized unit for software development. How Docker Containers Work:

Containers are built from Docker images, which are read-only templates with instructions for creating a Docker container. When a container is run from an image, it adds a read-write layer on top of the image, which is where the application and its dependencies are stored. Containers are isolated from each other and from the host system, ensuring that they do not interfere with each other or with the host system. Docker uses the host system's kernel, which means containers can start much faster than VMs and use fewer resources.

In summary, Docker containers are best for deploying lightweight, scalable applications and microservices, while VMs are better suited for scenarios requiring strong isolation, security, and compatibility with different operating systems. The choice between Docker containers and VMs depends on the specific needs of the application and the environment in which it will be deployed.

<h2>1.1. MariaDB</h2>

MariaDB Server is one of the most popular database servers in the world, known for its performance, stability, and openness. It is part of most cloud offerings and the default in most Linux distributions. It was created by some of the original developers of MySQL, who forked it due to concerns over its acquisition by Oracle Corporation in 2009. MariaDB aims to <strong>maintain high compatibility with MySQL</strong>, including exact matching with MySQL APIs and commands, allowing it to function as a drop-in replacement for MySQL in many cases. MariaDB is developed as <strong>open-source software</strong> and provides an SQL interface for accessing data. It is used by notable organizations such as Wikipedia, WordPress.com, and Google, and is included by default in several Linux distributions and BSD operating systems.

<h3>1.1.1. Dockerfile</h3>

<ol>
<li><code>FROM alpine:3.18</code> specifies the base image for the Docker container.</li>
<li><code>RUN apk update && apk upgrade &&\</code> updates the package index and upgrades all installed packages to their latest versions.</li>
<li><code>apk add mariadb mariadb-client</code> installs MariaDB and its client.</li>
<li><code>COPY ./conf/configure-mariadb.sh /tmp/configure-mariadb.sh</code> copies a shell script named <code>configure-mariadb.sh</code> from the <code>conf</code> directory in the host machine to the /tmp directory inside the Docker container.</li>
<li><code>RUN chmod +x /tmp/configure-mariadb.sh</code> makes the script executable.</li>
<li><code>ENTRYPOINT [ "sh", "/tmp/configure-mariadb.sh" ]</code> sets the entry point of the Docker container to the <code>configure-mariadb.sh</code> script.</li>
</ol>

<h3>1.1.2. configure-mariadb.sh</h3>

This script is designed to automate the process of starting a MariaDB service, creating a database and users with specific privileges, and then stopping the service. Let's break down each line:
<ol>
<li><code>#!/bin/sh</code> specifies the interpreter for the script.</li>
<li><code>echo "[DB config] Configuring MariaDB..."</code> prints a message indicating the start of the MariaDB configuration process.</li>
<li><code>if [ ! -d "/run/mysqld" ]; then</code> checks if the directory <code>/run/mysqld</code> does not exist.</li>
<li><code>echo "[DB config] Granting MariaDB daemon run permissions..."</code> prints a message indicating that the script is granting permissions to the MariaDB daemon.</li>
<li><code>mkdir -p /run/mysqld</code> Creates the directory <code>/run/mysqld</code> if it doesn't already exist.</li>
<li><code>chown -R mysql:mysql /run/mysqld</code> changes the ownership of the /run/mysqld directory.</li>
<li><code>fi</code> ends the if statement.</li>
<li><code>if [ -d "/var/lib/mysql/mysql" ]</code> checks if the directory <code>/var/lib/mysql/mysql</code> exists, indicating that MariaDB has already been configured.</li>
<li><code>echo "[DB config] MariaDB already configured."</code> prints a message indicating that MariaDB is already configured.</li>
<li><code>else</code> if the directory does not exist, the script proceeds with the MariaDB configuration.</li>
<li><code>echo "[DB config] Installing MySQL Data Directory..."</code> prints a message indicating the start of the MySQL data directory installation.</li>
<li><code>chown -R mysql:mysql /var/lib/mysql</code> changes the ownership of the <code>/var/lib/mysql</code> directory and its contents to the mysql user and group.</li>
<li><code>mysql_install_db --basedir=/usr --datadir=/var/lib/mysql --user=mysql --rpm > /dev/null</code> installs the MySQL data directory. The <code>--basedir</code> option specifies the base directory of the MariaDB installation, <code>--datadir</code> specifies the data directory, <code>--user</code> specifies the user to run the command as, and <code>--rpm</code> is used for compatibility with RPM-based systems. The output is redirected to <code>/dev/null</code> to suppress it.</li>
<li><code>echo "[DB config] MySQL Data Directory done."</code> prints a message indicating that the MySQL data directory installation is complete.</li>
<li><code>echo "[DB config] Configuring MySQL..."</code> prints a message indicating the start of the MySQL configuration.</li>
<li><code>TMP=/tmp/.tmpfile</code> sets a temporary file path for the MySQL configuration commands.</li>
<li><code>/usr/bin/mysqld --user=mysql --bootstrap < ${TMP}</code> starts the MariaDB server in bootstrap mode, executing the SQL commands from the temporary file.</li>
<li><code>rm -f ${TMP}</code> removes the temporary file after it has been used.</li>
<li><code>echo "[DB config] MySQL configuration done."</code> </li>
<li><code></code> prints a message indicating that the MySQL configuration is complete.</li>
<li><code>fi</code> ends the if statement.</li>
<li><code>echo "[DB config] Allowing remote connections to MariaDB"</code>  prints a message indicating that the script is configuring MariaDB to allow remote connections.</li>
<li><code>echo "[DB config] Starting MariaDB daemon on port 3306."</code> prints a message indicating that the MariaDB daemon is being started.</li>
<li><code>exec /usr/bin/mysqld --user=mysql --console</code> starts the MariaDB server in the foreground, allowing it to receive signals from Docker.</li>
</ol>

<h3>1.1.3. Access the container</h3>

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
<li><code>FROM alpine:3.18</code> specifies the base image for the Docker container.</li>
<li><code>RUN apk update && apk upgrade &&\</code> updates the package index and upgrades all installed packages to their latest versions.</li>
<li><code>apk add php81 php81-fpm php81-bcmath php81-bz2 php81-calendar php81-cli php81-ctype \ apk add mariadb-client</code> installs the PHP8.1 and a variety of extension necessary for Wordpress.</li>
<li><code>RUN sed -i 's/listen = 127.0.0.1:9000/listen = 9000/g' /etc/php81/php-fpm.d/www.conf</code> modifies the PHP-FPM configuration to listen on all interfaces.</li>
<li><code>RUN apk add curl && curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && chmod +x wp-cli.phar && mv wp-cli.phar /usr/bin/wp-cli.phar</code> install <code>curl</code> and downloads and move the <em>WP-CLI tools</em>.</li>
<li><code>COPY ./conf/configure-wordpress.sh /tmp/configure-wordpress.sh</code> copies a shell script named <code>configure-wordpress.sh</code> from the conf directory in the host machine to the <code>/tmp</code> directory inside the Docker container.</li>
<li><code>RUN chmod +x /tmp/configure-wordpress.sh</code> makes the script executable.</li>
<li><code>WORKDIR /var/www/html/wordpress</code> sets the working directory inside the container.</li>
<li><code>ENTRYPOINT [ "sh", "/tmp/configure-wordpress.sh" ]</code> sets the entry point of the Docker container to the <code> configure-wordpress.sh</code> script.</li>
</ol>

<h3>1.2.2. configure-wordpress.sh</h3>

This script is designed to automate the setup of a WordPress site using WP-CLI, a command-line interface for WordPress.

<ol>
<li><code>#!/bin/sh</code> cspecifies the interpreter for the script.</li>
<li><code>echo "[WP config] Configuring WordPress..."</code> prints a message indicating the start of the WordPress configuration process.</li>
<li><code>echo "[WP config] Waiting for MariaDB..."</code> prints a message indicating that the script is waiting for MariaDB to become accessible.</li>
<li><code>while ! mariadb -h${DB_HOST} -u${WP_DB_USER} -p${WP_DB_PASS} ${WP_DB_NAME} &>/dev/null; do</code> starts a loop that attempts to connect to the MariaDB database using the provided host, user, password, and database name. The loop continues until a successful connection is made. The output of the command is redirected to <code>/dev/null</code> to suppress it.</li>
<li><code>sleep 3</code> pauses the script for 3 seconds before attempting to connect to MariaDB again.</li>
<li><code>done</code> ends the loop.</li>
<li><code>echo "[WP config] MariaDB accessible."</code> prints a message indicating that MariaDB is accessible.</li>
<li><code>WP_PATH=/var/www/html/wordpress</code> sets the path where WordPress files will be located.</li>
<li><code>if [ -f ${WP_PATH}/wp-config.php ]</code> checks if the wp-config.php file exists in the specified WordPress path..</li>
<li><code>echo "[WP config] WordPress already configured."</code> prints a message indicating that WordPress is already configured.</li>
<li><code>echo "[WP config] Setting up WordPress..."</code> prints a message indicating the start of the WordPress setup process.</li>
<li><code>wp-cli.phar cli update --yes --allow-root</code> updates WP-CLI to the latest version. The <code>--yes</code> flag automatically confirms the update, and <code>--allow-root</code> allows the command to be run as the root user.</li>
<li><code>wp-cli.phar core download --allow-root</code> downloads the latest version of WordPress.</li>
<li><code>echo "[WP config] Creating wp-config.php..."</code> prints a message indicating that the <code>wp-config.php</code> file is being created.</li>
<li><code>wp-cli.phar config create --dbname=${WP_DB_NAME} --dbuser=${WP_DB_USER} --dbpass=${WP_DB_PASS} --dbhost=${DB_HOST} --path=${WP_PATH} --allow-root</code> creates the <code>wp-config.php</code> file with the specified database name, user, password, host, and path.</li>
<li><code>wp-cli.phar core install --url=${NGINX_HOST}/wordpress --title=${WP_TITLE} --admin_user=${WP_ADMIN_USER} --admin_password=${WP_ADMIN_PASS} --admin_email=${WP_ADMIN_EMAIL} --path=${WP_PATH} --allow-root</code> installs the WordPress core with the specified URL, title, admin user, password, email, and path.</li>
<li><code>p-cli.phar theme install blocksy --path=${WP_PATH} --activate --allow-root</code> installs and activates the Blocksy theme for WordPress.</li>
<li><code>wp-cli.phar theme status blocksy --allow-root</code> checks the status of the Blocksy theme.</li>
<li><code>fi</code> ends the if statement.</li>
<li><code>echo "[WP config] Starting WordPress fastCGI on port 9000."</code> prints a message indicating that the WordPress FastCGI process is being started.</li>
<li><code>exec /usr/sbin/php-fpm81 -F -R</code> starts the PHP FastCGI Process Manager (FPM) for PHP 8.1 in the foreground.</li>
</ol>

<h3>1.2.3 Access the container</h3>

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
<li><code>FROM alpine:3.18</code> specifies the base image for the Docker container.</li>
<li><code>RUN apk update && apk upgrade && apk add nginx &&</code> updates and upgrade the package index to their latest versions, then install <em>Nginx</em> a popular web server.</li>
<li><code>mkdir -p /var/www/html/</code> creates the directory <code>/var/www/html/</code></li>
<li><code>COPY ./conf/nginx.conf /etc/nginx/nginx.conf</code> copies a custom NGINX configuration file from the <code>conf</code> directory in the host machine to the <code>/etc/nginx</code> directory inside the Docker container. This allows for customizing the NGINX configuration.</li>
<li><code>COPY ./conf/default.conf /etc/nginx/http.d/default.conf</code> copies a custom default server block configuration file from the <code>conf</code> directory in the host machine to the <code>/etc/nginx/http.d</code> directory inside the Docker container. This allows for customizing the default server block.</li>
<li><code>RUN apk add openssl && openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/nginx-selfsigned.key -out /etc/ssl/certs/nginx-selfsigned.crt -subj "/C=FR/ST=Normandie/L=LeHavre/O=42Network/OU=42LeHavre/CN=inception"</code> installs OpenSSL and generate a self-signed certificate.</li>
<li><code>RUN adduser -D -g 'www' www && chown -R www:www /run/nginx/ && chown -R www:www /var/www/html/</code> creates a new user named <em>www</em> with the group <em>www</em> and changes the ownership of the directories <code>/run/nginx/</code> && <code>/var/www/html/</code></li>
<li><code>EXPOSE 443/tcp</code> sets the entry point of the Docker container to the nginx command.</li>
<li><code>CMD ["-g", "daemon off;"]</code> sets the default command to be executed when the container starts.</li>
</ol>

<h3>1.3.2. default.conf</h3>

This Nginx configuration document is designed to set up a secure and efficient web server for a specific website, ensuring that it only accepts HTTPS connections and uses TLSv1.2 for encryption. Here's a line-by-line explanation of what each part of the document does:

<ol>
<li><code>listen 443 ssl;</code> && <code>listen [::]:443 ssl</code> are telling <strong>Nginx</strong> to listen on port 443 (the standard port for HTTPS traffic) for both IPV4 and IPV6 addresses.</li>
<li><code>server_name</code> routes request to this server block based on the <code>Host</code> header of the incoming request.</li>
<li><code>root /var/www/inception/;</code> && <code>index index.php index.html;</code> sets the root directory for the website and specifies the default files to serve when a directory is requested.</li>
<li><code>ssl_protocols TLSv1.2</code> specifies that only TSLv1.2 should be used for the SSL connection. <strong>TLS 1.2</strong>, or Transport Layer Security version 1.2, is a cryptographic protocol designed to provide secure communication over a network. It is the successor to SSL (Secure Sockets Layer) and its use in securing web traffic, email, and other online services helps protect sensitive information from eavesdropping and unauthorized access.We both the 1.2 and 1.3 versions due to compatibility reasons, since not all servers and browsers support TSLv1.3</li>
<li><code>location /</code> block defines how to handle requests for the root directory and all subdirectories. </li>
	<ul>
		<li><code>fastcgi_split_path_info ^(.+\.php)(/.+)$;</code> splits the request URI into the script name and the path info.</li>
		<li><code>fastcgi_pass wordpress:9000;</code> passes PHP requests to a FastCGI server listening on wordpress:9000, which is typically a PHP-FPM service.</li>
		<li><code>fastcgi_index index.php;</code> specifies the default file to serve when a directory is requested.</li>
		<li><code>include fastcgi_params;</code> includes the FastCGI parameters file, which contains common FastCGI parameters.</li>
		<li><code>fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;</code> sets the <code>SCRIPT_FILENAME</code> parameter to the full path of the script to be executed.</li>
		<li><code>fastcgi_param PATH_INFO $fastcgi_path_info;</code> sets the <code>PATH_INFO</code> parameter to the path info extracted from the request URI.</li>
		<li><code>fastcgi_intercept_errors off;</code> disables intercepting of FastCGI errors by NGINX.</li>
		<li><code>fastcgi_buffer_size 16k;</code> sets the buffer size for reading the response from the FastCGI server.</li>
		<li><code>fastcgi_buffers 16 32k;</code></li>
		<li><code></code> sets the number and size of the buffers for reading the response from the FastCGI server.</li>
		<li><code>fastcgi_connect_timeout 120;</code> sets the timeout for establishing a connection with the FastCGI server.</li>
		<li><code>fastcgi_send_timeout 120;</code> sets the timeout for sending a request to the FastCGI server.</li>
		<li><code>fastcgi_read_timeout 120;</code> sets the timeout for reading a response from the FastCGI server.</li>
	</ul>
<li><code>}</code> ends the location block for PHP files.</li>
<li><code>location / {</code> starts a location block that matches all requests.</li>
<li><code>autoindex on;</code> enables directory listing.</li>
<li><code>try_files $uri $uri/ =404;</code> tries to serve the requested URI as a file, then as a directory, and finally returns a 404 error if neither is found.</li>
<li><code>}</code> ends the location block for all requests and the server block.</li>
</ol>

<h3>1.3.3. nginx.conf</h3>

This Nginx configuration file is designed to set up a web server with specific settings for handling requests, logging, and including additional configuration files. Here's a line-by-line explanation:

<ol>
<li><code>user www;</code> sets the user that NGINX will run as to www. This is a security measure to limit the permissions of the NGINX process.</li>
<li><code>worker_processes auto;</code> automatically sets the number of worker processes to the number of CPU cores available. This is important for handling multiple connections efficiently.</li>
<li><code>pcre_jit on;</code> enables the Just-In-Time (JIT) compilation for Perl Compatible Regular Expressions (PCRE), which can improve performance for regular expression matching.</li>
<li><code>error_log /var/log/nginx/error.log warn;</code> configures the error log file and sets the log level to warn. This means that only warnings and errors will be logged.</li>
<li><code>include /etc/nginx/modules/*.conf;</code> includes additional configuration files for NGINX modules. This allows for modular configuration and easier management of different settings.</li>
<li><code>events {</code> starts the events block, which contains directives related to handling connections.</li>
<li><code>worker_connections 1024;</code> sets the maximum number of simultaneous connections that each worker process can handle.</li>
<li><code>}</code> ends the events block.</li>
<li><code>http {</code> starts the http block, which contains directives related to HTTP and HTTPS traffic.</li>
<li><code>include /etc/nginx/mime.types;</code> includes the MIME types file, which maps file extensions to their MIME types.</li>
<li><code>default_type application/octet-stream;</code> sets the default MIME type for responses that do not match any file extension in the mime.types file.</li>
<li><code>server_tokens off;</code> disables the display of the NGINX version number in error messages. This is a security measure to hide version information.</li>
<li><code>client_max_body_size 1m;</code> sets the maximum allowed size of the client request body to 1 megabyte.</li>
<li><code>sendfile on;</code> enables the use of <code>sendfile()</code> for sending files to the client. </li>
<li><code>tcp_nopush on;</code> enables the TCP_NOPUSH option</li>
<li><code>ssl_protocols TLSv1.2 TLSv1.3;</code> specifies the SSL protocols to be used.</li>
<li><code>ssl_prefer_server_ciphers on;</code> configures NGINX to prefer the server's cipher suite over the client's when negotiating an SSL connection.</li>
<li><code>ssl_session_cache shared:SSL:2m;</code> configures the SSL session cache. This can improve performance by reusing SSL sessions.</li>
<li><code>ssl_session_timeout 1h;</code></li>
<li><code></code> sets the SSL session timeout to 1 hour. This determines how long an SSL session can be reused.</li>
<li><code>ssl_session_tickets off;</code> disables the use of SSL session tickets. This can improve security by preventing session resumption attacks.</li>
<li><code>gzip_vary on;</code> enables the <code>Vary: Accept-Encoding</code> response header when the gzip module is enabled.</li>
<li><code>map $http_upgrade $connection_upgrade {</code> starts a map block that sets the <code>$connection_upgrade</code> variable based on the $http_upgrade variable. This is used for handling WebSocket connections.</li>
<li><code>default upgrade;</code> the default action is to upgrade the connection.</li>
<li><code>'' close;</code> if the <code>$http_upgrade</code> variable is empty, the connection is closed.</li>
<li><code>}</code> ends the map block.</li>
<li><code>log_format main '$remote_addr - $remote_user [$time_local] "$request" '</code> defines a custom log format named main.</li>
<li><code>'$status $body_bytes_sent "$http_referer" '</code> continues the log format to include the response status, the number of bytes sent, and the referrer.</li>
<li><code>'"$http_user_agent" "$http_x_forwarded_for"';</code> completes the log format to include the user agent and the X-Forwarded-For header.</li>
<li><code>access_log /var/log/nginx/access.log main;</code> configures the access log file and uses the main log format.</li>
<li><code>include /etc/nginx/http.d/*.conf;</code> includes additional configuration files for HTTP server blocks. This allows for modular configuration and easier management of different server blocks.</li>
<li><code>}</code> ends the http block.</li>
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

The <code>script</code> rules is a shell script snippet that checks if a domain (represented by the variable <code>$DOMAIN</code>) is already present in the <code>/etc/hosts</code> file. If the domain is not found, it appends the domain with the IP address <code>127.0.0.1</code> to the <code>/etc/hosts</code> file.

This script is useful for accessing a local web server using a domain name instead of an IP address.

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
