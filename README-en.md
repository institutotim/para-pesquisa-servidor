Para Pesquisa
=============

Para Pesquisa is a free software for research forms creation. It was designed for Companies and Institutions interested in field research, in areas like Healthcare, Education, Housing, and Environment among others.
With Para Pesquisa, users can create new forms, follow-up finished and on-going researches, manage users and manage research funds.
It also comes with an Android App, which can be downloaded and installed in any Android tablet. Then the user can apply research forms and manage researches through an easy-to-use graphic interface. All the data collected is transferred using an internet connection to the server application.
The following sections will explain how to install Para Pesquisa on a Linux server.

## Complete Installation Guide

This guide is only recommend for those wishing to get a better grasp of the application architecture or are trying to build an image for larger deployments.

Since Para Pesquisa runs on a Ruby on Rails environment, first all the following dependencies need to be installed, in the following order:

 * Ruby
 * Redis
 * PostgreSQL
 * Git
 * Unicorn
 * Nginx
 
This guide thoroughly describe the deployment process of Para Pesquisa on an Ubutu Server (Linux) using nginx as a reverse proxy, configured to run on the same server.
However, other known deployment strategies may use different dependencies. If any  difficulty is experienced or additional information is needed, please refer to the Ruby on Rails official documentations:  http://rubyonrails.org/deploy/

Depending on how high the server’s workload will be, it may be necessary to run the application on a cluster. If so, refer to the following guides: Redis e PostgreSQL. Also, consider that may be necessary to apply load balancing for HTTP connections.
Keep in mind that this guide assumes that a new Ubunto installation is in use, without any prior package installed, and the user performing the installation is not the administrator.

### Ruby 2.0

First of all, update the server repositories:

    sudo apt-get -y update

Install the dependencies required to compile Ruby code:

    sudo apt-get -y install wget build-essential zlib1g-dev libssl-dev libreadline6-dev libyaml-dev libxml2 libxml2-dev libxslt1-dev
    
Download Ruby’s source code and build it:

    cd /tmp
    wget http://cache.ruby-lang.org/pub/ruby/2.0/ruby-2.0.0-p353.tar.gz
    tar -xvzf ruby-2.0.0-p353.tar.gz
    cd ruby-2.0.0-p353/
    ./configure --prefix=/usr/local
    
Compile it:

    Make

And finally, install it:

    sudo make install
    
### Redis

Redis works as a primary cache for all data being transferred from the tablet application to Para Pesquisa’s server.
Download and install Redis from linux’s repositories:

    sudo apt-get -y install redis-server
    
In order to increase performance, it may be necessary to perform additional configurations of Redis to decrease data flush time. This will prevent data loss between server and clients. If the clients experience data loss, they should synchronize the tablet data with the server before committing their updates.

### PostgreSQL

It is strongly recommended to install PostgreSQL latest version available. First, add PostgreSQL’s repository to the sources.list:

    sudo su -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ precise-pgdg main" >> /etc/apt/sources.list'
    sudo rm /var/lib/apt/lists/* -rf
    
Then perform an update and install PostgreSQL:

    sudo apt-get -y update
    sudo apt-get -y --force-yes install postgresql-9.3 postgresql-server-dev-9.3

### Git

Git is a system for revision control and source code management. GitHub, a web based Git repository, hosts Para Pesquisa source code. Therefore, in order to download Para Pesquisa, the server will also need Git.

Download and install Git:

    sudo apt-get -y install git-core
    
Create an user (para_pesquisa) to run Para Pesquisa:

    sudo adduser --disabled-password --gecos "" para_pesquisa
    
Download Para Pesquisa’s API:

    cd /home/para_pesquisa
    sudo git clone https://github.com/LaFabbrica/para-pesquisa-servidor.git

Install the bundler:

    cd para-pesquisa-servidor
    sudo gem install bundler

Install bundler dependencies:

    sudo bundle install --without development test --path vendor/bundle

Create a database for Para Pesquisa:

    sudo su - postgres -c "createdb para_pesquisa"

Create a user with database privileges:

    sudo su - postgres -c "psql -c \"CREATE USER para_pesquisa WITH PASSWORD 'CHOOSE_A_PASSWORD';\""
    sudo su - postgres -c "psql -c \"GRANT ALL PRIVILEGES ON DATABASE para_pesquisa to para_pesquisa;\""
    
Enable Password authentication on PostgreSQL:

    sudo sed -i 's/^\(local\s*all\s*all\s*\)\(peer\)/\1md5/' /etc/postgresql/9.3/main/pg_hba.conf
    sudo service postgresql restart
    
Then access the folder where the git repository has been cloned and change config/database.yml, setting the password defined above.
In order to restore the database structure for Para Pesquisa, it is necessary to install nodejs:

    sudo apt-get install nodejs

This command will create all the tables needed:

    bundle exec rake db:migrate

Create the Administrator user:

    bundle exec rake db:seed

### Unicorn
To allow the control of Para Pesquisa by upstart, it is necessary to install Unicorn. Unicorn works as a daemon that handles starting of tasks and services during boot, stopping them during shutdown and supervising them while the system is running. To set Unicorn up, first install the Unicornherder:
    
    sudo apt-get install -y python-dev python-pip
    sudo pip install unicornherder
    
Now, create a configuration file on `/etc/init/` so upstart can control Para Pesquisa:
description "Para Pesquisa - API"

    start on runlevel [2345]
    stop on runlevel [!2345]
    
    respawn
    respawn limit 5 20
    
    env PORT=8080
    env HOST=127.0.0.1
    
    env AWS_ACCESS_KEY_ID=Your Amazon S3 Access Key
    env AWS_SECRET_ACCESS_KEY=Your Amazon S3 Secret Key
    env AWS_BUCKET=Your Amazon S3 Bucket
    
    setuid para_pesquisa
    setgid para_pesquisa
    
    chdir /home/para_pesquisa/para-pesquisa-servidor

    exec bundle exec unicornherder -u unicorn -- -o $HOST --port $PORT -c config/unicorn.rb
    
Para Pesquisa has a data exportation feature. In order to use this feature, it is necessary to create an Amazon S3 account, it can be the AWS Free Tier, and configure the file above with your `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`.

Also, it is necessary to create a bucket for data storage, and pass its URL on AWS_BUCKET. This Data Exportation feature will be explained on another section of this document.
For More information regarding Amazon S3 services, please refer to:

 * [Amazon S3 Official Website.](http://aws.amazon.com/s3/)
 * [Amazon S3 Credencials Guide.](http://docs.aws.amazon.com/general/latest/gr/getting-aws-sec-creds.html)
 * [Amazon S3 Bucket Guide.](http://docs.aws.amazon.com/AmazonS3/latest/gsg/SigningUpforS3.html)
 
After configuring the unicornherder, set administrator permissions on Para Pesquisa home directory for the user “para_pesquisa”, and then start Para Pesquisa’s service:

    sudo chown -R para_pesquisa: /home/para_pesquisa
    sudo service para-pesquisa start

### NGINX
NGINX works as a buffer for slow connections and provides a static interface for Para Pesquisa’s server and the Administration Panel’s APIs.

    sudo apt-get install -y nginx

Now, configure NGINX to run as a reverse proxy for Unicorn, by adding a file named para-pesquisa-api to the NGINX configuration folder at /etc/nginx/sites-enabled/. The file content is: 

    upstream unicorn_server {
        server 127.0.0.1:8080 fail_timeout=0;
    }
    
    server {
        listen 80;
        client_max_body_size 4G;
        server_name api.para-pesquisa.org;
        keepalive_timeout 5;
        
        root /home/para_pesquisa/para-pesquisa-servidor/public;
        
        location / {
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header Host $http_host;
          proxy_redirect off;
        
          if (!-f $request_filename) {
            proxy_pass http://unicorn_server;
            break;
          }
        }
        
        error_page 500 502 503 504 /500.html;
        location = /500.html {
          root /home/para_pesquisa/para-pesquisa-servidor/public;
        }
    }

Please note that the variable `server_name` defines the name used in the nginx API, and can be set to a different value if needed.
Administration Panel

The Adminsitration Panel is a HTML5 application, responsible for managing Para Pesquisa installation. From this application, it is possible to create users, research forms and export research data. First, clone the repository on Para Pesquisa home directory:

    cd /home/para_pesquisa
    sudo git clone https://github.com/LaFabbrica/para-pesquisa-painel
    
After downloading this project, create an entrance for it on the GNINX and the Administration Panel will be good to go.  
Create a file named para-pesquisa-painel on the NGINX configuration folder at /etc/nginx/sites-enabled/ with the following content:

    server {
            listen 80;
            server_name para-pesquisa.org;
            root /home/para_pesquisa/para-pesquisa-painel/app;
            index index.html;
    }

Please note that the variable server_name defines the name for the Administration Panel, and can be set to a different value if needed.
After configuring nginx, run the following command to restart it:

    sudo service nginx restart

#### Setting Para Pesquisa’s base URL:

The following command will change the base URL for Para Pesquisa (please replace <BASE_URL> with  the desired URL):

sed -i '' 's/\(url\: \)\(undefined\)/\1"http:\/\/ <BASE_URL> "/' app/index.html

### Default Users:

The application comes with 3 pre-defined users:

 * Role: Administrator; username: `apiuser`; password: `apipass`
 * Role: Moderator; username: `moduser`; password: `modpass`
 * Role: Default agent; username: `agentuser`; password: `agentpass`

### Exporting data from Para Pesquisa

Para Pesquisa comes with an exportation tool, making it possible to use its data on other systems. This tool produces CSV files, and each entry keeps its database ID. Therefore, SQL queries can be created referencing data from Para Pesquisa.

This tool can be accessed on the Administration Panel by any user with Administrator privileges.
It is possible to export the following resources: Users, Forms, Data Fields, Submissions and Answers. 
The systems keep a log of older exportations. 

**Important**:

 * All data is exported using UTF-8 as encoding;
 * Only the newest  exportation of each resource can be downloaded;
 
Once exportation has started, the browser can be closed, since all the operation is performed server-side, and the result can be downloaded once it is over;
All the field headers are on Portuguese because the system currently only available on Portuguese. This guide, however, tries to provide users with translations and explanations on each of them. 

#### Exportable Resources

**Users**:
The “Users” tab on the exportation screen refers to Users exportation.

When exporting user data it is possible to  export usersfrom one of the following groups: Administrator, Coordinator, agent or “Todos” (Portuguese translation of “All”).  All the users information except password, which is encrypted on the data base, will be exported to the CSV file.

Selecting the option “Include Header” will add a header for the CSV file, containing the name of each column.
Exported User data files will be name following this pattern: `users_<timestamp>.csv`.
 
The data is exported following this structure:

 * user_id – (integer) – database ID of this user.
 * nome – (string) – user’s full name.
 * nome do usuário – (string) – user’s login.
 * e-mail – (string) – user’s email. May be null.
 * data de cadastro – (datetime) – user’s creation date, formatted as ISO 8601.
 * cargo – (string) – one of the three possible groups (Administrator, Coordinator, agent).

**Forms**:
The “Questionnaires” tab on the exportation screen refers to the forms exportation.
Selecting the option “Include Header” will add a header for the CSV file, containing the name of each column.
Exported forms data files will be name following this pattern: `forms_<timestamp>.csv`.

Exported Data:

 * form_id – (integer) – database ID for this form.
 * titulo – (string) – name given to the form.
 * subtítulo – (string) – summary describing the objectives of this form. Can be null.
 * data de criação – (string) – form’s creation date, formatted as ISO 8601.

**Data Fields**:
The “Fields” tab on the exportation screen refers to question fields created for any form on the system.
It is possible to cross references between fields and forms using both the form_id and field_id available on the exported file. 
Selecting the option “Incluir Cabeçalho (Include Header)” will add a header for the CSV file, containing the name of each column.
Exported fields files will be name following this pattern: `fields_<timestamp>.csv`.

Exported Data:

 * field_id - (integer) – database ID for this field. Can be cross referenced with the answers exportation file (answers_<timestamp>.csv).
 * form_id - (integer) - database ID indicating which form this field belongs to. Can be cross referenced with the forms exportation file (forms_<timestamp>.csv).
 * Título - (string) – the question associated with this field.
 * Tipo - (string) – data type for this field. Can be one of the following:
     * TextField - (string) – text field.
     * DatetimeField - (datetime) – field for dates and time, formatted as ISO 8601.
     * CpfField - (string) – field used for the Brazilian identification document CPF.
     * CheckboxField - (string[]) – field used for non-ordered multiple answers. 
     * EmailField - (string) – e-mail field, with automatic data validation.
     * PrivateField - (string) – private text field. The answer provided for this field will not be visible to the agent, only visible by higher clearance users.
     * NumberField - (integer /float) – field for generic numerical fields.
     * OrderedlistField - (string[]) – field used for ordered multiple answers. This field allows agents to order the answers given.
     * RadioField - (string) – Multiple selection field, with only one possible provided answer.
     * UrlField - (string) - Text field for URLs with automatic data validation.
     * SelectField - (string) – field representing a selected answer from a multiple choice question.
     * LabelField - (string) - Text field that can be used by the form creator to give out extra information for anyone applying this form.  This field should not be regarded when analyzing results.
     * DinheiroField - (string) – money field for Brazil’s currency: Real (R$). It has automatic data validation.

**Submissions**: 
The “Submissions” tab on the exportation screen refers to a form applied by a agent, containing the answers provided.
It is possible to cross references between forms and users that applied the form (agent) using both the form_id and user_id available on the exported file. 
On the exportation screen, it is possible to select a form, export all submissions related to it and filter the submissions by their system status.
Selecting the option “Incluir Cabeçalho (Include Header)” will add a header for the CSV file, containing the name of each column.
Exported fields files will be name following this pattern: submissions_<timestamp>.csv.

Exported Data:

 * submission_id - (integer) – database ID for this submission. Can be cross referenced with the answers exportation file (answers_<timestamp>.csv).
 * form_id - (integer) – database ID of the form corresponding to this submission. Can be cross referenced with the users exportation file (users_<timestamp>.csv).
 * user_id - (integer) – database ID of the user who performed the submission. Can be cross referenced with the forms exportation file (forms_<timestamp>.csv).
 * Data de criação - (datetime) – date on which the form was created, formatted as ISO 8601.  Only available if the form was imported into the system.
 * Data de preenchimento – (datetime) – date on which this submission was submitted, formatted as ISO 8601. 
 * Data de aprovação - (datetime) – date of this submission’s approval by a moderator user, formatted as ISO 8601.

**Answers**
The “Answers” tab on the exportation screen refers to answers given to research forms. This functionality has the same filter options as Submissions.
It is possible to cross references between a submission and an answer using the submission_id available on the exported file. 
Selecting the option “Incluir Cabeçalho (Include Header)” will add a header for the CSV file, containing the name of each column.
Exported fields files will be name following this pattern: `answers_<timestamp>.csv`.

Exported Data:

 * submission_id - (integer) – Database ID for this answer. Can be cross referenced with the submission exportation file (submission_<timestamp>.csv).
 * field_id - (integer) Database ID for the field corresponding to this answer. Can be cross referenced with the fields exportation file (fields_<timestamp>.csv).
 * answer – contains the value given as answer. Data type corresponds to the Field’s data type.
 * order - (integer) – this field is used for multiple answer fields, where the order of the answers given matters, therefore it is necessary to order the answers using this field.

## Para Pesquisa – Android Client
Para Pesquisa – Android Client is a default android application that can be easily edited by Android Studio or Eclipse.
In order to compile it, all a user needs to do is clone the git repository on a desired directory:
    
    cd <SELECTED_DIRECTORY>
    sudo git clone https://github.com/LaFabbrica/para-pesquisa-android
    
Then, compile the application:

    $ gradle
   
After it is compiled, you will need a Server Application: (https://github.com/LaFabbrica/para-pesquisa-servidor) and a Administration Panel : (https://github.com/LaFabbrica/para-pesquisa-painel) to create research forms.

You can find a pre-compiled version of the android application directly from Google Play:https://play.google.com/store/apps/details?id=com.lfdb.parapesquisa

## License
Para Pesquisa is released under GNU GPL version 2. A copy of this license can be found at this repository, file name LICENSE.